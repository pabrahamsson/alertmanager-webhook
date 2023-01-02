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

#[derive(Serialize, Debug)]
struct DiscordMessage {
    //content: String,
    embeds: Vec<DiscordEmbed>,
}

#[derive(Serialize, Debug)]
struct DiscordEmbed {
    title: String,
    description: String,
    color: u32,
}

#[derive(Serialize)]
struct DiscordField {
    name: String,
    value: String,
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

async fn get_description(annotations: &KV) -> String {
    if annotations.contains_key(&String::from("description")) {
        annotations["description"].clone()
    } else if annotations.contains_key(&String::from("message")) {
        annotations["message"].clone()
    } else if annotations.contains_key(&String::from("summary")) {
        annotations["summary"].clone()
    } else {
        "No 'description' or 'message' annotation found...".to_string()
    }
}

async fn create_embed(alert: &Alert) -> DiscordEmbed {
    let color = if alert.status == *"firing" {
        if alert.labels["severity"] == "critical" {
            COLOR_RED
        } else if alert.labels["severity"] == "warning" {
            COLOR_ORANGE
        } else {
            COLOR_BLUE
        }
    } else {
        COLOR_GREEN
    };
    DiscordEmbed {
        title: format!(
            "{} - {} ({})",
            alert.labels["alertname"].as_str(),
            alert.status.as_str().to_capitalized(),
            alert.labels["severity"].as_str().to_uppercase()
        ),
        description: get_description(&alert.annotations).await,
        color,
    }
}

async fn alerts_post_response(
    req: Request<Body>,
    client: &Client<HttpsConnector<HttpConnector>>,
) -> Result<Response<Body>> {
    let body = hyper::body::aggregate(req).await?;
    let alerts: Data = serde_json::from_reader(body.reader())?;
    let mut embeds = Vec::new();
    for alert in &alerts.alerts {
        let embed = create_embed(alert).await;
        embeds.push(embed);
    }
    if !embeds.is_empty() {
        let discord_message = DiscordMessage { embeds };
        discord_alert(client, discord_message).await?;
    }
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
async fn main() -> Result<()> {
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

    let server = Server::bind(&addr).serve(new_service);
    println!("Listening on http://{}", addr);
    server.await?;
    Ok(())
}
