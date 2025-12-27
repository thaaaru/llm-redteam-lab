#!/bin/bash
set -e

# ============================================================
# Start Ollama Service with Red Team Lab Configuration
# ============================================================

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load Ollama environment variables
set -a
source "$LAB_DIR/config/ollama.env"
set +a

echo "Starting Ollama on $OLLAMA_HOST..."

# Check if already running
if pgrep -x "ollama" > /dev/null; then
    echo "⚠️  Ollama is already running"
    exit 0
fi

# Start Ollama service in the background
# The serve command starts the API server
ollama serve > /tmp/ollama.log 2>&1 &

OLLAMA_PID=$!
echo "Ollama started (PID: $OLLAMA_PID)"

# Wait for service to be ready
echo "Waiting for Ollama to be ready..."
for i in {1..30}; do
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo "✓ Ollama API is ready"
        exit 0
    fi
    sleep 1
done

echo "❌ Ollama failed to start within 30 seconds"
echo "Check logs: /tmp/ollama.log"
exit 1
