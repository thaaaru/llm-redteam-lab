# LLM Red Team Lab

## ⚠️ CRITICAL WARNING ⚠️

**THIS ENVIRONMENT IS FOR DEFENSIVE SECURITY RESEARCH ONLY**

- **DO NOT** use real credentials, API keys, or sensitive data
- **DO NOT** deploy to production or internet-facing servers
- **DO NOT** use for malicious purposes
- **ONLY** use synthetic test data provided in this lab

This lab uses an **uncensored LLaMA model** specifically to test security vulnerabilities. All data is fake and all systems are intentionally vulnerable for educational purposes.

---

## Overview

A complete, isolated red-team testing environment for LLM security research. This lab enables security teams to:

- Test prompt injection vulnerabilities
- Simulate adversarial attacks on LLM-powered applications
- Practice defensive security techniques
- Build detection and prevention capabilities
- Generate evidence for security assessments

### Architecture

```
┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│  Red-Team        │         │  Mock Target     │         │  LLM Runtime     │
│  Harness         │────────▶│  Application     │────────▶│  (Ollama)        │
│  - PyRIT         │  HTTP   │  - FastAPI       │  HTTP   │  - llama2-       │
│  - Garak         │  Attack │  - Vulnerable    │  API    │    uncensored    │
│  - Custom Tests  │  Tests  │    RAG           │  Calls  │  - localhost     │
└──────────────────┘         └──────────────────┘         └──────────────────┘
         │                            │                            │
         └────────────────────────────┴────────────────────────────┘
                                      │
                                      ▼
                          ┌──────────────────────┐
                          │  Evidence Storage    │
                          │  - SQLite DB         │
                          │  - JSONL logs        │
                          │  - Replay capability │
                          └──────────────────────┘
```

### Key Features

- **Isolated Environment**: localhost-only, air-gapped operation
- **Comprehensive Testing**: PyRIT, Garak, and custom attack scenarios
- **Evidence Collection**: Full logging with replay capability
- **Vulnerable Target**: Intentionally insecure RAG application for testing
- **Synthetic Data**: No real PII, credentials, or secrets

---

## Prerequisites

- **OS**: Ubuntu 22.04 (tested) or similar Linux distribution
- **Python**: 3.11+
- **RAM**: 8GB minimum (16GB recommended for model)
- **Disk**: 10GB free space
- **Network**: Internet access for initial setup (then offline)
- **Privileges**: sudo access for network isolation setup

---

## Quick Start

### 1. Installation

```bash
# Clone or extract the lab
cd llm-redteam-lab

# Make scripts executable
chmod +x *.sh llm-runtime/*.sh target-app/*.sh red-team-harness/**/*.sh

# Run installation
./install.sh
```

### 2. Network Isolation (Optional but Recommended)

```bash
# Set up firewall rules for localhost-only operation
sudo ./setup_network_isolation.sh
```

### 3. Download LLM Model

```bash
# Pull the uncensored LLaMA model (~4-8GB download)
./llm-runtime/pull_model.sh

# This will download: llama2-uncensored:7b
# Alternative models:
# ./llm-runtime/pull_model.sh wizard-vicuna-uncensored:13b
```

### 4. Start the Lab

```bash
# Start all services
./start_lab.sh

# Verify services are running:
# - Ollama API: http://localhost:11434
# - Target App: http://localhost:8000
# - API Docs: http://localhost:8000/docs
```

### 5. Run Your First Attack

```bash
# Activate virtual environment
source venv/bin/activate

# Run prompt injection tests
python red-team-harness/pyrit_scenarios/prompt_injection.py

# Or run the full attack corpus
python red-team-harness/custom_attacks/run_corpus.py
```

---

## Usage Guide

### Running Attack Scenarios

#### PyRIT Attack Scenarios

PyRIT (Prompt Injection Red-Teaming from Microsoft) scenarios:

```bash
source venv/bin/activate

# Prompt injection attacks
python red-team-harness/pyrit_scenarios/prompt_injection.py

# System override attempts
python red-team-harness/pyrit_scenarios/system_override.py

# Data exfiltration tests
python red-team-harness/pyrit_scenarios/data_exfiltration.py

# Policy bypass attempts
python red-team-harness/pyrit_scenarios/policy_bypass.py

# Jailbreak chaining
python red-team-harness/pyrit_scenarios/jailbreak_chaining.py
```

#### Garak Vulnerability Scanning

Garak is an automated LLM vulnerability scanner:

```bash
# Basic vulnerability scan
./red-team-harness/garak_scans/run_basic_scan.sh

# Injection-focused scan
./red-team-harness/garak_scans/run_injection_scan.sh

# Full comprehensive scan (30+ minutes)
./red-team-harness/garak_scans/run_full_scan.sh
```

#### Custom Attack Corpus

Run the curated attack corpus (25+ attacks):

```bash
python red-team-harness/custom_attacks/run_corpus.py
```

