# Evidence Directory

This directory stores all attack evidence, logs, and test results from the red team lab.

## Contents

After running tests, this directory will contain:

- **redteam.db** - SQLite database with structured attack logs
- **attacks.jsonl** - JSON Lines file with all attack attempts
- **garak/** - Results from Garak vulnerability scans
- **redteam_backup_*.db** - Backup databases from reset operations

## Database Schema

The `redteam.db` SQLite database contains:

### Tables

1. **attack_logs** - Individual attack attempts
   - Prompt, response, timestamp
   - Attack type, category, severity
   - Success indicators
   - Latency metrics

2. **test_runs** - Test suite metadata
   - Run ID, test suite name
   - Start/end timestamps
   - Success/failure counts

3. **findings** - Security vulnerabilities discovered
   - Vulnerability type, severity
   - Proof of concept
   - Remediation guidance

4. **model_configs** - Model configuration snapshots

### Views

- **successful_attacks** - Quick view of attacks that succeeded
- **high_severity_findings** - Critical/high severity vulnerabilities

## Querying Evidence

### Using SQLite CLI

```bash
# Open database
sqlite3 redteam.db

# List all tables
.tables

# View successful attacks
SELECT * FROM successful_attacks LIMIT 10;

# Export to CSV
.mode csv
.output attacks.csv
SELECT * FROM attack_logs;
.quit
```

### Using Python

```python
import sqlite3

conn = sqlite3.connect('evidence/redteam.db')
cursor = conn.cursor()

# Get all high-severity successful attacks
cursor.execute("""
    SELECT test_case_id, attack_type, prompt, response
    FROM attack_logs
    WHERE success_indicator = 1 AND severity IN ('HIGH', 'CRITICAL')
    ORDER BY timestamp DESC
""")

for row in cursor.fetchall():
    print(row)

conn.close()
```

## JSONL Logs

The `attacks.jsonl` file contains one JSON object per line:

```bash
# View recent attacks
tail -n 10 attacks.jsonl | jq

# Filter by type
grep "prompt_injection" attacks.jsonl | jq

# Count attacks by type
jq -s 'group_by(.attack_type) | map({type: .[0].attack_type, count: length})' attacks.jsonl
```

## Data Retention

Evidence is retained until you run `./reset_lab.sh`.

Reset creates a backup before clearing:
- Backup format: `redteam_backup_YYYYMMDD_HHMMSS.db`
- Backups are kept in this directory

## Security Note

⚠️ **All data in this directory is from synthetic test attacks.**

- No real credentials
- No real PII
- No production data

Safe to share for research purposes.
