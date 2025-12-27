#!/bin/bash
set -e

# ============================================================
# DNS Leak Detection Script
# Checks for DNS leaks before running red team operations
# ABORTS if any leaks are detected
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔍 DNS LEAK DETECTION TEST"
echo "  Critical: Aborts on any DNS leak detection"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

LEAK_DETECTED=0

# Check if Tor is running
if ! pgrep -x "tor" > /dev/null; then
    echo -e "${RED}✗ CRITICAL: Tor is not running${NC}"
    echo "  Start Tor first: sudo systemctl start tor"
    exit 1
fi

echo -e "${GREEN}✓${NC} Tor is running"
echo ""

# Test 1: Check real IP (without proxy)
echo "[1/5] Checking real IP address..."
REAL_IP=$(curl -s --max-time 10 ifconfig.me 2>/dev/null || echo "UNKNOWN")
if [ "$REAL_IP" == "UNKNOWN" ]; then
    echo -e "${YELLOW}⚠${NC} Warning: Could not determine real IP (might already be behind firewall)"
    REAL_IP="N/A"
else
    echo "  Real IP: $REAL_IP"
fi
echo ""

# Test 2: Check Tor IP (through proxy)
echo "[2/5] Checking Tor exit node IP..."
TOR_IP=$(proxychains4 -q curl -s --max-time 15 ifconfig.me 2>/dev/null || echo "FAILED")
if [ "$TOR_IP" == "FAILED" ]; then
    echo -e "${RED}✗ CRITICAL: Cannot connect through Tor proxy${NC}"
    echo "  Check Tor configuration and network connectivity"
    exit 1
fi
echo "  Tor IP: $TOR_IP"

# Verify IPs are different (unless firewall blocks direct access)
if [ "$REAL_IP" != "N/A" ] && [ "$REAL_IP" == "$TOR_IP" ]; then
    echo -e "${RED}✗ CRITICAL: Tor IP matches real IP - proxy not working!${NC}"
    LEAK_DETECTED=1
fi
echo ""

# Test 3: DNS leak test through multiple providers
echo "[3/5] Testing DNS resolution through Tor..."

# Test with multiple DNS leak detection services
DNS_LEAK_SERVICES=(
    "https://www.dnsleaktest.com/api/v1/leak-test"
    "https://ipleak.net/json/"
)

for service in "${DNS_LEAK_SERVICES[@]}"; do
    echo "  Testing with: $service"

    # Get DNS servers seen by the service (through Tor)
    DNS_RESULT=$(proxychains4 -q curl -s --max-time 15 "$service" 2>/dev/null || echo "TIMEOUT")

    if [ "$DNS_RESULT" == "TIMEOUT" ]; then
        echo -e "    ${YELLOW}⚠${NC} Service timeout (may be blocked)"
        continue
    fi

    # Check if our real IP appears in the DNS result
    if [ "$REAL_IP" != "N/A" ] && echo "$DNS_RESULT" | grep -q "$REAL_IP"; then
        echo -e "    ${RED}✗ DNS LEAK DETECTED: Real IP found in DNS query!${NC}"
        LEAK_DETECTED=1
    else
        echo -e "    ${GREEN}✓${NC} No leak detected from this service"
    fi
done
echo ""

# Test 4: Verify DNS is proxied
echo "[4/5] Verifying DNS proxy configuration..."

# Check proxychains config
if grep -q "^proxy_dns" config/proxychains.conf 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} proxy_dns enabled in configuration"
else
    echo -e "  ${RED}✗ CRITICAL: proxy_dns NOT enabled${NC}"
    LEAK_DETECTED=1
fi

# Verify resolv.conf doesn't expose local DNS
if [ -f /etc/resolv.conf ]; then
    LOCAL_DNS=$(grep "^nameserver" /etc/resolv.conf | grep -v "127.0.0.1" | head -1)
    if [ -n "$LOCAL_DNS" ]; then
        echo -e "  ${YELLOW}⚠${NC} Local DNS servers configured: $LOCAL_DNS"
        echo "     Ensure DNS queries go through Tor"
    fi
fi
echo ""

# Test 5: DNS query test
echo "[5/5] Performing actual DNS query test..."

# Test DNS resolution through proxychains
TEST_DOMAIN="check.torproject.org"
echo "  Resolving: $TEST_DOMAIN through Tor..."

DNS_TEST=$(proxychains4 -q nslookup "$TEST_DOMAIN" 2>&1 || echo "FAILED")
if echo "$DNS_TEST" | grep -q "FAILED"; then
    echo -e "  ${RED}✗ DNS resolution through Tor failed${NC}"
    LEAK_DETECTED=1
else
    echo -e "  ${GREEN}✓${NC} DNS resolution through Tor successful"
fi
echo ""

# Final verdict
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $LEAK_DETECTED -eq 0 ]; then
    echo -e "${GREEN}  ✓ NO DNS LEAKS DETECTED - SAFE TO PROCEED${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Tor Circuit Information:"
    echo "  Exit Node IP: $TOR_IP"
    echo "  Proxy: SOCKS5 127.0.0.1:9050"
    echo ""
    exit 0
else
    echo -e "${RED}  ✗ DNS LEAKS DETECTED - ABORTING FOR SECURITY${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "CRITICAL SECURITY ISSUE:"
    echo "  DNS leaks can expose your real identity and location."
    echo ""
    echo "Remediation steps:"
    echo "  1. Verify Tor is running: sudo systemctl status tor"
    echo "  2. Check proxychains config: cat config/proxychains.conf"
    echo "  3. Ensure proxy_dns is enabled"
    echo "  4. Test Tor connection: proxychains4 curl ifconfig.me"
    echo "  5. Check firewall rules: sudo ufw status"
    echo ""
    echo "DO NOT PROCEED until leaks are fixed!"
    echo ""
    exit 1
fi
