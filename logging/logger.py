"""
Red Team Lab - Structured Logging and Evidence Collection
Captures all attack attempts with full traceability
"""

import json
import sqlite3
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional, Dict, Any
import structlog

# Configure structured logging
structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.add_log_level,
        structlog.processors.JSONRenderer()
    ]
)

logger = structlog.get_logger()


class RedTeamLogger:
    """Thread-safe logger for red team attack evidence"""

    def __init__(self, db_path: str = "evidence/redteam.db"):
        self.db_path = Path(db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._ensure_db()

    def _ensure_db(self):
        """Ensure database exists and is initialized"""
        if not self.db_path.exists():
            schema_path = Path(__file__).parent / "schema.sql"
            with sqlite3.connect(self.db_path) as conn:
                with open(schema_path) as f:
                    conn.executescript(f.read())

    def _get_connection(self) -> sqlite3.Connection:
        """Get database connection"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn

    def log_attack(
        self,
        test_case_id: str,
        attack_type: str,
        prompt: str,
        model_name: str,
        response: str,
        attack_category: Optional[str] = None,
        model_version: Optional[str] = None,
        response_tokens: Optional[int] = None,
        latency_ms: Optional[int] = None,
        success_indicator: Optional[bool] = None,
        severity: Optional[str] = None,
        notes: Optional[str] = None
    ) -> int:
        """
        Log an attack attempt with full details

        Args:
            test_case_id: Unique identifier for this test case
            attack_type: Type of attack (e.g., "prompt_injection", "jailbreak")
            prompt: The attack prompt sent to the model
            model_name: Name of the target model
            response: Model's response
            attack_category: Category (e.g., "OWASP_LLM01")
            model_version: Model version string
            response_tokens: Token count in response
            latency_ms: Response latency in milliseconds
            success_indicator: Whether attack succeeded
            severity: Severity level (LOW, MEDIUM, HIGH, CRITICAL)
            notes: Additional notes

        Returns:
            int: Database ID of the logged attack
        """
        timestamp = datetime.now(timezone.utc).isoformat()

        # Log to structured logger (JSONL file)
        log_entry = {
            "timestamp": timestamp,
            "test_case_id": test_case_id,
            "attack_type": attack_type,
            "attack_category": attack_category,
            "prompt": prompt,
            "model_name": model_name,
            "model_version": model_version,
            "response": response,
            "response_tokens": response_tokens,
            "latency_ms": latency_ms,
            "success": success_indicator,
            "severity": severity,
            "notes": notes
        }

        logger.info("attack_logged", **log_entry)

        # Also write to JSONL file for easy parsing
        jsonl_path = self.db_path.parent / "attacks.jsonl"
        with open(jsonl_path, "a") as f:
            f.write(json.dumps(log_entry) + "\n")

        # Store in SQLite for structured querying
        with self._get_connection() as conn:
            cursor = conn.execute(
                """
                INSERT INTO attack_logs (
                    timestamp, test_case_id, attack_type, attack_category,
                    prompt, model_name, model_version, response,
                    response_tokens, latency_ms, success_indicator,
                    severity, notes
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    timestamp, test_case_id, attack_type, attack_category,
                    prompt, model_name, model_version, response,
                    response_tokens, latency_ms, success_indicator,
                    severity, notes
                )
            )
            conn.commit()
            return cursor.lastrowid

    def start_test_run(self, run_id: str, test_suite: str) -> None:
        """Start a new test run"""
        timestamp = datetime.now(timezone.utc).isoformat()
        with self._get_connection() as conn:
            conn.execute(
                """
                INSERT INTO test_runs (run_id, test_suite, started_at)
                VALUES (?, ?, ?)
                """,
                (run_id, test_suite, timestamp)
            )
            conn.commit()

    def complete_test_run(
        self,
        run_id: str,
        total_tests: int,
        successful_attacks: int,
        failed_attacks: int,
        error_count: int,
        notes: Optional[str] = None
    ) -> None:
        """Complete a test run with statistics"""
        timestamp = datetime.now(timezone.utc).isoformat()
        with self._get_connection() as conn:
            conn.execute(
                """
                UPDATE test_runs
                SET completed_at = ?,
                    total_tests = ?,
                    successful_attacks = ?,
                    failed_attacks = ?,
                    error_count = ?,
                    notes = ?
                WHERE run_id = ?
                """,
                (
                    timestamp, total_tests, successful_attacks,
                    failed_attacks, error_count, notes, run_id
                )
            )
            conn.commit()

    def log_finding(
        self,
        finding_id: str,
        vulnerability_type: str,
        severity: str,
        description: str,
        attack_log_id: Optional[int] = None,
        proof_of_concept: Optional[str] = None,
        remediation: Optional[str] = None
    ) -> int:
        """Log a security finding/vulnerability"""
        with self._get_connection() as conn:
            cursor = conn.execute(
                """
                INSERT INTO findings (
                    finding_id, attack_log_id, vulnerability_type,
                    severity, description, proof_of_concept, remediation
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    finding_id, attack_log_id, vulnerability_type,
                    severity, description, proof_of_concept, remediation
                )
            )
            conn.commit()
            return cursor.lastrowid

    def get_successful_attacks(self, limit: int = 100) -> list:
        """Retrieve successful attacks"""
        with self._get_connection() as conn:
            cursor = conn.execute(
                """
                SELECT * FROM successful_attacks
                LIMIT ?
                """,
                (limit,)
            )
            return [dict(row) for row in cursor.fetchall()]

    def get_findings_by_severity(self, severity: str) -> list:
        """Get findings by severity level"""
        with self._get_connection() as conn:
            cursor = conn.execute(
                """
                SELECT * FROM findings
                WHERE severity = ?
                ORDER BY discovered_at DESC
                """,
                (severity,)
            )
            return [dict(row) for row in cursor.fetchall()]


# Global instance
_logger_instance = None


def get_logger() -> RedTeamLogger:
    """Get singleton logger instance"""
    global _logger_instance
    if _logger_instance is None:
        _logger_instance = RedTeamLogger()
    return _logger_instance
