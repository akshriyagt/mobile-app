FROM python:3.11-slim

# ffmpeg is required by faster-whisper to decode most audio formats
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Model size: tiny/base/small/medium (see README) — "small" is the default
# in app.py. Override here if your host has limited RAM.
ENV WHISPER_MODEL=small
ENV FLASK_DEBUG=false

# Whisper transcription is slow per-request, so this uses a single worker
# with a long timeout instead of Flask's dev server. Cloud hosts set $PORT
# automatically; 5000 is the local fallback.
EXPOSE 5000
CMD gunicorn --bind 0.0.0.0:${PORT:-5000} --workers 1 --timeout 600 app:app
