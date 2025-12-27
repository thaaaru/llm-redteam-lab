#!/bin/bash
set -e

# ============================================================
# Start LLM Red Team Lab
# ============================================================

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$LAB_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔴 STARTING RED TEAM LAB"
echo "  ⚠️  FOR DEFENSIVE SECURITY RESEARCH ONLY ⚠️"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Activate virtual environment
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found. Run ./install.sh first."
    exit 1
fi

source venv/bin/activate

# Check if Ollama is running
if ! pgrep -x "ollama" > /dev/null; then
    echo "[1/3] Starting Ollama service..."
    ./llm-runtime/start_ollama.sh &
    sleep 5
else
    echo "[1/3] Ollama already running"
fi

# Check if model is available
echo "[2/3] Verifying LLM model availability..."
./llm-runtime/health_check.sh

# Start target application
echo "[3/3] Starting vulnerable target application..."
cd target-app
./run.sh &
TARGET_PID=$!
cd ..

# Wait for services to be ready
echo ""
echo "Waiting for services to initialize..."
sleep 3

# Verify all services are running
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "  ✓ Ollama API: http://localhost:11434"
else
    echo "  ❌ Ollama API not responding"
fi

if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "  ✓ Target App: http://localhost:8000"
else
    echo "  ❌ Target App not responding"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Lab is Running"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Services:"
echo "  • Ollama API:    http://localhost:11434"
echo "  • Target App:    http://localhost:8000"
echo "  • API Docs:      http://localhost:8000/docs"
echo ""
echo "Ready to run red team attacks!"
echo ""
echo "Example commands:"
echo "  # Run PyRIT prompt injection attack"
echo "  python red-team-harness/pyrit_scenarios/prompt_injection.py"
echo ""
echo "  # Run Garak vulnerability scan"
echo "  ./red-team-harness/garak_scans/run_basic_scan.sh"
echo ""
echo "  # Run custom attack corpus"
echo "  python red-team-harness/custom_attacks/run_corpus.py"
echo ""
echo "To stop the lab: ./stop_lab.sh"
echo ""
