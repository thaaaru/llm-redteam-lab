#!/bin/bash
set -e

# ============================================================
# Start Vulnerable RAG Application
# ⚠️ FOR TESTING ONLY ⚠️
# ============================================================

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Activate virtual environment
source "$LAB_DIR/venv/bin/activate"

# Set Python path to include logging module
export PYTHONPATH="$LAB_DIR:$PYTHONPATH"

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔴 Starting Vulnerable RAG Application"
echo "  ⚠️  INTENTIONALLY INSECURE - FOR TESTING ONLY ⚠️"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Ollama is running
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "❌ Ollama is not running. Start it first:"
    echo "   ./llm-runtime/start_ollama.sh"
    exit 1
fi

# Start the application
exec uvicorn app:app \
    --host 127.0.0.1 \
    --port 8000 \
    --log-level info