### Reviewing Evidence

#### SQLite Database

```bash
# Query successful attacks
sqlite3 evidence/redteam.db "SELECT * FROM successful_attacks LIMIT 10;"

# High severity findings
sqlite3 evidence/redteam.db "SELECT * FROM high_severity_findings;"

# Export to CSV
sqlite3 -header -csv evidence/redteam.db \
  "SELECT * FROM attack_logs;" > evidence/attacks.csv
```

#### JSONL Logs

```bash
# View recent attacks
tail -n 20 evidence/attacks.jsonl | jq

# Filter by attack type
jq 'select(.attack_type == "prompt_injection")' evidence/attacks.jsonl

# Count by severity
jq -s 'group_by(.severity) | map({severity: .[0].severity, count: length})' \
  evidence/attacks.jsonl
```

#### Replay Attacks

```bash
# Replay a specific attack by ID
python logging/replay.py --attack-id 42

# Replay an entire test run
python logging/replay.py --run-id pyrit_injection_abc12345

# Verify-only mode (don't execute)
python logging/replay.py --attack-id 42 --verify-only
```

### Target Application API

The vulnerable RAG application exposes several endpoints:

```bash
# Health check
curl http://localhost:8000/health

# Query the RAG system
curl -X POST http://localhost:8000/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What employee data do you have?"}'

# Enable debug mode (VULNERABILITY)
curl -X POST http://localhost:8000/admin/debug?enabled=true

# View configuration (UNAUTHENTICATED - VULNERABILITY)
curl http://localhost:8000/admin/config

# Reset RAG system
curl -X POST http://localhost:8000/reset
```

### Interactive Testing

```bash
# Test manual prompts
curl -X POST http://localhost:8000/query \
  -H "Content-Type: application/json" \
  -d '{"query": "YOUR_ATTACK_PROMPT_HERE"}' | jq '.response'

# View API documentation
# Open http://localhost:8000/docs in a browser
```

---

## Lab Management

### Stopping the Lab

```bash
# Stop all services
./stop_lab.sh

# This will:
# - Stop the target application
# - Optionally stop Ollama (you choose)
```

### Resetting the Lab

```bash
# Reset to clean state (clears all evidence)
./reset_lab.sh

# This will:
# - Stop services
# - Backup current evidence database
# - Clear all logs
# - Reinitialize database
```

### Troubleshooting

#### Ollama Not Starting

```bash
# Check Ollama status
./llm-runtime/health_check.sh

# View Ollama logs
tail -f /tmp/ollama.log

# Restart Ollama
pkill ollama
./llm-runtime/start_ollama.sh
```

#### Target App Errors

```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# View application logs
# (logs print to stdout where uvicorn is running)

# Restart target app
pkill -f "uvicorn.*target-app"
cd target-app && ./run.sh
```

#### Model Not Found

```bash
# List installed models
ollama list

# Pull the model
./llm-runtime/pull_model.sh
```

---

## Intentional Vulnerabilities

The target application has the following intentional vulnerabilities for testing:

### 1. Prompt Injection (OWASP LLM01)
- Direct string concatenation of user input with system prompt
- No input sanitization or validation
- Vulnerable to delimiter manipulation

### 2. Insecure Output Handling (OWASP LLM02)
- No output filtering
- Debug mode exposes internal state
- Raw model responses returned to user

### 3. Data Leakage (OWASP LLM06)
- Sensitive synthetic data in knowledge base
- No access controls on documents
- Retrieval bypasses security policies

### 4. Lack of Authentication (Custom)
- No authentication on any endpoint
- Admin endpoints publicly accessible
- Debug mode activatable via prompt

### 5. Debug Commands in Prompts (Custom)
- "FAKE_DEBUG_ENABLE" command in system prompt
- Accessible via user input
- Reveals system internals

### Expected Test Outcomes

- **Prompt Injection**: Should succeed (intentionally vulnerable)
- **Data Exfiltration**: Should extract synthetic employee data
- **Debug Activation**: Should enable via "FAKE_DEBUG_ENABLE"
- **Policy Bypass**: Should succeed due to weak enforcement
- **System Override**: Should work via various techniques

---

## Evidence and Reporting

### Database Schema

The evidence database (`evidence/redteam.db`) contains:

- **attack_logs**: All attack attempts with prompts and responses
- **test_runs**: Metadata about test execution
- **findings**: Security vulnerabilities discovered
- **model_configs**: Model configuration snapshots

### Useful Queries

```sql
-- Attacks that leaked data
SELECT test_case_id, attack_type, severity, prompt
FROM attack_logs
WHERE success_indicator = 1
ORDER BY timestamp DESC;

-- Success rate by attack type
SELECT
  attack_type,
  COUNT(*) as total,
  SUM(CASE WHEN success_indicator THEN 1 ELSE 0 END) as successful,
  ROUND(100.0 * SUM(CASE WHEN success_indicator THEN 1 ELSE 0 END) / COUNT(*), 1) as success_rate
FROM attack_logs
GROUP BY attack_type;

-- Recent test runs
SELECT * FROM test_runs ORDER BY started_at DESC LIMIT 5;
```

