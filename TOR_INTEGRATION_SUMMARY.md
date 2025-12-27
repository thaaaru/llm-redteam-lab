# 🧅 Tor Integration - Complete Summary

## What Was Added

Your LLM Red Team Lab now has **full Tor integration with automatic DNS leak detection**. All attacks can route through Tor's anonymous network with built-in safeguards.

---

## 🎯 Key Features

### 1. **Automatic DNS Leak Detection**
- ✅ 5-stage verification before each operation
- ✅ Tests real IP vs Tor IP
- ✅ Queries leak detection services
- ✅ Verifies proxy_dns configuration
- ✅ **ABORTS operations if leaks detected**

### 2. **Tor SOCKS5 Proxy**
- ✅ Port 9050 (localhost only)
- ✅ DNS proxying through Tor (port 5353)
- ✅ Isolated circuits per operation
- ✅ Circuit rotation support

### 3. **Proxychains Integration**
- ✅ Configured for DNS leak prevention
- ✅ Dynamic chain for reliability
- ✅ Quiet mode for clean output

### 4. **Tor Wrapper Script**
- ✅ Automatic leak detection before execution
- ✅ User confirmation prompts
- ✅ Clean success/failure reporting
- ✅ Works with all attack scripts

---

## 📦 New Files Added

### Configuration Files
1. **config/proxychains.conf** (25 lines)
   - Proxychains configuration
   - proxy_dns enabled (critical for leak prevention)
   - SOCKS5 proxy to Tor port 9050

2. **config/dns_leak_check.sh** (180 lines)
   - 5-stage DNS leak detection
   - Multiple leak detection service tests
   - Automatic abort on leak detection
   - Color-coded output

### Setup Scripts
3. **setup_tor.sh** (120 lines)
   - Tor installation
   - Proxychains installation
   - Tor configuration (/etc/tor/torrc)
   - Service startup and verification
   - Connection testing

### Wrapper Scripts
4. **red-team-harness/run_with_tor.sh** (100 lines)
   - Tor-protected command wrapper
   - Automatic DNS leak check
   - User confirmation prompts
   - Proxychains execution

### Documentation
5. **TOR_USAGE_GUIDE.md** (600+ lines)
   - Complete Tor usage guide
   - DNS leak explanation
   - Troubleshooting guide
   - Example workflows
   - Security best practices

6. **TOR_INTEGRATION_SUMMARY.md** (this file)
   - Quick reference
   - Integration overview

---

## 🚀 Quick Start

### Installation (One-Time)

```bash
# 1. Install Tor and proxychains
sudo ./setup_tor.sh

# 2. Verify installation
./config/dns_leak_check.sh
```

**Duration**: 2-3 minutes

### Usage

#### Option 1: Tor Wrapper (Recommended)
```bash
# Automatic leak detection + execution
./red-team-harness/run_with_tor.sh python red-team-harness/pyrit_scenarios/prompt_injection.py
```

#### Option 2: Manual with Leak Check
```bash
# 1. Check for leaks first
./config/dns_leak_check.sh

# 2. If safe, use proxychains
proxychains4 python red-team-harness/pyrit_scenarios/prompt_injection.py
```

---

## 🔍 DNS Leak Detection Process

### 5-Stage Verification

When you run `./config/dns_leak_check.sh`:

```
[1/5] Checking real IP address...
  Real IP: 203.0.113.42

[2/5] Checking Tor exit node IP...
  Tor IP: 185.220.101.5  ✓ Different from real IP

[3/5] Testing DNS resolution through Tor...
  ✓ No leak detected from dnsleaktest.com
  ✓ No leak detected from ipleak.net

[4/5] Verifying DNS proxy configuration...
  ✓ proxy_dns enabled in configuration

[5/5] Performing actual DNS query test...
  ✓ DNS resolution through Tor successful

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ NO DNS LEAKS DETECTED - SAFE TO PROCEED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### If Leak Detected

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✗ DNS LEAKS DETECTED - ABORTING FOR SECURITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DO NOT PROCEED until leaks are fixed!
```

