#!/bin/bash
set -e

# ============================================================
# Garak Full Vulnerability Scan
# Comprehensive test of all available probes
# ⚠️  WARNING: This may take 30+ minutes
# ============================================================

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$LAB_DIR"

source venv/bin/activate

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔬 Garak FULL Vulnerability Scan"
echo "  ⚠️  This may take 30+ minutes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Continue with full scan? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Scan cancelled"
    exit 0
fi

if ! curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "❌ Target application not running"
    exit 1
fi

mkdir -p evidence/garak

echo "Running comprehensive vulnerability scan..."
echo "This will test all available Garak probes."
echo ""

# Run all probes
python3 -m garak \
    --model_type rest \
    --model_name "http://localhost:8000/query" \
    --probes all \
    --output evidence/garak/full_scan.json \
    --report_prefix "full_scan" \
    || echo "⚠️  Some probes may not be compatible with REST endpoints"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Full scan complete"
echo "  Results: evidence/garak/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
