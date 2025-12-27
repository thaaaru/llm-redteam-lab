# 🧅 LLM Red Team Lab with Tor Integration - Final Bundle

## 📦 Bundle Information

**Package**: `llm-redteam-lab-with-tor.tar.gz`
**Size**: 64 KB (compressed)
**SHA-256**: `25414f33df788747a407091136f66e37336d3dc57b16ee2a1110301fe77bcd68`
**Files**: 52 files (up from 47 in original bundle)

---

## 🆕 What's New - Tor Integration

This updated bundle includes **complete Tor integration with automatic DNS leak detection**:

### New Features
✅ **Tor/SOCKS5/Proxychains** support
✅ **Automatic DNS leak detection** (5-stage verification)
✅ **Auto-abort on leaks** - Operations stop if DNS leaks detected
✅ **Tor wrapper script** - Easy execution through Tor
✅ **Circuit rotation** support
✅ **600+ lines of Tor documentation**

### New Files (5 additions)
1. `config/proxychains.conf` - Proxychains configuration
2. `config/dns_leak_check.sh` - DNS leak detector (180 lines)
3. `setup_tor.sh` - Tor installation script (120 lines)
4. `red-team-harness/run_with_tor.sh` - Tor wrapper (100 lines)
5. `TOR_USAGE_GUIDE.md` - Complete guide (600+ lines)
6. `TOR_INTEGRATION_SUMMARY.md` - Quick reference

---

## 🚀 Quick Start (Complete Workflow)

### Step 1: Extract Bundle
```bash
tar -xzf llm-redteam-lab-with-tor.tar.gz
cd llm-redteam-lab
```

### Step 2: Verify Checksum (Optional)
```bash
sha256sum /path/to/llm-redteam-lab-with-tor.tar.gz
# Expected: 25414f33df788747a407091136f66e37336d3dc57b16ee2a1110301fe77bcd68
```

### Step 3: Make Scripts Executable
```bash
chmod +x *.sh
chmod +x llm-runtime/*.sh
chmod +x target-app/*.sh
chmod +x config/*.sh
chmod +x red-team-harness/**/*.sh
chmod +x red-team-harness/**/*.py
chmod +x logging/*.py
```

### Step 4: Base Installation
```bash
./install.sh
# Duration: 5-10 minutes
```

### Step 5: Install Tor (RECOMMENDED)
```bash
sudo ./setup_tor.sh
# Duration: 2-3 minutes
```

**This installs and configures**:
- Tor service (SOCKS5 proxy on port 9050)
- Proxychains with DNS leak prevention
- DNS leak detection scripts
- Tor wrapper for automatic leak checking

### Step 6: Download Model
```bash
./llm-runtime/pull_model.sh
# Duration: 10-30 minutes (~4-8GB download)
```

### Step 7: Start Lab
```bash
./start_lab.sh
```

### Step 8: Verify Tor (If Installed)
```bash
./config/dns_leak_check.sh
```

**Expected output**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ NO DNS LEAKS DETECTED - SAFE TO PROCEED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 9: Run First Attack

#### Option A: With Tor (Recommended for Practice)
```bash
./red-team-harness/run_with_tor.sh python red-team-harness/pyrit_scenarios/prompt_injection.py
```

#### Option B: Without Tor (Localhost Testing)
```bash
source venv/bin/activate
python red-team-harness/pyrit_scenarios/prompt_injection.py
```

---

## 📋 Complete Installation Checklist

### Base Installation
- [ ] Bundle extracted
- [ ] Scripts made executable (`chmod +x`)
- [ ] Base install completed (`./install.sh`)
- [ ] Virtual environment created
- [ ] Model downloaded (`./llm-runtime/pull_model.sh`)
- [ ] Lab starts successfully (`./start_lab.sh`)
- [ ] Health checks pass

### Tor Installation (Optional but Recommended)
- [ ] Tor installed (`sudo ./setup_tor.sh`)
- [ ] Tor service running (`sudo systemctl status tor`)
- [ ] Proxychains installed (`proxychains4 --version`)
- [ ] DNS leak check passes (`./config/dns_leak_check.sh`)
- [ ] Tor IP different from real IP
- [ ] proxy_dns enabled in config

---

## 🔍 DNS Leak Detection Explained

### What is a DNS Leak?

When using Tor, a DNS leak occurs if your DNS queries bypass Tor and go directly through your ISP's DNS servers. This exposes:
- Your real IP address
- What domains you're querying
- Your browsing/attack patterns

### How We Prevent It

