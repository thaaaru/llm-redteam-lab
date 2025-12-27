#!/bin/bash
set -e

# ============================================================
# LLM Red Team Lab - Installation Script
# ⚠️  FOR DEFENSIVE SECURITY RESEARCH ONLY ⚠️
# ============================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  LLM RED TEAM LAB - INSTALLATION"
echo "  ⚠️  DO NOT USE REAL DATA OR CREDENTIALS ⚠️"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check for root/sudo
if [ "$EUID" -eq 0 ]; then
    echo "❌ Do not run as root. Run as regular user with sudo access."
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    echo "❌ Cannot detect OS. This script is designed for Ubuntu 22.04"
    exit 1
fi

if [ "$OS" != "ubuntu" ]; then
    echo "⚠️  Warning: This script is tested on Ubuntu 22.04. Detected: $OS"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "[1/8] Updating system packages..."
sudo apt-get update -qq

echo "[2/8] Installing system dependencies..."
sudo apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3-pip \
    curl \
    wget \
    git \
    sqlite3 \
    ufw \
    jq \
    > /dev/null

# Verify Python 3.11
if ! command -v python3.11 &> /dev/null; then
    echo "❌ Python 3.11 not found. Installing from deadsnakes PPA..."
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt-get update
    sudo apt-get install -y python3.11 python3.11-venv python3.11-dev
fi

echo "[3/8] Installing Ollama..."
if ! command -v ollama &> /dev/null; then
    curl -fsSL https://ollama.ai/install.sh | sh
else
    echo "  ✓ Ollama already installed"
fi

echo "[4/8] Creating Python virtual environment..."
python3.11 -m venv venv
source venv/bin/activate

echo "[5/8] Installing Python dependencies..."
pip install --upgrade pip setuptools wheel > /dev/null
pip install -r requirements.txt

echo "[6/8] Installing red-team harness dependencies..."
pip install -r red-team-harness/requirements.txt

echo "[7/8] Installing target app dependencies..."
pip install -r target-app/requirements.txt

echo "[8/8] Initializing logging database..."
sqlite3 evidence/redteam.db < logging/schema.sql

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Installation Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. [RECOMMENDED] Setup Tor for anonymous operations:"
echo "     sudo ./setup_tor.sh"
echo ""
echo "  2. [OPTIONAL] Run network isolation setup:"
echo "     sudo ./setup_network_isolation.sh"
echo ""
echo "  3. Pull the uncensored LLaMA model:"
echo "     ./llm-runtime/pull_model.sh"
echo ""
echo "  4. Start the lab:"
echo "     ./start_lab.sh"
echo ""
echo "⚠️  SECURITY REMINDER:"
echo "    • Install Tor for DNS leak protection (recommended)"
echo "    • All attacks can route through Tor with automatic leak detection"
echo "    • Use synthetic data only - no real secrets or credentials"
echo ""
