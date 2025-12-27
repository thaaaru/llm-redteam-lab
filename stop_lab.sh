#!/bin/bash

# ============================================================
# Stop LLM Red Team Lab
# ============================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Stopping Red Team Lab..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Stop target application (FastAPI/uvicorn)
if pgrep -f "uvicorn.*target-app" > /dev/null; then
    echo "[1/2] Stopping target application..."
    pkill -f "uvicorn.*target-app"
    echo "  ✓ Target app stopped"
else
    echo "[1/2] Target app not running"
fi

# Stop Ollama (optional - can keep running)
read -p "[2/2] Stop Ollama service? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if pgrep -x "ollama" > /dev/null; then
        echo "  Stopping Ollama..."
        pkill -x ollama
        echo "  ✓ Ollama stopped"
    else
        echo "  Ollama not running"
    fi
else
    echo "  Keeping Ollama running"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Lab Stopped"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
