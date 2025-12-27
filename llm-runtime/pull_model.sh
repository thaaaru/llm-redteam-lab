#!/bin/bash
set -e

# ============================================================
# Pull Uncensored LLaMA Model for Red Team Testing
# ============================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Pulling Uncensored LLaMA Model"
echo "  ⚠️  This may take several minutes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Model options (choose one):
# 1. llama2-uncensored:7b - Smaller, faster, less capable
# 2. wizard-vicuna-uncensored:13b - Better quality
# 3. dolphin-llama3:8b - Alternative uncensored variant

MODEL_NAME="${1:-llama2-uncensored:7b}"

echo "Target model: $MODEL_NAME"
echo ""

# Ensure Ollama is running
if ! pgrep -x "ollama" > /dev/null; then
    echo "Starting Ollama service..."
    ../llm-runtime/start_ollama.sh
    sleep 5
fi

# Pull the model
echo "Downloading model (this downloads ~4-8GB)..."
echo ""
ollama pull "$MODEL_NAME"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Model Downloaded: $MODEL_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "To verify:"
echo "  ollama list"
echo ""
echo "To test:"
echo "  ollama run $MODEL_NAME"
echo ""
echo "⚠️  REMINDER: This model is uncensored and intended for"
echo "    red team testing only. Do not use in production."
echo ""
