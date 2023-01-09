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
use serde::{Deserialize, Serialize};
use serde_json::Value;
use tokio::signal::unix::{signal, SignalKind};

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
            description: self.set_description().await,
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

async fn alerts_post_response(
    req: Request<Body>,
    client: &Client<HttpsConnector<HttpConnector>>,
) -> Result<Response<Body>> {
    let body = hyper::body::aggregate(req).await?;
    let alert: Data = serde_json::from_reader(body.reader())?;
    discord_alert(client, DiscordMessage::new(alert).await).await?;
    let response = Response::builder()
        .status(StatusCode::OK)
        .header(header::CONTENT_TYPE, "application/json")
        .body(Body::empty())?;
    Ok(response)
}

async fn response_handler(
    req: Request<Body>,
    client: Client<HttpsConnector<HttpConnector>>,
) -> Result<Response<Body>> {
    match (req.method(), req.uri().path()) {
        (&Method::POST, "/alerts") => alerts_post_response(req, &client).await,
        (&Method::GET, "/healthz") => Ok(Response::builder()
            .status(StatusCode::OK)
            .body(OK.into())
            .unwrap()),
        _ => Ok(Response::builder()
            .status(StatusCode::NOT_FOUND)
            .body(NOTFOUND.into())
            .unwrap()),
    }
}

#[tokio::main]
async fn main() {
    pretty_env_logger::init();
    let addr = "0.0.0.0:6000".parse().unwrap();
    let https = HttpsConnector::new();
    let client = Client::builder().build::<_, hyper::Body>(https);

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
    println!("Listening on http://{}", addr);
    let graceful = server
        .with_graceful_shutdown(async move {
            println!("waiting for signal");
            stream.recv().await;
            println!("done waiting for signal");
        });
    match tokio::join!(tokio::task::spawn(graceful)).0 {
        Ok(_) => println!("serving"),
        Err(e) => println!("ERROR: Thread join error {}", e)
    };
}
