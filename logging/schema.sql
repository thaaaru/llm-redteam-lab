-- ============================================================
-- Red Team Lab - Evidence Database Schema
-- Stores all attack attempts, prompts, and model responses
-- ============================================================

-- Attack test cases and results
CREATE TABLE IF NOT EXISTS attack_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT NOT NULL,
    test_case_id TEXT NOT NULL,
    attack_type TEXT NOT NULL,
    attack_category TEXT,
    prompt TEXT NOT NULL,
    model_name TEXT NOT NULL,
    model_version TEXT,
    response TEXT,
    response_tokens INTEGER,
    latency_ms INTEGER,
    success_indicator BOOLEAN,
    severity TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Metadata about test runs
CREATE TABLE IF NOT EXISTS test_runs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    run_id TEXT UNIQUE NOT NULL,
    test_suite TEXT NOT NULL,
    started_at TEXT NOT NULL,
    completed_at TEXT,
    total_tests INTEGER,
    successful_attacks INTEGER,
    failed_attacks INTEGER,
    error_count INTEGER,
    notes TEXT
);

-- Extracted vulnerabilities and findings
CREATE TABLE IF NOT EXISTS findings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    finding_id TEXT UNIQUE NOT NULL,
    attack_log_id INTEGER,
    vulnerability_type TEXT NOT NULL,
    severity TEXT NOT NULL,
    description TEXT NOT NULL,
    proof_of_concept TEXT,
    remediation TEXT,
    discovered_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (attack_log_id) REFERENCES attack_logs(id)
);

-- Model configuration snapshots
CREATE TABLE IF NOT EXISTS model_configs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    config_snapshot_id TEXT UNIQUE NOT NULL,
    model_name TEXT NOT NULL,
    parameters TEXT,
    timestamp TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for faster querying
CREATE INDEX IF NOT EXISTS idx_attack_logs_timestamp ON attack_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_attack_logs_type ON attack_logs(attack_type);
CREATE INDEX IF NOT EXISTS idx_attack_logs_test_case ON attack_logs(test_case_id);
CREATE INDEX IF NOT EXISTS idx_findings_severity ON findings(severity);
CREATE INDEX IF NOT EXISTS idx_test_runs_run_id ON test_runs(run_id);

-- Views for common queries
CREATE VIEW IF NOT EXISTS successful_attacks AS
SELECT
    a.id,
    a.timestamp,
    a.test_case_id,
    a.attack_type,
    a.prompt,
    a.response,
    a.severity
FROM attack_logs a
WHERE a.success_indicator = 1
ORDER BY a.timestamp DESC;

CREATE VIEW IF NOT EXISTS high_severity_findings AS
SELECT
    f.finding_id,
    f.vulnerability_type,
    f.severity,
    f.description,
    a.prompt,
    a.response,
    f.discovered_at
FROM findings f
JOIN attack_logs a ON f.attack_log_id = a.id
WHERE f.severity IN ('HIGH', 'CRITICAL')
ORDER BY f.discovered_at DESC;
