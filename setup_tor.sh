#!/bin/bash
set -e

# ============================================================
# Tor and Proxychains Setup
# Installs and configures Tor for anonymous red team operations
# ============================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🧅 TOR & PROXYCHAINS SETUP"
echo "  Enables anonymous, DNS-leak-free red team operations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

# Install Tor
echo "[1/6] Installing Tor..."
apt-get update -qq
apt-get install -y tor torsocks > /dev/null 2>&1
echo "  ✓ Tor installed"
echo ""

# Install proxychains
echo "[2/6] Installing proxychains-ng..."
apt-get install -y proxychains4 > /dev/null 2>&1
echo "  ✓ Proxychains installed"
echo ""

# Configure Tor
echo "[3/6] Configuring Tor..."
cat > /etc/tor/torrc << 'EOF'
# Tor Configuration for Red Team Lab
# SOCKS5 proxy for anonymous operations

# SOCKS5 proxy
SOCKSPort 9050

# Ensure strict isolation
IsolateDestAddr 1
IsolateDestPort 1

# DNS port for DNS resolution through Tor
DNSPort 5353

# Control port (for monitoring)
ControlPort 9051

# Logging
Log notice file /var/log/tor/notices.log

# Security settings
ExcludeNodes {??}  # Exclude unknown countries
StrictNodes 1

# Circuit building
CircuitBuildTimeout 60
LearnCircuitBuildTimeout 0

# Performance
NumEntryGuards 8
EOF

echo "  ✓ Tor configured at /etc/tor/torrc"
echo ""

# Copy proxychains config
echo "[4/6] Configuring proxychains..."
LAB_DIR=$(dirname "$(readlink -f "$0")")

if [ -f "$LAB_DIR/config/proxychains.conf" ]; then
    cp "$LAB_DIR/config/proxychains.conf" /etc/proxychains4.conf
    echo "  ✓ Proxychains configured at /etc/proxychains4.conf"
else
    echo "  ⚠ Warning: Custom proxychains.conf not found, using default"
fi
echo ""

# Start Tor service
echo "[5/6] Starting Tor service..."
systemctl enable tor
systemctl restart tor
sleep 3

# Verify Tor is running
if systemctl is-active --quiet tor; then
    echo "  ✓ Tor service is running"
else
    echo "  ✗ Failed to start Tor service"
    journalctl -u tor --no-pager -n 20
    exit 1
fi
echo ""

# Test Tor connection
echo "[6/6] Testing Tor connection..."
echo "  Testing SOCKS5 proxy..."

# Wait for Tor to establish circuits
echo "  Waiting for Tor to establish circuits (this may take 30 seconds)..."
sleep 10

# Test connection
TEST_IP=$(proxychains4 -q curl -s --max-time 30 ifconfig.me 2>/dev/null || echo "FAILED")

if [ "$TEST_IP" == "FAILED" ]; then
    echo "  ✗ Tor connection test failed"
    echo "  Check Tor logs: sudo journalctl -u tor -n 50"
    exit 1
else
    echo "  ✓ Tor connection successful"
    echo "  Exit node IP: $TEST_IP"
fi
echo ""

# Install DNS leak check script
echo "Installing DNS leak checker..."
chmod +x "$LAB_DIR/config/dns_leak_check.sh"
echo "  ✓ DNS leak checker ready"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Tor & Proxychains Setup Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Configuration:"
echo "  • Tor SOCKS5:     127.0.0.1:9050"
echo "  • Tor DNS:        127.0.0.1:5353"
echo "  • Tor Control:    127.0.0.1:9051"
echo ""
echo "Usage:"
echo "  • Run with Tor:   proxychains4 <command>"
echo "  • Check for leaks: ./config/dns_leak_check.sh"
echo "  • Tor status:     sudo systemctl status tor"
echo "  • New circuit:    sudo systemctl restart tor"
echo ""
echo "⚠️  CRITICAL: Always run DNS leak check before operations!"
echo "    ./config/dns_leak_check.sh"
echo ""
echo "All red team attacks will now route through Tor with DNS leak"
echo "protection. Attacks will ABORT if DNS leaks are detected."
echo ""