1. **proxy_dns** in proxychains config - Routes DNS through Tor
2. **Tor DNSPort 5353** - Tor resolves DNS queries
3. **5-stage verification** - Comprehensive leak detection
4. **Automatic abort** - Stops operations if leaks found

### 5-Stage Leak Detection

```bash
./config/dns_leak_check.sh
```

**Tests performed**:
1. ✅ Check real IP address
2. ✅ Check Tor exit node IP (must be different)
3. ✅ Query leak detection services through Tor
4. ✅ Verify proxy_dns configuration
5. ✅ Perform actual DNS resolution test

**Result**: ABORT if any stage fails ❌

---

## 🎯 Usage Examples

### Example 1: Single Attack with Tor Protection

```bash
# Automatic leak detection + execution
./red-team-harness/run_with_tor.sh python red-team-harness/pyrit_scenarios/prompt_injection.py
```

**What happens**:
1. Checks Tor is running
2. Runs DNS leak detection (5 tests)
3. Aborts if leaks detected
4. Prompts for confirmation
5. Executes through proxychains
6. Reports success/failure

### Example 2: Manual Tor Usage

```bash
# 1. Check for leaks first (ALWAYS!)
./config/dns_leak_check.sh

# 2. If safe, use proxychains
proxychains4 python red-team-harness/custom_attacks/run_corpus.py
```

### Example 3: Circuit Rotation

```bash
# Run attack through exit node A
./red-team-harness/run_with_tor.sh python red-team-harness/pyrit_scenarios/data_exfiltration.py

# Rotate to exit node B
sudo systemctl restart tor
sleep 10

# Run attack through exit node B
./red-team-harness/run_with_tor.sh python red-team-harness/pyrit_scenarios/policy_bypass.py
```

### Example 4: Verify Tor Identity

```bash
# Check current Tor exit IP
proxychains4 curl ifconfig.me

# Rotate circuit
sudo systemctl restart tor
sleep 10

# Check new exit IP (should be different)
proxychains4 curl ifconfig.me
```

---

## 📚 Documentation Files

### Read These First
1. **BUNDLE_README.txt** - Quick overview
2. **TOR_INTEGRATION_SUMMARY.md** - Tor feature summary
3. **QUICK_START.md** - 5-minute quickstart

### Complete Guides
4. **TOR_USAGE_GUIDE.md** - 600+ line Tor guide (comprehensive!)
5. **INSTALLATION_INSTRUCTIONS.md** - Detailed setup
6. **README.md** - Complete usage guide (updated with Tor)
7. **examples/sample_transcript.md** - Example session

### Reference
8. **DEPLOYMENT_GUIDE.md** - Deployment options
9. **IMPLEMENTATION_COMPLETE.md** - Technical details

---

## 🔐 Security Features Summary

### DNS Leak Prevention
✅ **proxy_dns enabled** - All DNS through Tor
✅ **5-stage verification** - Comprehensive leak detection
✅ **Automatic abort** - Stops if leaks found
✅ **Multiple test services** - Cross-verification

### Anonymity
✅ **Tor SOCKS5** - Hide real IP
✅ **Circuit isolation** - Separate connections
✅ **Exit node rotation** - Change identity
✅ **DNS proxying** - Prevent query exposure

### Safeguards
✅ **Pre-flight checks** - Leak detection before operations
✅ **Configuration validation** - Ensures proper setup
✅ **User confirmation** - Explicit approval required
✅ **Audit trail** - All operations logged

---

## 🔧 Tor Management Commands

```bash
# Start/Stop/Restart
sudo systemctl start tor
sudo systemctl stop tor
sudo systemctl restart tor

# Status and Logs
sudo systemctl status tor
sudo journalctl -u tor -f

# Check Current IP
proxychains4 curl ifconfig.me

# DNS Leak Check
./config/dns_leak_check.sh

# Rotate Circuit (get new exit node)
sudo systemctl restart tor
sleep 10
proxychains4 curl ifconfig.me  # Verify new IP
```

---

## 🚨 Important Notes

### When to Use Tor

**Use Tor for**:
- ✅ Training and OpSec practice
- ✅ Simulating real-world operations
- ✅ Anonymous reconnaissance
- ✅ Compliance with testing protocols

**Tor NOT needed for**:
- ❌ Localhost testing (target is 127.0.0.1)
- ❌ Evidence review (SQLite is local)
- ❌ Lab management commands

### Performance Impact

- **Without Tor**: ~100-500ms per request
- **With Tor**: ~1-3 seconds per request
- **Circuit building**: 10-30 seconds (one-time)

**Recommendation**: Use Tor for realism and training, skip for bulk localhost testing.

