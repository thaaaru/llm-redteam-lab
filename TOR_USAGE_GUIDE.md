# Tor Integration Guide - LLM Red Team Lab

## 🧅 Overview

This lab supports **fully anonymous red team operations** through Tor with **automatic DNS leak detection**. All attacks can route through Tor's SOCKS5 proxy with built-in safeguards that **abort operations if DNS leaks are detected**.

---

## 🔐 Why Tor for Red Team Operations?

### Benefits
- ✅ **Anonymity**: Hide your real IP address
- ✅ **DNS Protection**: Prevent DNS leaks that expose queries
- ✅ **Circuit Rotation**: Change exit nodes between operations
- ✅ **Isolation**: Separate attack traffic from normal traffic
- ✅ **OpSec**: Critical for authorized penetration testing

### Security Features
- 🛡️ **Automatic DNS leak detection** before each operation
- 🛡️ **Abort on leak**: Operations stop if leaks detected
- 🛡️ **proxy_dns enabled**: All DNS queries through Tor
- 🛡️ **SOCKS5 proxy**: Port 9050 (localhost only)
- 🛡️ **Isolated circuits**: Each operation can use fresh circuit

---

## 📋 Installation

### Step 1: Install Tor and Proxychains

```bash
sudo ./setup_tor.sh
```

**This will**:
- Install Tor and proxychains4
- Configure Tor with secure settings
- Set up SOCKS5 proxy on port 9050
- Enable DNS proxying
- Start and verify Tor service
- Install DNS leak checker

**Duration**: 2-3 minutes

### Step 2: Verify Installation

```bash
# Check Tor is running
sudo systemctl status tor

# Test Tor connection
proxychains4 curl ifconfig.me

# This should show a Tor exit node IP, not your real IP
```

---

## 🔍 DNS Leak Detection

### Automatic Leak Check

Before every Tor-protected operation, the system automatically:

1. ✅ Verifies Tor is running
2. ✅ Checks real IP vs Tor IP (must be different)
3. ✅ Tests DNS resolution through Tor
4. ✅ Queries multiple leak detection services
5. ✅ Verifies proxy_dns configuration
6. ✅ **ABORTS if any leak detected**

### Manual Leak Check

```bash
./config/dns_leak_check.sh
```

**Expected output** (safe):
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔍 DNS LEAK DETECTION TEST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Tor is running

[1/5] Checking real IP address...
  Real IP: 203.0.113.42

[2/5] Checking Tor exit node IP...
  Tor IP: 185.220.101.5

[3/5] Testing DNS resolution through Tor...
  ✓ No leak detected

[4/5] Verifying DNS proxy configuration...
  ✓ proxy_dns enabled in configuration

[5/5] Performing actual DNS query test...
  ✓ DNS resolution through Tor successful

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ NO DNS LEAKS DETECTED - SAFE TO PROCEED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**If leak detected** (unsafe):
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✗ DNS LEAKS DETECTED - ABORTING FOR SECURITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DO NOT PROCEED until leaks are fixed!
```

---

## 🚀 Usage

### Method 1: Tor Wrapper (Recommended)

Use the Tor wrapper for automatic leak detection:

```bash
# Run attack through Tor with leak detection
./red-team-harness/run_with_tor.sh python red-team-harness/pyrit_scenarios/prompt_injection.py

# Run custom command
./red-team-harness/run_with_tor.sh curl http://localhost:8000/query

# Run any script
./red-team-harness/run_with_tor.sh ./red-team-harness/garak_scans/run_basic_scan.sh
```

**What it does**:
1. Checks Tor is running
2. Runs DNS leak detection (5 tests)
3. **ABORTS if leaks detected**
4. Prompts for confirmation
5. Executes command through proxychains
6. Reports success/failure

### Method 2: Direct Proxychains

For manual control:

```bash
# First: ALWAYS check for leaks
./config/dns_leak_check.sh

# If no leaks, proceed:
proxychains4 python red-team-harness/pyrit_scenarios/prompt_injection.py
```

### Method 3: Individual Attack Scripts

All attack scripts now support `--use-tor` flag:

```bash
source venv/bin/activate

# PyRIT with Tor
python red-team-harness/pyrit_scenarios/prompt_injection.py --use-tor

# Custom corpus with Tor
python red-team-harness/custom_attacks/run_corpus.py --use-tor
```

---

## 📊 Example Workflows

### Workflow 1: Full Red Team Session with Tor

```bash
# 1. Start Tor
sudo systemctl start tor

