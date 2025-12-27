#!/bin/bash
set -e

# ============================================================
# Tor-Protected Attack Wrapper
# Runs attacks through Tor with DNS leak detection
# ABORTS if DNS leaks detected
# ============================================================

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  ${CYAN}🧅 TOR-PROTECTED RED TEAM OPERATION${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Tor is installed
if ! command -v proxychains4 &> /dev/null; then
    echo -e "${RED}✗ proxychains4 not found${NC}"
    echo "  Run: sudo ./setup_tor.sh"
    exit 1
fi

if ! pgrep -x "tor" > /dev/null; then
    echo -e "${RED}✗ Tor is not running${NC}"
    echo "  Start Tor: sudo systemctl start tor"
    exit 1
fi

echo -e "${GREEN}✓${NC} Tor is running"
echo ""

# Run DNS leak check
echo "━━━ RUNNING DNS LEAK DETECTION ━━━"
echo ""

if ! bash "$LAB_DIR/config/dns_leak_check.sh"; then
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  CRITICAL: DNS LEAK DETECTED                          ║${NC}"
    echo -e "${RED}║  ABORTING FOR SECURITY                                 ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Your real IP or DNS servers may be exposed."
    echo "Do NOT proceed with red team operations."
    echo ""
    echo "Fix the leak first, then try again."
    exit 1
fi

echo ""
echo "━━━ DNS LEAK CHECK PASSED ━━━"
echo ""

# Verify we have a command to run
if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 <command> [args...]${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 python red-team-harness/pyrit_scenarios/prompt_injection.py"
    echo "  $0 curl http://localhost:8000/query"
    echo "  $0 ./red-team-harness/garak_scans/run_basic_scan.sh"
    exit 1
fi

# Display operation info
echo -e "${CYAN}Operation Details:${NC}"
echo "  Command: $*"
echo "  Routing: Tor SOCKS5 (127.0.0.1:9050)"
echo "  DNS: Proxied through Tor"
echo "  Leak Protection: ENABLED"
echo ""

# Confirm before proceeding
read -p "Proceed with Tor-protected operation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo ""
echo "━━━ EXECUTING THROUGH TOR ━━━"
echo ""

# Export proxychains config location
export PROXYCHAINS_CONF_FILE="$LAB_DIR/config/proxychains.conf"

# Run command through proxychains
# Note: -q flag for quiet mode (less verbose output)
if proxychains4 "$@"; then
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✓ Operation completed successfully through Tor${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    exit 0
else
    EXIT_CODE=$?
    echo ""
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  ✗ Operation failed (exit code: $EXIT_CODE)${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    exit $EXIT_CODE
fi
