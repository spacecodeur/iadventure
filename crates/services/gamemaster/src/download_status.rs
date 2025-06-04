use chrono::DateTime;
use httpserver::Json;
use serde::Serialize;
use std::fs;

#[derive(Serialize)]
pub struct DownloadStatusResponse {
    pub status: String,
    pub timestamp: Option<String>,
    pub message: String,
    pub duration_seconds: Option<i64>,
}

pub async fn download_status() -> Json<DownloadStatusResponse> {
    let status_file = "/home/appuser/.cache/model_download_status.txt";

    match fs::read_to_string(status_file) {
        Ok(content) => {
            let parts: Vec<&str> = content.trim().split('|').collect();
            if parts.len() >= 2 {
                let status = parts[0].to_string();
                let timestamp_str = parts[1];

                if let Ok(timestamp_f64) = timestamp_str.parse::<f64>() {
                    let timestamp_i64 = timestamp_f64 as i64;
                    let datetime = DateTime::from_timestamp(timestamp_i64, 0);
                    let formatted_time =
                        datetime.map(|dt| dt.format("%Y-%m-%d %H:%M:%S UTC").to_string());

                    let duration = DateTime::from_timestamp(chrono::Utc::now().timestamp(), 0)
                        .and_then(|now| datetime.map(|start| (now - start).num_seconds()));

                    let message = match status.as_str() {
                        "STARTING" => "Download initialization...".to_string(),
                        "DOWNLOADING_TOKENIZER" => "Downloading tokenizer...".to_string(),
                        "DOWNLOADING_MODEL" => {
                            "Downloading main model (may take several hours)...".to_string()
                        }
                        "COMPLETED" => "Download completed successfully!".to_string(),
                        "ALREADY_EXISTS" => "Model already exists".to_string(),
                        s if s.starts_with("ERROR:") => format!("Error: {}", &s[6..]),
                        _ => format!("Unknown status: {}", status),
                    };

                    Json(DownloadStatusResponse {
                        status,
                        timestamp: formatted_time,
                        message,
                        duration_seconds: duration,
                    })
                } else {
                    Json(DownloadStatusResponse {
                        status: "ERROR".to_string(),
                        timestamp: None,
                        message: "Invalid timestamp format".to_string(),
                        duration_seconds: None,
                    })
                }
            } else {
                Json(DownloadStatusResponse {
                    status: "ERROR".to_string(),
                    timestamp: None,
                    message: "Invalid status file format".to_string(),
                    duration_seconds: None,
                })
            }
        }
        Err(_) => Json(DownloadStatusResponse {
            status: "UNKNOWN".to_string(),
            timestamp: None,
            message: "Status file not found - download may not have started yet".to_string(),
            duration_seconds: None,
        }),
    }
}
