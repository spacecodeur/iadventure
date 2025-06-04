#!/usr/bin/env python3
"""
EVA Qwen2.5-72B v0.1 model download script
Automatically executed during container build if model doesn't exist
"""

import os
import sys
import time
from pathlib import Path
from transformers import AutoTokenizer
from huggingface_hub import snapshot_download

MODEL_NAME = "EVA-UNIT-01/EVA-Qwen2.5-72B-v0.1"
CACHE_DIR = "/home/appuser/.cache/huggingface"
STATUS_FILE = "/home/appuser/.cache/model_download_status.txt"

def write_status(status):
    """Write download status to file"""
    with open(STATUS_FILE, "w") as f:
        f.write(f"{status}|{time.time()}\n")

def check_model_exists():
    """Check if model is already downloaded"""
    model_path = Path(CACHE_DIR) / f"models--{MODEL_NAME.replace('/', '--')}"
    return model_path.exists() and any(model_path.iterdir())

def download_model():
    """Download model with progress tracking"""
    try:
        write_status("STARTING")
        print(f"🚀 Starting download of model {MODEL_NAME}")
        
        # Download tokenizer (fast)
        write_status("DOWNLOADING_TOKENIZER")
        print("📥 Downloading tokenizer...")
        AutoTokenizer.from_pretrained(MODEL_NAME, cache_dir=CACHE_DIR)
        
        # Download complete model
        write_status("DOWNLOADING_MODEL")
        print("📥 Downloading model (this may take a long time)...")
        snapshot_download(
            repo_id=MODEL_NAME,
            cache_dir=CACHE_DIR,
            resume_download=True
        )
        
        write_status("COMPLETED")
        print("✅ Download completed successfully!")
        return True
        
    except Exception as e:
        write_status(f"ERROR: {str(e)}")
        print(f"❌ Download error: {e}")
        return False

def main():
    print("🔍 Checking for existing model...")
    
    if check_model_exists():
        write_status("ALREADY_EXISTS")
        print("✅ Model already exists, skipping download")
        return
    
    success = download_model()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()