---

## 📊 What You Get

### Original Features
✅ Ollama LLM Runtime
✅ Vulnerable RAG Application
✅ PyRIT Attack Scenarios (5 types)
✅ Garak Vulnerability Scanner
✅ Custom Attack Corpus (27+ prompts)
✅ Evidence Collection (SQLite + JSONL)
✅ Attack Replay System
✅ 2,000+ lines of documentation

### NEW: Tor Integration
✅ Tor SOCKS5 Proxy
✅ Proxychains Configuration
✅ DNS Leak Detection (5 stages)
✅ Automatic Abort on Leaks
✅ Tor Wrapper Script
✅ Circuit Rotation Support
✅ 600+ lines Tor documentation

---

## 🛠️ Troubleshooting

### DNS Leaks Detected

```bash
# 1. Verify proxy_dns
grep proxy_dns config/proxychains.conf

# 2. Check Tor config
sudo grep DNSPort /etc/tor/torrc

# 3. Restart Tor
sudo systemctl restart tor
sleep 10

# 4. Re-test
./config/dns_leak_check.sh
```

### Tor Won't Start

```bash
# Check logs
sudo journalctl -u tor -n 50

# Reinstall
sudo apt-get remove --purge tor
sudo ./setup_tor.sh
```

### Proxychains Not Found

```bash
sudo apt-get install proxychains4
# Or re-run:
sudo ./setup_tor.sh
```

---

## ✅ Verification Steps

After installation, verify everything works:

```bash
# 1. Check base lab
./start_lab.sh
./llm-runtime/health_check.sh
curl http://localhost:8000/health

# 2. Check Tor (if installed)
sudo systemctl status tor
proxychains4 curl ifconfig.me  # Should show Tor IP

# 3. Check for DNS leaks
./config/dns_leak_check.sh     # Should pass all tests

# 4. Run test attack
./red-team-harness/run_with_tor.sh curl http://localhost:8000/health
```

---

## 📞 Quick Reference

| Command | Purpose |
|---------|---------|
| `./install.sh` | Base installation |
| `sudo ./setup_tor.sh` | Install Tor |
| `./llm-runtime/pull_model.sh` | Download model |
| `./start_lab.sh` | Start lab |
| `./config/dns_leak_check.sh` | Check for DNS leaks |
| `./red-team-harness/run_with_tor.sh <cmd>` | Run with Tor |
| `proxychains4 <cmd>` | Manual Tor usage |
| `sudo systemctl restart tor` | Rotate circuit |

---

## 🎓 Learning Path

### Day 1: Setup
1. Extract bundle
2. Run `./install.sh`
3. Run `sudo ./setup_tor.sh`
4. Download model
5. Verify installation

### Day 2: Tor Testing
1. Read `TOR_USAGE_GUIDE.md`
2. Run DNS leak checks
3. Test Tor connections
4. Practice circuit rotation

### Day 3: Red Team Operations
1. Run attacks without Tor (baseline)
2. Run same attacks with Tor (compare)
3. Practice leak detection
4. Review evidence

---

## 📦 Bundle Contents Summary

**Total Files**: 52
**Total Size**: 64 KB compressed, ~6,000 lines when extracted
**New in This Bundle**: Tor integration (5 files, 1,000+ lines)

### Directory Structure
```
llm-redteam-lab/
├── config/
│   ├── proxychains.conf           [NEW]
│   ├── dns_leak_check.sh          [NEW]
│   ├── ollama.env
│   ├── pyrit_config.yaml
│   └── garak_config.yaml
├── red-team-harness/
│   ├── run_with_tor.sh            [NEW]
│   ├── [attack scenarios]
├── setup_tor.sh                   [NEW]
├── TOR_USAGE_GUIDE.md             [NEW]
├── TOR_INTEGRATION_SUMMARY.md     [NEW]
└── [all other files from original bundle]
```

---

## 🚀 Ready to Deploy!

**Bundle Location**:
`/Users/tharaka/claude_space/Uncensored-LLaMA/llm-redteam-lab-with-tor.tar.gz`

**Next Steps**:
1. Transfer bundle to target system
2. Extract: `tar -xzf llm-redteam-lab-with-tor.tar.gz`
3. Install: `./install.sh && sudo ./setup_tor.sh`
4. Verify: `./config/dns_leak_check.sh`
5. Attack: `./red-team-harness/run_with_tor.sh <command>`

---

**🧅 Complete LLM Red Team Lab with Tor integration, DNS leak protection, and automatic abort on leaks!**

**Total Features**: Everything from original bundle + Full Tor anonymity with leak detection
