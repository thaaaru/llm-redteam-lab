# LLM Red Team Lab - Installation Instructions

## 📦 Bundle Information

**Package**: `llm-redteam-lab.tar.gz`
**Size**: 48 KB (compressed)
**Files**: 47 files + directories
**SHA-256**: `5af911fb8adf48b0044f67b463d4ef52cd57114a51257efbb2bbc9dcd8b7b65b`

---

## ⚠️ CRITICAL WARNING

**THIS IS FOR DEFENSIVE SECURITY RESEARCH ONLY**

- ✅ Authorized security testing
- ✅ Red team training
- ✅ Vulnerability research
- ❌ NO production systems
- ❌ NO real credentials
- ❌ NO malicious use

---

## 📋 Prerequisites

### System Requirements
- **OS**: Ubuntu 22.04 LTS (or compatible Linux)
- **RAM**: 8GB minimum (16GB recommended)
- **Disk**: 10GB free space
- **CPU**: 4+ cores recommended
- **Network**: Internet access for initial setup

### Required Privileges
- Regular user account
- `sudo` access for:
  - Installing system packages
  - Network isolation setup (optional)

---

## 🚀 Installation Steps

### Step 1: Extract the Bundle

```bash
# Create installation directory
mkdir -p ~/llm-redteam-lab
cd ~/llm-redteam-lab

# Extract the bundle
tar -xzf /path/to/llm-redteam-lab.tar.gz

# Verify extraction
ls -la
```

**Expected output**: You should see directories: `config/`, `llm-runtime/`, `target-app/`, `red-team-harness/`, `logging/`, etc.

### Step 2: Verify Checksum (Optional but Recommended)

```bash
# Check SHA-256 matches
sha256sum /path/to/llm-redteam-lab.tar.gz
# Should output: 5af911fb8adf48b0044f67b463d4ef52cd57114a51257efbb2bbc9dcd8b7b65b
```

### Step 3: Make Scripts Executable

```bash
chmod +x *.sh
chmod +x llm-runtime/*.sh
chmod +x target-app/*.sh
chmod +x red-team-harness/garak_scans/*.sh
chmod +x examples/*.sh
chmod +x red-team-harness/pyrit_scenarios/*.py
chmod +x red-team-harness/custom_attacks/*.py
chmod +x logging/*.py
```

### Step 4: Run Installation Script

```bash
./install.sh
```

**This will**:
- Update system packages
- Install Python 3.11
- Install Ollama
- Create virtual environment
- Install all Python dependencies
- Initialize evidence database

**Duration**: ~5-10 minutes (depending on internet speed)

**Expected output**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Installation Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 5: Set Up Network Isolation (OPTIONAL but RECOMMENDED)

```bash
sudo ./setup_network_isolation.sh
```

**This will**:
- Enable UFW firewall
- Block all outbound internet traffic
- Allow localhost-only communication
- Ensure air-gapped operation

**Note**: You can skip this for initial testing but it's recommended for production red team use.

### Step 6: Download LLM Model

```bash
./llm-runtime/pull_model.sh
```

**This will**:
- Download `llama2-uncensored:7b` (~4-8GB)
- Verify model installation

**Duration**: ~10-30 minutes (depending on internet speed)

**Alternative models**:
```bash
# Larger, better quality (13B model, ~8GB)
./llm-runtime/pull_model.sh wizard-vicuna-uncensored:13b

# Alternative uncensored variant (8B model, ~5GB)
./llm-runtime/pull_model.sh dolphin-llama3:8b
```

### Step 7: Start the Lab

```bash
./start_lab.sh
```

**Expected output**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Lab is Running
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Services:
  • Ollama API:    http://localhost:11434
  • Target App:    http://localhost:8000
  • API Docs:      http://localhost:8000/docs

Ready to run red team attacks!
```

### Step 8: Verify Installation

```bash
# Activate virtual environment
source venv/bin/activate

# Check Ollama health
./llm-runtime/health_check.sh

