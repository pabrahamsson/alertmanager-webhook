use std::{collections::HashMap,env};

use bytes::Buf;
use changecase::ChangeCase;
use hyper::client::HttpConnector;
use hyper::service::{make_service_fn, service_fn};
use hyper::{header, Body, Client, Method, Request, Response, Server, StatusCode};
use hyper_tls::HttpsConnector;
use serde::{Deserialize, Serialize};
use serde_json::Value;

type GenericError = Box<dyn std::error::Error + Send + Sync>;
type Result<T> = std::result::Result<T, GenericError>;

static NOTFOUND: &[u8] = b"Not Found";
static OK: &[u8] = b"ok";
static COLOR_GREEN: u32 = 3066993;
static COLOR_RED: u32 = 10038562;

#[derive(Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
#[allow(dead_code)]
struct AMAlerts {
    alerts: Vec<AMAlert>,
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
struct AMAlert {
    annotations: HashMap<String, String>,
    ends_at: String,
    fingerprint: String,
    #[serde(rename = "generatorURL")]
    generator_url: String,
    //labels: Option<HashMap<String, String>>,
    labels: Value,
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
    //fields: Vec<DiscordField>,
}

#[derive(Serialize)]
struct DiscordField {
    name: String,
    value: String,
}

async fn discord_alert(client: &Client<HttpsConnector<HttpConnector>>, message: DiscordMessage) -> Result<Response<Body>> {
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

async fn get_description(annotations: &HashMap<String,String>) -> String {
    if annotations.contains_key(&String::from("description")) {
        annotations["description"].clone()
    } else if annotations.contains_key(&String::from("message")) {
        annotations["message"].clone()
    } else {
        "No 'description' or 'message' annotation found...".to_string()
    }
}

async fn create_embed(alert: &AMAlert) -> DiscordEmbed {
    let color = if alert.status == String::from("firing") {
        COLOR_RED
    } else {
        COLOR_GREEN
    };
    let description = get_description(&alert.annotations).await;
    let embed = DiscordEmbed {
        title: format!("{} - {} ({})",
            alert.labels["alertname"].as_str().unwrap(),
            alert.status.as_str().to_capitalized(),
            alert.labels["severity"].as_str().unwrap().to_uppercase()
        ),
        description: description.to_string(),
        color: color,
    };
    embed
}

async fn alerts_post_response(req: Request<Body>, client: &Client<HttpsConnector<HttpConnector>>) -> Result<Response<Body>> {
    let whole_body = hyper::body::aggregate(req).await?;
    let alerts: AMAlerts = serde_json::from_reader(whole_body.reader())?;
    let mut embeds = Vec::new();
    for alert in &alerts.alerts {
        let embed = create_embed(&alert).await;
        embeds.push(embed);
    };
    if embeds.len() > 0 {
        let discord_message = DiscordMessage {
            embeds: embeds,
        };
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
        (&Method::GET, "/healthz") => {
            Ok(Response::builder()
               .status(StatusCode::OK)
               .body(OK.into())
               .unwrap())
        },
        _ => {
            Ok(Response::builder()
               .status(StatusCode::NOT_FOUND)
               .body(NOTFOUND.into())
               .unwrap())
        }
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    pretty_env_logger::init();
    let addr = "0.0.0.0:6000".parse().unwrap();
    let https = HttpsConnector::new();
    let client = Client::builder()
        .build::<_, hyper::Body>(https);

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