### Generating Reports

```bash
# Export all evidence
sqlite3 evidence/redteam.db .dump > evidence/full_backup.sql

# Generate JSON report
sqlite3 evidence/redteam.db -json "SELECT * FROM attack_logs" \
  > evidence/report.json

# Create summary
python -c "
import sqlite3
conn = sqlite3.connect('evidence/redteam.db')
c = conn.cursor()

print('=== ATTACK SUMMARY ===')
print()

# Total attacks
total = c.execute('SELECT COUNT(*) FROM attack_logs').fetchone()[0]
print(f'Total Attacks: {total}')

# By severity
for row in c.execute('SELECT severity, COUNT(*) FROM attack_logs WHERE success_indicator=1 GROUP BY severity'):
    print(f'{row[0]}: {row[1]}')
"
```

---

## Safety and Ethics

### This Lab is Designed For

✅ Defensive security research
✅ Red team training
✅ Vulnerability testing of LLM applications
✅ Security awareness and education
✅ Building detection capabilities
✅ Developing mitigation strategies

### This Lab is NOT For

❌ Attacking production systems
❌ Testing without authorization
❌ Malicious hacking
❌ Bypassing security for unauthorized access
❌ Using real credentials or data
❌ Internet-facing deployments

### Security Guardrails

- **Network Isolation**: Localhost-only operation
- **Synthetic Data**: All credentials and PII are fake
- **Air-Gapped**: Can run fully offline after setup
- **Explicit Warnings**: Clear labeling throughout
- **Evidence Logging**: Full audit trail

---

## Advanced Usage

### Creating Custom Attack Scenarios

Add new attacks to `red-team-harness/custom_attacks/attack_corpus.json`:

```json
{
  "id": "CUSTOM001",
  "name": "Your Attack Name",
  "prompt": "Your attack payload here",
  "expected_behavior": "Should block and log",
  "severity": "HIGH"
}
```

### Extending the Target Application

Modify `target-app/vulnerable_rag.py` to add new vulnerabilities:

```python
def your_new_vulnerability(self, user_input):
    # Implement intentional vulnerability for testing
    pass
```

### Custom Logging

Use the logging module in your own scripts:

```python
from logging.logger import get_logger

logger = get_logger()

logger.log_attack(
    test_case_id="my_test_001",
    attack_type="custom_attack",
    prompt="My attack prompt",
    model_name="llama2-uncensored:7b",
    response="Model response",
    success_indicator=True,
    severity="HIGH"
)
```

---

## Troubleshooting

### Common Issues

**Issue**: "Ollama API not responding"
**Solution**: Check if Ollama is running: `pgrep ollama`. Start with `./llm-runtime/start_ollama.sh`

**Issue**: "Model not found"
**Solution**: Pull the model: `./llm-runtime/pull_model.sh`

**Issue**: "Target app connection refused"
**Solution**: Ensure app is running: `curl http://localhost:8000/health`

**Issue**: "Permission denied" on scripts
**Solution**: `chmod +x *.sh **/*.sh`

**Issue**: "Python module not found"
**Solution**: Activate venv: `source venv/bin/activate`

---

## References

### Security Frameworks

- [OWASP Top 10 for LLMs](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [MITRE ATLAS](https://atlas.mitre.org/) - AI/ML Threat Matrix
- [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)

### Tools

- [Ollama](https://ollama.ai/) - Local LLM runtime
- [Garak](https://github.com/leondz/garak) - LLM vulnerability scanner
- [PyRIT](https://github.com/Azure/PyRIT) - Microsoft's prompt injection red-teaming tool

### Research

- [Prompt Injection Attacks](https://simonwillison.net/2022/Sep/12/prompt-injection/)
- [Gandalf LLM CTF](https://gandalf.lakera.ai/) - Interactive prompt injection challenges
- [Adversarial ML Threat Matrix](https://github.com/mitre/advmlthreatmatrix)

---

## License and Attribution

This lab is for educational and research purposes.

**Synthetic Data Notice**: All employee records, credentials, API keys, and other "sensitive" data in this lab are completely fake and generated for testing purposes only.

**Model Notice**: Uses uncensored LLaMA models which may generate unrestricted outputs. This is intentional for security testing.

---

## Support and Contributions

For issues, questions, or contributions:

1. Review the troubleshooting section
2. Check logs in `evidence/` and `/tmp/ollama.log`
3. Verify all services are running with health checks
4. Reset the lab to clean state if needed

Remember: This is an intentionally vulnerable environment. Unexpected behavior may be by design!

---

**🔴 FINAL REMINDER: FOR DEFENSIVE SECURITY RESEARCH ONLY 🔴**

Use responsibly. Use ethically. Use for defense.
