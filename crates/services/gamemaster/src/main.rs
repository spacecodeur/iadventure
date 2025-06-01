use httpserver::{Json, Router, get, run_http_server};
use serde::Serialize;
use services_manager::{ServicesName, get_service_port};

#[derive(Serialize)]
struct SimpleResponse {
    message: String,
}

async fn helloworld() -> Json<SimpleResponse> {
    // try me from a docker container inner the ${APP_NAME}-docker-network network
    // with commands :
    //      - curl --location --request GET 'http://service-gamemaster:51082'
    Json(SimpleResponse {
        message: "hello ! I'm the service gamemaster !".to_string(),
    })
}

fn main() {
    let port = get_service_port(ServicesName::GAMEMASTER);
    let app = Router::new().route("/", get(helloworld));
    run_http_server(app, &port);
}
