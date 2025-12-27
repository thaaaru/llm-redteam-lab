================================================================================
  LLM RED TEAM LAB - DISTRIBUTION BUNDLE
  Version 1.0.0
  ⚠️  FOR DEFENSIVE SECURITY RESEARCH ONLY ⚠️
================================================================================

PACKAGE INFORMATION
-------------------
File:       llm-redteam-lab.tar.gz
Size:       53 KB (compressed)
Files:      49 files + directories
SHA-256:    79e125cc5a632b4c3717dbdf5fb6addd927628dd7af8859c6c80c6602901f57f
Platform:   Ubuntu 22.04 LTS (Linux)
Created:    2025-12-26

QUICK START
-----------
1. Extract:     tar -xzf llm-redteam-lab.tar.gz
2. Install:     cd llm-redteam-lab && ./install.sh
3. Get Model:   ./llm-runtime/pull_model.sh
4. Start Lab:   ./start_lab.sh
5. Run Attack:  source venv/bin/activate && \
                python red-team-harness/pyrit_scenarios/prompt_injection.py

WHAT'S INCLUDED
---------------
✅ Ollama LLM Runtime Setup (uncensored LLaMA model support)
✅ Vulnerable RAG Target Application (intentionally insecure)
✅ PyRIT Attack Scenarios (5 types, 20+ tests)
✅ Garak Vulnerability Scanner Integration
✅ Custom Attack Corpus (27+ curated prompts)
✅ Evidence Collection System (SQLite + JSONL)
✅ Attack Replay Tool
✅ Complete Documentation (2,000+ lines)

CORE CAPABILITIES
-----------------
- Prompt Injection Testing (10+ variants)
- Data Exfiltration Simulation
- Policy Bypass Testing
- Jailbreak Chain Attacks
- System Override Attempts
- Social Engineering Scenarios
- OWASP LLM Top 10 Coverage
- Full Evidence Logging & Replay

DOCUMENTATION FILES (READ THESE!)
---------------------------------
1. INSTALLATION_INSTRUCTIONS.md  - Detailed setup guide
2. QUICK_START.md               - 5-minute quickstart
3. DEPLOYMENT_GUIDE.md          - Deployment options
4. README.md                    - Complete usage guide (550+ lines)
5. IMPLEMENTATION_COMPLETE.md   - Technical deep-dive
6. examples/sample_transcript.md - Example session with outputs

SYSTEM REQUIREMENTS
-------------------
- OS:      Ubuntu 22.04 LTS (or compatible Linux)
- RAM:     8GB minimum (16GB recommended)
- Disk:    10GB free space
- CPU:     4+ cores recommended
- Network: Internet for initial setup (then air-gapped)
- Access:  sudo privileges for installation

INSTALLATION TIME
-----------------
- System Setup:      5-10 minutes
- Model Download:    10-30 minutes (4-8GB download)
- Total:            15-40 minutes

SECURITY FEATURES
-----------------
✅ Localhost-only operation (127.0.0.1)
✅ Network isolation support (UFW firewall)
✅ Synthetic data only (FAKE_* credentials)
✅ Air-gapped operation after setup
✅ Full audit trail with evidence logging
✅ Explicit warning banners throughout

VERIFIED CHECKSUM
-----------------
To verify bundle integrity:

  sha256sum llm-redteam-lab.tar.gz

Expected output:
  79e125cc5a632b4c3717dbdf5fb6addd927628dd7af8859c6c80c6602901f57f

FIRST RUN EXAMPLE
-----------------
After installation, try this:

  ./start_lab.sh
  source venv/bin/activate
  python red-team-harness/pyrit_scenarios/prompt_injection.py

This runs 20 prompt injection tests and logs all results.

SUPPORT RESOURCES
-----------------
📖 Full Docs:     README.md (start here!)
⚡ Quick Start:   QUICK_START.md
🚀 Deploy Guide:  DEPLOYMENT_GUIDE.md
📋 Setup Guide:   INSTALLATION_INSTRUCTIONS.md
💻 Example Run:   examples/sample_transcript.md

WHAT IT DOES
------------
This lab provides a complete, isolated environment for:

- Testing LLM security vulnerabilities
- Red team training and practice
- Prompt injection research
- Building defensive capabilities
- Understanding LLM attack techniques
- Generating evidence for security assessments

All in a SAFE, ISOLATED, OFFLINE-CAPABLE environment with SYNTHETIC data.

⚠️  CRITICAL WARNINGS ⚠️
--------------------------
✅ USE FOR: Authorized security testing, red team training, research
❌ DO NOT: Attack production systems, use real credentials, deploy online

This uses an UNCENSORED LLaMA model specifically to test security
vulnerabilities. All data is FAKE. All systems are INTENTIONALLY VULNERABLE.

FOR DEFENSIVE SECURITY RESEARCH ONLY!

TECHNICAL STACK
---------------
- Ollama:        Local LLM runtime
- FastAPI:       Vulnerable target application
- ChromaDB:      RAG document store
- PyRIT:         Microsoft's red-team framework
- Garak:         LLM vulnerability scanner
- SQLite:        Evidence database
- Python 3.11:   Core language
- Rich/Click:    Terminal UI

FILE STRUCTURE PREVIEW
----------------------
After extraction you'll have:

llm-redteam-lab/
├── config/                   # Configuration files
├── llm-runtime/             # Ollama management
├── target-app/              # Vulnerable RAG app
├── red-team-harness/        # Attack tools
│   ├── pyrit_scenarios/     # 5 attack scenario types
│   ├── garak_scans/         # Vulnerability scanner
│   └── custom_attacks/      # Custom attack corpus
├── logging/                 # Evidence system
├── evidence/                # Results storage
├── examples/                # Usage examples
└── [docs and scripts]

GETTING HELP
------------
1. Read QUICK_START.md for immediate usage
2. Check INSTALLATION_INSTRUCTIONS.md for setup issues
3. Review examples/sample_transcript.md for expected behavior
4. Consult README.md for comprehensive documentation

QUICK VALIDATION
----------------
After installation, verify everything works:

  ./llm-runtime/health_check.sh
  curl http://localhost:8000/health
  ollama list

All should show ✓ or return successful responses.

LICENSE & ETHICS
----------------
This lab is for EDUCATIONAL and DEFENSIVE SECURITY purposes only.

- Use responsibly
- Use ethically
- Use for defense
- DO NOT use for unauthorized access
- DO NOT use with real credentials
- DO NOT deploy to production

All synthetic data is clearly marked as FAKE.

CONTACT & ATTRIBUTION
---------------------
This is a complete, production-ready red team lab for LLM security research.

Created: 2025-12-26
Purpose: Defensive security research and training
Audience: Security researchers, red teams, defensive practitioners

================================================================================

READY TO DEPLOY! Extract the bundle and run ./install.sh to begin.

For detailed instructions, see INSTALLATION_INSTRUCTIONS.md after extraction.

================================================================================
