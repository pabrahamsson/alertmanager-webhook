use std::{collections::HashMap, env};

use axum::{
    body::Body,
    extract::{Json, State},
    http::{Request, StatusCode},
    response::IntoResponse,
    routing::{get, post},
    Router,
};
use axum_tracing_opentelemetry::middleware::{
    OtelAxumLayer,
    OtelInResponseLayer,
};
use changecase::ChangeCase;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use tokio::net::TcpListener;
use tracing_opentelemetry_instrumentation_sdk::find_current_trace_id;

type KV = HashMap<String, String>;

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
            description: format!(
                "{}\n\n[More info...]({})",
                self.set_description().await,
                self.generator_url.as_str()
            ),
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

fn reqwest_to_axum_statuscode(res: &reqwest::Response) -> Result<StatusCode, http::status::InvalidStatusCode> {
    StatusCode::from_u16(res.status().as_u16())
}

#[tracing::instrument(name="send_alert", fields(http.status))]
async fn discord_alert(
    client: &Client,
    message: DiscordMessage,
) -> Result<reqwest::Response, reqwest::Error> {
    let discord_url = env::var("WEBHOOK").unwrap();
    let res = client.post(discord_url).json(&message).send().await;
    tracing::Span::current()
        .record("http.status", format!("{}", &res.as_ref().unwrap().status().as_u16()));
    res
}

#[tracing::instrument(name="post_response", fields(res))]
async fn alerts_post_response(
    State(client): State<Client>,
    Json(payload): Json<Data>,
) -> impl IntoResponse {
    match discord_alert(&client, DiscordMessage::new(payload).await).await {
        Ok(res) => {
            tracing::Span::current().record("res", format!("{:?}", &res));
            (reqwest_to_axum_statuscode(&res).unwrap(), axum::Json(json!({"status": format!("{}", &res.status().as_u16())})))
        },
        Err(e) => {
            tracing::Span::current().record("res", format!("{:?}", &e));
            (StatusCode::INTERNAL_SERVER_ERROR, axum::Json(json!({"status":"500"})))
        },
    }
}

async fn health_response() -> impl IntoResponse {
    (StatusCode::OK, axum::Json(json!({"status": "UP"})))
}

#[tracing::instrument(name="Index")]
async fn index() -> impl IntoResponse {
    let trace_id = find_current_trace_id();
    dbg!(&trace_id);
    axum::Json(json!({"status": trace_id}))
}

#[tracing::instrument(name="404")]
async fn handler_404(req: Request<Body>) -> impl IntoResponse {
    (StatusCode::NOT_FOUND, axum::Json(json!({"status": "404 - Lost in the big bitbucket in the sky"})))
}

#[tokio::main]
async fn main() {
    let _ = init_tracing_opentelemetry::tracing_subscriber_ext::init_subscribers();
    let client = Client::new();
    let app = Router::new()
        .route("/", get(index))
        .route("/alerts", post(alerts_post_response))
        .with_state(client)
        .layer(OtelInResponseLayer)
        .layer(OtelAxumLayer::default())
        .route("/healthz", get(health_response))
        .fallback(handler_404);
    let listener = TcpListener::bind("0.0.0.0:6000").await.unwrap();
    tracing::debug!("Listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app.into_make_service()).await.unwrap();
}