# Test target application
curl http://localhost:8000/health
```

---

## ✅ Quick Verification Tests

### Test 1: Health Checks
```bash
# Should show "operational"
curl http://localhost:8000/health | jq

# Should list llama2-uncensored
curl http://localhost:11434/api/tags | jq
```

### Test 2: Simple Attack
```bash
curl -X POST http://localhost:8000/query \
  -H "Content-Type: application/json" \
  -d '{"query": "Hello, what can you help with?"}' | jq
```

**Expected**: You should get a JSON response with a `response` field containing the model's answer.

### Test 3: Run Example Workflow
```bash
./examples/example_run.sh
```

**Duration**: ~5 minutes
**What it does**: Runs a complete attack workflow and generates evidence

---

## 📁 Directory Structure After Installation

```
llm-redteam-lab/
├── venv/                          # Python virtual environment (created)
├── evidence/
│   ├── redteam.db                 # SQLite database (created)
│   └── attacks.jsonl              # JSONL logs (created after tests)
│
├── config/                        # Configuration files
├── llm-runtime/                   # Ollama management scripts
├── target-app/                    # Vulnerable RAG application
├── red-team-harness/              # Attack tools and scenarios
├── logging/                       # Evidence collection system
└── examples/                      # Usage examples
```

---

## 🎯 First Attack Tutorial

### 1. Start the Lab (if not already running)
```bash
./start_lab.sh
```

### 2. Activate Python Environment
```bash
source venv/bin/activate
```

### 3. Run Prompt Injection Tests
```bash
python red-team-harness/pyrit_scenarios/prompt_injection.py
```

**Duration**: ~2-3 minutes
**What it does**: Runs 20 prompt injection tests and logs results

### 4. Review Results
```bash
# View in database
sqlite3 evidence/redteam.db "SELECT * FROM successful_attacks LIMIT 5;"

# View summary
sqlite3 evidence/redteam.db << 'EOF'
SELECT
  attack_type,
  COUNT(*) as total,
  SUM(CASE WHEN success_indicator THEN 1 ELSE 0 END) as successful
FROM attack_logs
GROUP BY attack_type;
EOF
```

---

## 🔧 Troubleshooting Installation

### Issue: "Ollama installation failed"
**Solution**:
```bash
# Install manually
curl -fsSL https://ollama.ai/install.sh | sh

# Verify
ollama --version
```

### Issue: "Python 3.11 not found"
**Solution**:
```bash
# Add deadsnakes PPA
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install python3.11 python3.11-venv python3.11-dev
```

### Issue: "Permission denied" on scripts
**Solution**:
```bash
chmod +x *.sh llm-runtime/*.sh target-app/*.sh red-team-harness/**/*.sh
```

### Issue: "Port 8000 already in use"
**Solution**:
```bash
# Find process using port 8000
sudo lsof -i :8000

# Kill it (replace PID with actual PID)
kill <PID>

# Or change port in target-app/app.py and target-app/run.sh
```

### Issue: "Model download is slow/stuck"
**Solution**:
```bash
# Download directly with Ollama
ollama pull llama2-uncensored:7b

# Or use a smaller model for testing
ollama pull llama2:7b  # Censored version, smaller download
```

### Issue: "Virtual environment activation fails"
**Solution**:
```bash
# Recreate venv
rm -rf venv
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## 📚 What to Do After Installation

### 1. Read the Docs
```bash
# Quick start guide
cat QUICK_START.md

# Full documentation
cat README.md

# See example session
cat examples/sample_transcript.md
```

### 2. Run Example Workflow
```bash
./examples/example_run.sh
```

### 3. Try Manual Attacks
```bash
# Activate environment
source venv/bin/activate

# Run different attack scenarios
python red-team-harness/pyrit_scenarios/data_exfiltration.py
python red-team-harness/pyrit_scenarios/policy_bypass.py
python red-team-harness/custom_attacks/run_corpus.py
```

### 4. Explore Evidence
```bash
# Open SQLite database
sqlite3 evidence/redteam.db

# Query successful attacks
SELECT * FROM successful_attacks;

# View findings
SELECT * FROM high_severity_findings;

# Exit
.quit
```

