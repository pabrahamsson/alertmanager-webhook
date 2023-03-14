use std::{collections::HashMap, env};

use bytes::Buf;
use changecase::ChangeCase;
use hyper::{
    client::HttpConnector,
    header,
    service::{make_service_fn, service_fn},
    Body, Client, Method, Request, Response, Server, StatusCode,
};
use hyper_tls::HttpsConnector;
use opentelemetry::global;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use tokio::signal::unix::{signal, SignalKind};
use tracing::{info, Instrument};
use tracing_subscriber::{filter, fmt, layer::SubscriberExt, util::SubscriberInitExt};

type GenericError = Box<dyn std::error::Error + Send + Sync>;
type Result<T> = std::result::Result<T, GenericError>;
type KV = HashMap<String, String>;

static NOTFOUND: &[u8] = b"Not Found";
static OK: &[u8] = b"ok";
static COLOR_BLUE: u32 = 255;
static COLOR_GREEN: u32 = 65280;
static COLOR_ORANGE: u32 = 16744448;
static COLOR_RED: u32 = 16711680;

#[derive(Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
#[allow(dead_code)]
struct Data {
    alerts: Vec<Alert>,
    common_annotations: Value,
    common_labels: Value,
    #[serde(rename = "externalURL")]
    external_url: String,
    group_key: String,
    group_labels: Value,
    receiver: String,
    status: String,
}

#[derive(Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
#[allow(dead_code)]
struct Alert {
    annotations: KV,
    ends_at: String,
    fingerprint: String,
    #[serde(rename = "generatorURL")]
    generator_url: String,
    labels: KV,
    starts_at: String,
    status: String,
}

impl Alert {
    async fn create_embed(&self) -> DiscordEmbed {
        let color = if self.status == *"firing" {
            match self.labels["severity"].as_str() {
                "critical" => COLOR_RED,
                "warning" => COLOR_ORANGE,
                _ => COLOR_BLUE,
            }
        } else {
            COLOR_GREEN
        };
        DiscordEmbed {
            title: format!(
                "{} - {} ({})",
                self.labels["alertname"].as_str(),
                self.status.as_str().to_capitalized(),
                self.labels["severity"].as_str().to_uppercase()
            ),
            description: format!("{}\n\n[More info...]({})", self.set_description().await, self.generator_url.as_str()),
            //description: self.set_description().await,
            color,
        }
    }

    async fn set_description(&self) -> String {
        if self.annotations.contains_key(&String::from("description")) {
            self.annotations["description"].clone()
        } else if self.annotations.contains_key(&String::from("message")) {
            self.annotations["message"].clone()
        } else if self.annotations.contains_key(&String::from("summary")) {
            self.annotations["summary"].clone()
        } else {
            String::from("No 'description', 'message' or 'summary' annotation found...")
        }
    }
}

#[derive(Serialize, Debug)]
struct DiscordMessage {
    //content: String,
    embeds: Vec<DiscordEmbed>,
}

impl DiscordMessage {
    async fn new(data: Data) -> DiscordMessage {
        let mut embeds = Vec::new();
        for alert in &data.alerts {
            let embed = alert.create_embed().await;
            embeds.push(embed);
        }
        DiscordMessage { embeds }
    }
}

#[derive(Serialize, Debug)]
struct DiscordEmbed {
    title: String,
    description: String,
    color: u32,
}

async fn discord_alert(
    client: &Client<HttpsConnector<HttpConnector>>,
    message: DiscordMessage,
) -> Result<Response<Body>> {
    let discord_url = env::var("WEBHOOK")?;
    let req = Request::builder()
        .method(Method::POST)
        .uri(discord_url)
        .header(header::CONTENT_TYPE, "application/json")
        .body(serde_json::to_string(&message)?.into())
        .unwrap();

    let res = client.request(req).await?;
    Ok(Response::new(res.into_body()))
}

#[tracing::instrument]
async fn alerts_post_response(
    req: Request<Body>,
    client: &Client<HttpsConnector<HttpConnector>>,
) -> Result<Response<Body>> {
    let body = hyper::body::aggregate(req).await?;
    let alert: Data = serde_json::from_reader(body.reader())?;
    tracing::info!(alert = ?alert);
    discord_alert(client, DiscordMessage::new(alert).await).await?;
    let response = Response::builder()
        .status(StatusCode::OK)
        .header(header::CONTENT_TYPE, "application/json")
        .body(Body::empty())?;
    tracing::info!(discord_response = ?response);
    Ok(response)
}

#[tracing::instrument]
async fn health_response() -> Result<Response<Body>> {
    tracing::info!("A_OK");
    Ok(Response::builder()
        .status(StatusCode::OK)
        .body(OK.into())
        .unwrap())
}

async fn response_handler(
    req: Request<Body>,
    client: Client<HttpsConnector<HttpConnector>>,
) -> Result<Response<Body>> {
    match (req.method(), req.uri().path()) {
        (&Method::POST, "/alerts") => {
            alerts_post_response(req, &client)
                .instrument(tracing::info_span!("/alerts"))
            .await
        },
        (&Method::GET, "/healthz") => {
            health_response()
                .instrument(tracing::info_span!("/healthz"))
            .await
        },
        _ => Ok(Response::builder()
            .status(StatusCode::NOT_FOUND)
            .body(NOTFOUND.into())
            .unwrap()),
    }
}

#[tokio::main]
async fn main() -> std::result::Result<(), Box<dyn std::error::Error>> {
    let addr = "0.0.0.0:6000".parse().unwrap();
    let https = HttpsConnector::new();
    let client = Client::builder().build::<_, hyper::Body>(https);

    global::set_text_map_propagator(opentelemetry_jaeger::Propagator::new());
    let tracer = opentelemetry_jaeger::new_agent_pipeline()
        .with_service_name("alertmanager-webhook")
        .install_simple()?;
    let opentelemetry = tracing_opentelemetry::layer().with_tracer(tracer);
    let fmt_layer = fmt::layer().json();
    tracing_subscriber::registry()
        .with(opentelemetry)
        .with(filter::LevelFilter::INFO)
        .with(fmt_layer)
        .try_init()?;

    let new_service = make_service_fn(move |_| {
        let client = client.clone();
        async {
            Ok::<_, GenericError>(service_fn(move |req| {
                response_handler(req, client.to_owned())
            }))
        }
    });

    let mut stream = signal(SignalKind::terminate()).expect("Failed to create stream");
    let server = Server::bind(&addr).serve(new_service);
    info!("{}", format!("Listening on http://{}", addr));
    let graceful = server
        .with_graceful_shutdown(async move {
            info!("{}", format!("waiting forrrrrr signal"));
            stream.recv().await;
            info!("done waiting for signal");
        });
    match tokio::join!(tokio::task::spawn(graceful)).0 {
        Ok(_) => println!("serving"),
        Err(e) => println!("ERROR: Thread join error {}", e)
    };
    Ok(())
}
