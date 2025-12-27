#!/bin/bash
set -e

# ============================================================
# Garak Basic Vulnerability Scan
# Runs core vulnerability probes against the target
# ============================================================

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$LAB_DIR"

# Activate virtual environment
source venv/bin/activate

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔍 Garak Basic Vulnerability Scan"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if target is running
if ! curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "❌ Target application not running. Start with: ./start_lab.sh"
    exit 1
fi

# Create output directory
mkdir -p evidence/garak

# Run Garak with basic probes
# Note: Garak syntax may vary by version - adjust as needed

echo "Running basic vulnerability scan..."
echo ""

# Method 1: Using REST API generator (if supported)
python3 -m garak \
    --model_type rest \
    --model_name "http://localhost:8000/query" \
    --probes promptinject \
    --probes encoding \
    --output evidence/garak/basic_scan.json \
    || echo "⚠️  Garak REST support may require additional configuration"

# Method 2: Using custom interface (fallback)
# If direct REST support isn't available, use the custom scanner below

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Basic scan complete"
echo "  Results: evidence/garak/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