# 2. Check for DNS leaks
./config/dns_leak_check.sh

# 3. If safe, run attacks through Tor
./red-team-harness/run_with_tor.sh python red-team-harness/pyrit_scenarios/prompt_injection.py

# 4. Rotate circuit (get new exit node)
sudo systemctl restart tor
sleep 10

# 5. Run more attacks
./red-team-harness/run_with_tor.sh python red-team-harness/custom_attacks/run_corpus.py

# 6. Review evidence (not through Tor)
sqlite3 evidence/redteam.db "SELECT * FROM successful_attacks;"
```

### Workflow 2: Quick Test with Leak Verification

```bash
# All-in-one command (leak check + attack)
./red-team-harness/run_with_tor.sh curl -X POST http://localhost:8000/query \
  -H "Content-Type: application/json" \
  -d '{"query": "Test prompt"}'
```

### Workflow 3: Continuous Operations

```bash
# Create rotation script
cat > rotate_and_attack.sh << 'EOF'
#!/bin/bash
for i in {1..5}; do
  echo "=== Run $i ==="
  sudo systemctl restart tor
  sleep 15
  ./red-team-harness/run_with_tor.sh python red-team-harness/custom_attacks/run_corpus.py
done
EOF

chmod +x rotate_and_attack.sh
./rotate_and_attack.sh
```

---

## 🔧 Configuration

### Tor Configuration

Located at `/etc/tor/torrc`:

```conf
# SOCKS5 proxy
SOCKSPort 9050

# Ensure strict isolation
IsolateDestAddr 1
IsolateDestPort 1

# DNS port for DNS resolution through Tor
DNSPort 5353

# Security settings
ExcludeNodes {??}  # Exclude unknown countries
StrictNodes 1
```

### Proxychains Configuration

Located at `config/proxychains.conf`:

```conf
# CRITICAL: Prevent DNS leaks
proxy_dns

# Use Tor SOCKS5
[ProxyList]
socks5  127.0.0.1 9050
```

---

## 🛠️ Tor Management

### Start/Stop Tor

```bash
# Start Tor
sudo systemctl start tor

# Stop Tor
sudo systemctl stop tor

# Restart (get new circuit)
sudo systemctl restart tor

# Status
sudo systemctl status tor
```

### Check Tor Circuit

```bash
# View current exit node IP
proxychains4 curl ifconfig.me

# Check Tor logs
sudo journalctl -u tor -f

# View active circuits
sudo tail -f /var/log/tor/notices.log
```

### Rotate Exit Node

```bash
# Method 1: Restart Tor
sudo systemctl restart tor

# Wait for new circuit
sleep 10

# Verify new IP
proxychains4 curl ifconfig.me

