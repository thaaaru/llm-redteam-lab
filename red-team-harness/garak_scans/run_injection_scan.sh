#!/bin/bash
set -e

# ============================================================
# Garak Injection-Focused Scan
# Specifically tests prompt injection vulnerabilities
# ============================================================

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$LAB_DIR"

source venv/bin/activate

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  💉 Garak Injection Vulnerability Scan"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if ! curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "❌ Target application not running"
    exit 1
fi

mkdir -p evidence/garak

echo "Testing prompt injection vulnerabilities..."
echo ""

# Focus on injection-related probes
python3 -m garak \
    --model_type rest \
    --model_name "http://localhost:8000/query" \
    --probes promptinject \
    --probes continuation \
    --probes misleading \
    --output evidence/garak/injection_scan.json \
    || echo "⚠️  Note: Adjust Garak syntax based on installed version"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Injection scan complete"
echo "  Results: evidence/garak/injection_scan.json"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