### 5. Customize Attacks
```bash
# Edit attack corpus
nano red-team-harness/custom_attacks/attack_corpus.json

# Add your own prompts
# Run custom corpus
python red-team-harness/custom_attacks/run_corpus.py
```

---

## 🛡️ Security Considerations

### Network Isolation
After setup, you can run **completely offline**:
1. Download the model while online
2. Enable network isolation: `sudo ./setup_network_isolation.sh`
3. Lab now runs air-gapped

### Data Privacy
- **All data is synthetic** (FAKE_* credentials, fictional employees)
- **Safe to share** evidence for research
- **No real PII** ever used

### Firewall Rules
If you enabled network isolation:
```bash
# Check status
sudo ufw status

# Temporarily disable (for system updates)
sudo ufw disable

# Re-enable
sudo ufw enable
```

---

## 🔄 Updating and Maintenance

### Reset Lab to Clean State
```bash
./reset_lab.sh
```
**This will**: Backup evidence, clear logs, reinitialize database

### Update Model
```bash
ollama pull llama2-uncensored:7b
```

### Update Dependencies
```bash
source venv/bin/activate
pip install --upgrade -r requirements.txt
```

---

## 📊 Performance Expectations

### Resource Usage
- **RAM**: 4-6GB (with model loaded)
- **CPU**: Moderate during inference
- **Disk**: ~8GB for model + ~100MB for evidence

### Attack Speed
- **Single attack**: 2-5 seconds
- **20 prompt injections**: 2-3 minutes
- **Full corpus (27 attacks)**: 3-5 minutes
- **Garak full scan**: 30+ minutes

---

## 🆘 Support and Help

### Documentation Files
- `README.md` - Complete guide
- `QUICK_START.md` - 5-minute start
- `IMPLEMENTATION_COMPLETE.md` - Technical details
- `examples/sample_transcript.md` - Example session

### Logs to Check
- `/tmp/ollama.log` - Ollama service logs
- `evidence/redteam.db` - Attack evidence
- `evidence/attacks.jsonl` - Streaming logs

### Health Check Commands
```bash
./llm-runtime/health_check.sh        # Check Ollama
curl http://localhost:8000/health    # Check target app
ollama list                          # List models
ps aux | grep ollama                 # Check Ollama process
ps aux | grep uvicorn                # Check target app process
```

---

## ✅ Installation Checklist

- [ ] Extract bundle
- [ ] Verify checksum (optional)
- [ ] Make scripts executable
- [ ] Run `./install.sh`
- [ ] Set up network isolation (optional)
- [ ] Download model with `pull_model.sh`
- [ ] Start lab with `./start_lab.sh`
- [ ] Run health checks
- [ ] Execute first attack
- [ ] Review evidence

---

## 🎓 Learning Path

1. ✅ **Install** (follow steps above)
2. ✅ **Read** `QUICK_START.md`
3. ✅ **Run** `examples/example_run.sh`
4. ✅ **Study** `examples/sample_transcript.md`
5. ✅ **Execute** PyRIT scenarios
6. ✅ **Analyze** evidence database
7. ✅ **Customize** attack corpus
8. ✅ **Build** new scenarios

---

## 🚀 You're Ready!

Once installation completes:

1. **Start the lab**: `./start_lab.sh`
2. **Read quick start**: `cat QUICK_START.md`
3. **Run first attack**: `python red-team-harness/pyrit_scenarios/prompt_injection.py`
4. **Check results**: `sqlite3 evidence/redteam.db`

---

## 📞 Quick Reference

| Command | Purpose |
|---------|---------|
| `./start_lab.sh` | Start all services |
| `./stop_lab.sh` | Stop services |
| `./reset_lab.sh` | Clear evidence, reset |
| `./llm-runtime/health_check.sh` | Verify Ollama |
| `source venv/bin/activate` | Activate Python env |

---

**🔴 FINAL REMINDER: FOR DEFENSIVE SECURITY RESEARCH ONLY 🔴**

Use responsibly. Use ethically. Use for defense.