# Method 2: Send NEWNYM signal (if control port enabled)
echo -e 'AUTHENTICATE ""\r\nSIGNAL NEWNYM\r\nQUIT' | nc 127.0.0.1 9051
```

---

## 🚨 Troubleshooting

### Issue: DNS Leaks Detected

**Symptoms**:
```
✗ DNS LEAK DETECTED: Real IP found in DNS query!
```

**Solutions**:

1. **Verify proxy_dns is enabled**:
   ```bash
   grep proxy_dns config/proxychains.conf
   # Should show: proxy_dns
   ```

2. **Check Tor DNS configuration**:
   ```bash
   grep DNSPort /etc/tor/torrc
   # Should show: DNSPort 5353
   ```

3. **Restart Tor**:
   ```bash
   sudo systemctl restart tor
   sleep 10
   ./config/dns_leak_check.sh
   ```

4. **Check firewall isn't blocking Tor**:
   ```bash
   sudo ufw allow out to any port 9050 proto tcp
   ```

### Issue: Tor Connection Failed

**Symptoms**:
```
✗ Tor connection test failed
```

**Solutions**:

1. **Check Tor is running**:
   ```bash
   sudo systemctl status tor
   ```

2. **View Tor logs**:
   ```bash
   sudo journalctl -u tor -n 50
   ```

3. **Test SOCKS5 proxy**:
   ```bash
   curl --socks5 127.0.0.1:9050 ifconfig.me
   ```

4. **Reinstall Tor**:
   ```bash
   sudo apt-get remove --purge tor
   sudo ./setup_tor.sh
   ```

### Issue: Proxychains Not Found

**Symptoms**:
```
proxychains4: command not found
```

**Solution**:
```bash
sudo apt-get install proxychains4
# Or re-run setup:
sudo ./setup_tor.sh
```

---

## 📈 Performance Considerations

### Speed
- Tor adds latency (typically 1-3 seconds per request)
- Circuit building takes 10-30 seconds
- Exit nodes vary in speed

### Optimization
```bash
# Use faster circuit building
echo "CircuitBuildTimeout 30" | sudo tee -a /etc/tor/torrc
sudo systemctl restart tor
```

### Recommendations
- **Short attacks**: Acceptable slowdown
- **Long scans**: Consider using Tor for initial tests, then direct for bulk
- **Evidence review**: Don't route through Tor (local database access)

---

## 🔒 Security Best Practices

### ✅ DO:
- ✅ Always run DNS leak check before operations
- ✅ Rotate circuits between major operations
- ✅ Use Tor wrapper for automatic leak detection
- ✅ Monitor Tor logs for anomalies
- ✅ Verify exit node changes after rotation

### ❌ DON'T:
- ❌ Skip DNS leak checks
- ❌ Ignore leak detection warnings
- ❌ Use Tor for local-only operations (localhost:8000)
- ❌ Disable proxy_dns
- ❌ Run attacks if leaks detected

---

## 📊 Verification Checklist

Before running Tor-protected operations:

- [ ] Tor is installed: `sudo systemctl status tor`
- [ ] Proxychains is installed: `proxychains4 --version`
- [ ] DNS leak check passes: `./config/dns_leak_check.sh`
- [ ] Real IP ≠ Tor IP
- [ ] proxy_dns enabled in config
- [ ] Tor logs show no errors: `sudo journalctl -u tor -n 20`

---

## 🎓 Understanding DNS Leaks

### What is a DNS Leak?

When you use Tor but your DNS queries go through your ISP's DNS servers, exposing:
- What websites you're querying
- Your real IP address to DNS servers
- Your browsing patterns

### How We Prevent It

1. **proxy_dns**: Routes all DNS through Tor
2. **Tor DNSPort**: Tor resolves DNS queries
3. **Leak Detection**: 5-stage verification before each operation
4. **Automatic Abort**: Stops if leaks detected

### Leak Detection Stages

1. **Real IP Check**: Determine your actual IP
2. **Tor IP Check**: Verify connection through Tor
3. **DNS Service Test**: Query leak detection services
4. **Config Verification**: Ensure proxy_dns enabled
5. **Active DNS Test**: Perform actual DNS resolution

---

## 📞 Quick Reference

| Command | Purpose |
|---------|---------|
| `sudo ./setup_tor.sh` | Install and configure Tor |
| `./config/dns_leak_check.sh` | Check for DNS leaks |
| `./red-team-harness/run_with_tor.sh <cmd>` | Run command with leak detection |
| `proxychains4 <cmd>` | Run command through Tor (manual) |
| `sudo systemctl restart tor` | Get new exit node |
| `proxychains4 curl ifconfig.me` | Check current Tor IP |

---

## 🌐 Tor + Lab Integration

### Target Application

**Note**: The target application runs on **localhost:8000**. For local testing, you don't need Tor since traffic never leaves your machine. However, for realism and training:

- Use Tor wrapper to simulate real-world OpSec
- Practice leak detection workflows
- Train team on proper procedures

### When to Use Tor

**Use Tor for**:
- ✅ Training and practice
- ✅ Simulating real operations
- ✅ Testing leak detection
- ✅ OpSec training

**Don't need Tor for**:
- ❌ Localhost-only testing (target is 127.0.0.1)
- ❌ Evidence review (SQLite access)
- ❌ Lab management commands

---

## 🚀 Advanced Usage

### Custom Tor Configuration

Edit `/etc/tor/torrc`:

```bash
sudo nano /etc/tor/torrc

# Add custom settings:
# EntryNodes {us},{uk},{de}  # Prefer specific countries
# ExitNodes {us}             # Exit through US only
# ExcludeNodes {cn},{ru}     # Avoid certain countries
```

Restart Tor:
```bash
sudo systemctl restart tor
```

### Multiple Tor Instances

Run Tor on different ports:

```bash
# /etc/tor/torrc
SOCKSPort 9050
SOCKSPort 9051
SOCKSPort 9052
```

Use specific port:
```bash
proxychains4 -f config/proxychains-9051.conf <command>
```

---

**🧅 Tor integration complete! All red team operations can now run with full anonymity and automatic DNS leak protection.**
