#!/bin/bash
set -e

# ============================================================
# Network Isolation Setup
# Ensures the lab operates in an air-gapped mode
# ============================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  NETWORK ISOLATION SETUP"
echo "  Configuring localhost-only access"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

# Enable UFW if not already enabled
if ! ufw status | grep -q "Status: active"; then
    echo "[1/4] Enabling UFW firewall..."
    ufw --force enable
else
    echo "[1/4] UFW already enabled"
fi

echo "[2/4] Setting default policies..."
# Deny all incoming/outgoing by default
ufw default deny incoming
ufw default deny outgoing

echo "[3/4] Allowing localhost traffic..."
# Allow all traffic on loopback interface
ufw allow in on lo
ufw allow out on lo

# Allow established connections (needed for system stability)
ufw allow out to any port 53  # DNS (for initial setup only)
ufw allow out to any port 123 # NTP (for system time)

echo "[4/4] Verifying configuration..."
ufw status verbose

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Network Isolation Configured"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  WARNING: Outbound internet access is now restricted."
echo "    Only localhost (127.0.0.1) traffic is allowed."
echo ""
echo "To disable (for system updates):"
echo "  sudo ufw disable"
echo ""
echo "To re-enable:"
echo "  sudo ufw enable"
echo ""