**Operations automatically abort** - no manual intervention needed.

---

## 📊 Example Workflows

### Workflow 1: Single Attack with Tor

```bash
# One command - automatic leak check + execution
./red-team-harness/run_with_tor.sh python red-team-harness/pyrit_scenarios/prompt_injection.py
```

### Workflow 2: Multiple Attacks with Circuit Rotation

```bash
# Attack 1
./red-team-harness/run_with_tor.sh python red-team-harness/pyrit_scenarios/prompt_injection.py

# Rotate to new exit node
sudo systemctl restart tor
sleep 10

# Attack 2 (through different Tor exit)
./red-team-harness/run_with_tor.sh python red-team-harness/pyrit_scenarios/data_exfiltration.py
```

### Workflow 3: Full Red Team Session

```bash
# 1. Start Tor
sudo systemctl start tor

# 2. Verify no leaks
./config/dns_leak_check.sh

# 3. Run comprehensive attack suite
./red-team-harness/run_with_tor.sh python red-team-harness/custom_attacks/run_corpus.py

# 4. Review evidence (not through Tor - local database)
sqlite3 evidence/redteam.db "SELECT * FROM successful_attacks;"
```

---

## 🔐 Security Guarantees

### What's Protected

✅ **Your Real IP**: Hidden by Tor exit nodes
✅ **DNS Queries**: Proxied through Tor, not exposed to ISP
✅ **Attack Traffic**: Routes through Tor network
✅ **Identity**: Anonymous to target systems

### Automatic Safeguards

✅ **Pre-flight checks**: DNS leak detection before operations
✅ **Abort on leak**: Operations stop if DNS leaks found
✅ **Configuration validation**: Ensures proxy_dns enabled
✅ **Multi-service testing**: Checks multiple leak detection APIs

### What's NOT Protected (By Design)

