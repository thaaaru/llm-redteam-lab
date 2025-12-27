#!/bin/bash

# ============================================================
# Ollama Health Check
# Verifies the LLM runtime is operational
# ============================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Checking Ollama health..."
echo ""

# Check 1: Process running
if pgrep -x "ollama" > /dev/null; then
    echo -e "${GREEN}✓${NC} Ollama process is running"
else
    echo -e "${RED}✗${NC} Ollama process not found"
    echo "  Start with: ./llm-runtime/start_ollama.sh"
    exit 1
fi

# Check 2: API responding
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Ollama API is responding"
else
    echo -e "${RED}✗${NC} Ollama API not responding on localhost:11434"
    exit 1
fi

# Check 3: Models available
MODELS=$(curl -s http://localhost:11434/api/tags | grep -o '"name":"[^"]*"' | cut -d'"' -f4)

if [ -z "$MODELS" ]; then
    echo -e "${YELLOW}⚠${NC} No models installed"
    echo "  Install with: ./llm-runtime/pull_model.sh"
    exit 1
else
    echo -e "${GREEN}✓${NC} Models available:"
    for model in $MODELS; do
        echo "    - $model"
    done
fi

# Check 4: Test inference
echo ""
echo "Testing inference..."
TEST_RESPONSE=$(curl -s http://localhost:11434/api/generate -d '{
  "model": "'"$(echo $MODELS | awk '{print $1}')"'",
  "prompt": "Say OK",
  "stream": false,
  "options": {
    "num_predict": 5
  }
}' | grep -o '"response":"[^"]*"' | cut -d'"' -f4)

if [ -n "$TEST_RESPONSE" ]; then
    echo -e "${GREEN}✓${NC} Inference test passed"
    echo "  Response: $TEST_RESPONSE"
else
    echo -e "${RED}✗${NC} Inference test failed"
    exit 1
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  All health checks passed${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
