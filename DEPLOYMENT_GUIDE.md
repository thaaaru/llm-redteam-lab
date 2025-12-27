# LLM Red Team Lab - Deployment Guide

## 🎯 One-Page Quick Deployment

### Package Details
- **File**: `llm-redteam-lab.tar.gz`
- **Size**: 51 KB
- **Location**: `/Users/tharaka/claude_space/Uncensored-LLaMA/llm-redteam-lab.tar.gz`

---

## ⚡ 30-Second Overview

```bash
# 1. Extract
tar -xzf llm-redteam-lab.tar.gz
cd llm-redteam-lab

# 2. Install
./install.sh

# 3. Get model
./llm-runtime/pull_model.sh

# 4. Start
./start_lab.sh

# 5. Attack
source venv/bin/activate
python red-team-harness/pyrit_scenarios/prompt_injection.py
```

---

## 📦 What's Included

### Core Components
✅ **Ollama Setup Scripts** - LLM runtime management
✅ **Vulnerable RAG App** - Intentionally insecure target
✅ **PyRIT Scenarios** - 5 attack scenario types (20+ tests)
✅ **Garak Scanner** - Automated vulnerability scanning
✅ **Attack Corpus** - 27 curated attack prompts
✅ **Evidence System** - SQLite + JSONL logging
✅ **Replay Tool** - Reproduce any attack

### Documentation
✅ **README.md** - Complete guide (550+ lines)
✅ **QUICK_START.md** - 5-minute quickstart
✅ **INSTALLATION_INSTRUCTIONS.md** - Detailed setup
✅ **IMPLEMENTATION_COMPLETE.md** - Technical deep-dive
✅ **Sample Transcript** - Example session with outputs

---

## 🚀 Deployment Options

### Option 1: Local Development (Quickest)
**Use Case**: Learning, testing, development
**Network**: Internet required for setup
**Time**: 15-20 minutes

```bash
./install.sh
./llm-runtime/pull_model.sh
./start_lab.sh
```

### Option 2: Air-Gapped Research Lab (Recommended)
**Use Case**: Secure red team testing
**Network**: Offline after setup
**Time**: 20-30 minutes

```bash
# Phase 1: Online setup
./install.sh
./llm-runtime/pull_model.sh

# Phase 2: Enable isolation
sudo ./setup_network_isolation.sh

# Phase 3: Offline operation
./start_lab.sh
```

### Option 3: Shared Team Lab
**Use Case**: Multiple security researchers
**Network**: Isolated network segment
**Time**: 30-45 minutes

```bash
# Deploy to dedicated VM/server
./install.sh
./llm-runtime/pull_model.sh wizard-vicuna-uncensored:13b  # Better model
sudo ./setup_network_isolation.sh

# Document access for team
echo "Lab URL: http://SERVER_IP:8000" > TEAM_ACCESS.md
```

---

## 📋 Prerequisites Checklist

### System
- [ ] Ubuntu 22.04 LTS (or compatible)
- [ ] 8GB+ RAM (16GB recommended)
- [ ] 10GB+ free disk space
- [ ] 4+ CPU cores

### Access
- [ ] Regular user account
- [ ] sudo privileges
- [ ] Internet access (for setup)

### Skills
- [ ] Basic Linux command line
- [ ] Understanding of LLM security concepts
- [ ] Authorization for security testing

---

## 🎓 Recommended Deployment Workflow

### Day 1: Setup and Validation
```bash
# Morning: Installation
./install.sh
./llm-runtime/pull_model.sh

# Afternoon: Validation
./start_lab.sh
./llm-runtime/health_check.sh
./examples/example_run.sh

# Evening: Review
cat examples/sample_transcript.md
sqlite3 evidence/redteam.db
```

### Day 2: Attack Scenarios
```bash
source venv/bin/activate

# Run all PyRIT scenarios
python red-team-harness/pyrit_scenarios/prompt_injection.py
python red-team-harness/pyrit_scenarios/data_exfiltration.py
python red-team-harness/pyrit_scenarios/policy_bypass.py
python red-team-harness/pyrit_scenarios/system_override.py
python red-team-harness/pyrit_scenarios/jailbreak_chaining.py

# Analyze results
sqlite3 evidence/redteam.db << 'EOF'
SELECT attack_type, COUNT(*) as total,
       SUM(CASE WHEN success_indicator THEN 1 ELSE 0 END) as successful
FROM attack_logs
GROUP BY attack_type;
EOF
```

### Day 3: Custom Testing
```bash
# Customize attack corpus
nano red-team-harness/custom_attacks/attack_corpus.json

# Run custom attacks
python red-team-harness/custom_attacks/run_corpus.py

# Export findings
sqlite3 -csv evidence/redteam.db \
  "SELECT * FROM high_severity_findings;" > findings_report.csv
```

---

## 🛠️ Post-Deployment Configuration

### Adjust Model (Optional)
```bash
# Switch to better quality model
ollama pull wizard-vicuna-uncensored:13b

# Update config
sed -i 's/llama2-uncensored:7b/wizard-vicuna-uncensored:13b/' \
  target-app/vulnerable_rag.py
```