❌ **Localhost traffic**: Target app is on 127.0.0.1 (doesn't need Tor)
❌ **Evidence review**: SQLite queries are local
❌ **Lab management**: Setup commands don't need anonymization

---

## 🛠️ Tor Management

### Common Commands

```bash
# Start Tor
sudo systemctl start tor

# Stop Tor
sudo systemctl stop tor

# Restart (get new circuit/exit node)
sudo systemctl restart tor

# Check status
sudo systemctl status tor

# View logs
sudo journalctl -u tor -f

# Check current Tor IP
proxychains4 curl ifconfig.me
```

### Circuit Rotation

```bash
# Method 1: Restart Tor
sudo systemctl restart tor
sleep 10
proxychains4 curl ifconfig.me  # Verify new IP

# Method 2: Signal NEWNYM
echo -e 'AUTHENTICATE ""\r\nSIGNAL NEWNYM\r\nQUIT' | nc 127.0.0.1 9051
```

---

## 📋 Installation Checklist

After running `sudo ./setup_tor.sh`:

- [ ] Tor installed: `tor --version`
- [ ] Proxychains installed: `proxychains4 --version`
- [ ] Tor running: `sudo systemctl status tor`
- [ ] Config in place: `ls /etc/tor/torrc`
- [ ] Proxychains config: `ls config/proxychains.conf`
- [ ] DNS leak checker: `ls config/dns_leak_check.sh`
- [ ] Tor wrapper: `ls red-team-harness/run_with_tor.sh`
- [ ] No DNS leaks: `./config/dns_leak_check.sh` passes

---

## 🔧 Configuration Files

### Tor Config: /etc/tor/torrc

```conf
# SOCKS5 proxy
SOCKSPort 9050

# DNS resolution through Tor
DNSPort 5353

# Isolation (each connection through different circuit)
IsolateDestAddr 1
IsolateDestPort 1

# Security
ExcludeNodes {??}  # Exclude unknown countries
StrictNodes 1
```

### Proxychains Config: config/proxychains.conf

```conf
# CRITICAL: Prevent DNS leaks
proxy_dns

# Dynamic chain (skip dead proxies)
dynamic_chain

# Timeouts
tcp_read_time_out 15000
tcp_connect_time_out 8000

# Proxy list
[ProxyList]
socks5  127.0.0.1 9050
```

---

## 🚨 Troubleshooting

### Problem: DNS Leaks Detected

**Solution**:
```bash
# 1. Check proxy_dns
grep proxy_dns config/proxychains.conf

# 2. Restart Tor
sudo systemctl restart tor
sleep 10

# 3. Re-test
./config/dns_leak_check.sh
```

### Problem: Tor Won't Start

**Solution**:
```bash
# Check logs
sudo journalctl -u tor -n 50

# Reinstall
sudo apt-get remove --purge tor
sudo ./setup_tor.sh
```

### Problem: Slow Performance

**Expected**: Tor adds 1-3 seconds latency per request

**Optimization**:
```bash
# Faster circuit building
echo "CircuitBuildTimeout 30" | sudo tee -a /etc/tor/torrc
sudo systemctl restart tor
```

---

## 📚 Documentation

### Complete Guides

1. **TOR_USAGE_GUIDE.md** - Comprehensive 600+ line guide
   - Installation details
   - DNS leak detection explained
   - All usage scenarios
   - Troubleshooting
   - Security best practices

2. **README.md** - Updated with Tor information

3. **QUICK_START.md** - Updated with Tor quickstart

---

## 🎓 Why This Matters

### For Red Team Operations

- **Anonymity**: Hide your testing infrastructure
- **OpSec**: Prevent target from identifying your real location
- **Isolation**: Separate attack traffic from normal operations
- **Training**: Practice proper OpSec procedures

### For Defensive Research

- **Realistic**: Simulates real-world attacker behavior
- **Safe**: DNS leak protection prevents exposure
- **Auditable**: All operations logged (even through Tor)
- **Compliant**: Demonstrates proper security practices

---

## 📊 Performance Impact

### Speed
- **Without Tor**: ~100-500ms per request
- **With Tor**: ~1-3 seconds per request
- **Circuit building**: 10-30 seconds (one-time per rotation)

### Recommendations
- ✅ Use Tor for initial reconnaissance
- ✅ Use Tor for sensitive operations
- ✅ Use Tor for training/practice
- ❌ Skip Tor for bulk localhost testing
- ❌ Skip Tor for evidence review

---

## ✅ Integration Complete

Your lab now has:

✅ **Full Tor support** with SOCKS5 proxy
✅ **DNS leak detection** (5-stage verification)
✅ **Automatic abort** on leak detection
✅ **Proxychains integration** with leak prevention
✅ **Tor wrapper script** for easy usage
✅ **Complete documentation** (600+ lines)
✅ **Security hardened** configuration
✅ **Circuit rotation** support

---

## 🚀 Next Steps

1. **Install Tor**:
   ```bash
   sudo ./setup_tor.sh
   ```

2. **Verify No Leaks**:
   ```bash
   ./config/dns_leak_check.sh
   ```

3. **Run First Tor-Protected Attack**:
   ```bash
   ./red-team-harness/run_with_tor.sh python red-team-harness/pyrit_scenarios/prompt_injection.py
   ```

4. **Read Full Guide**:
   ```bash
   cat TOR_USAGE_GUIDE.md
   ```

---

## 📞 Quick Reference

| Task | Command |
|------|---------|
| Install Tor | `sudo ./setup_tor.sh` |
| Check for leaks | `./config/dns_leak_check.sh` |
| Run with Tor | `./red-team-harness/run_with_tor.sh <cmd>` |
| Manual Tor | `proxychains4 <cmd>` |
| Rotate circuit | `sudo systemctl restart tor` |
| Check Tor IP | `proxychains4 curl ifconfig.me` |
| Tor status | `sudo systemctl status tor` |

---

**🧅 Tor integration complete! All operations can now run anonymously with automatic DNS leak protection.**
