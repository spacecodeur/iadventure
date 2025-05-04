use httpserver::{Json, Router, post, run_http_server};
use services_manager::{get_service_port, ServicesName};
use serde::Serialize;
use uuid::Uuid;

#[derive(Serialize)]
struct AdventureResponse {
    adventure_id: String,
}

async fn create_adventure() -> Json<AdventureResponse> {
    let uuid = Uuid::new_v4();
    Json(AdventureResponse {
        adventure_id: uuid.to_string(),
    })
}

fn main() {
    let port = get_service_port(ServicesName::ADVENTURE);
    let app = Router::new().route("/", post(create_adventure));
    run_http_server(app, &port);
}