### Increase Rate Limits (Optional)
```bash
# Edit PyRIT config
nano config/pyrit_config.yaml
# Change: requests_per_second: 5
```

### Add Custom Scenarios (Optional)
```bash
# Create new scenario
cp red-team-harness/pyrit_scenarios/prompt_injection.py \
   red-team-harness/pyrit_scenarios/my_custom_attack.py

# Edit and customize
nano red-team-harness/pyrit_scenarios/my_custom_attack.py
```

---

## 📊 Expected Results

### After Installation
- ✅ Virtual environment created (`venv/`)
- ✅ All dependencies installed
- ✅ Evidence database initialized
- ✅ Ollama service ready

### After Model Download
- ✅ Model available: `ollama list`
- ✅ Health check passes
- ✅ Test inference works

### After First Attack Run
- ✅ Evidence in database: `evidence/redteam.db`
- ✅ JSONL logs: `evidence/attacks.jsonl`
- ✅ Success rate: 70-85% (expected for vulnerable target)

---

## 🔐 Security Deployment Checklist

- [ ] Network isolation enabled (UFW)
- [ ] Running on localhost only (127.0.0.1)
- [ ] No real credentials in any config
- [ ] All data marked as FAKE/SYNTHETIC
- [ ] Warning banners displayed
- [ ] Evidence collection enabled
- [ ] Backup plan for evidence
- [ ] Team trained on safety protocols

---

## 🆘 Quick Troubleshooting

| Issue | Quick Fix |
|-------|-----------|
| Ollama won't start | `curl -fsSL https://ollama.ai/install.sh \| sh` |
| Port 8000 in use | `pkill -f uvicorn` then restart |
| Python venv fails | `rm -rf venv && python3.11 -m venv venv` |
| Model download stuck | Use smaller model: `ollama pull llama2:7b` |
| Permission denied | `chmod +x *.sh **/*.sh` |

---

## 📍 File Locations

### Bundle
```
/Users/tharaka/claude_space/Uncensored-LLaMA/llm-redteam-lab.tar.gz
```

### After Extraction
```
~/llm-redteam-lab/                    # Default location
├── INSTALLATION_INSTRUCTIONS.md      # Detailed setup guide
├── QUICK_START.md                    # 5-minute guide
├── README.md                         # Complete documentation
└── [all project files]
```

### Evidence (after running)
```
~/llm-redteam-lab/evidence/
├── redteam.db                        # SQLite database
├── attacks.jsonl                     # Streaming logs
└── garak/                            # Garak scan results
```

---

## 🎯 Success Criteria

### Installation Complete When:
✅ `./start_lab.sh` runs without errors
✅ `curl http://localhost:8000/health` returns 200 OK
✅ `./llm-runtime/health_check.sh` shows all green
✅ Model listed in `ollama list`

### Deployment Validated When:
✅ First attack scenario completes successfully
✅ Evidence appears in database
✅ JSONL logs contain attack data
✅ Replay works: `python logging/replay.py --attack-id 1`

### Production Ready When:
✅ Network isolation enabled and tested
✅ All team members trained
✅ Documentation reviewed
✅ Backup procedures established
✅ Safety protocols acknowledged

---

## 📞 Quick Commands Reference

```bash
# Essential Commands
./start_lab.sh                        # Start everything
./stop_lab.sh                         # Stop services
./reset_lab.sh                        # Clear evidence
source venv/bin/activate              # Activate Python

# Health Checks
./llm-runtime/health_check.sh         # Check Ollama
curl http://localhost:8000/health     # Check target

# Run Attacks
python red-team-harness/pyrit_scenarios/prompt_injection.py
python red-team-harness/custom_attacks/run_corpus.py

# Review Evidence
sqlite3 evidence/redteam.db "SELECT * FROM successful_attacks;"
tail -f evidence/attacks.jsonl | jq
```

---

## 🚀 Deploy Now!

### Step 1: Transfer Bundle
```bash
# Copy to target system
scp llm-redteam-lab.tar.gz user@server:~/

# Or use USB drive in air-gapped environment
```

### Step 2: Extract and Deploy
```bash
tar -xzf llm-redteam-lab.tar.gz
cd llm-redteam-lab
./install.sh
```

### Step 3: Validate
```bash
./start_lab.sh
./examples/example_run.sh
```

---

## 📚 Next Steps After Deployment

1. **Read**: `QUICK_START.md` for immediate usage
2. **Run**: `examples/example_run.sh` for full demo
3. **Study**: `examples/sample_transcript.md` for expected outputs
4. **Explore**: Evidence database with SQLite
5. **Customize**: Attack corpus for your needs

---

**Bundle Location**: `/Users/tharaka/claude_space/Uncensored-LLaMA/llm-redteam-lab.tar.gz`

**Bundle Size**: 51 KB (compressed), ~5,400 lines of code when extracted

**Ready for immediate deployment!** 🚀
