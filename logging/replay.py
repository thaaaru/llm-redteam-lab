"""
Attack Replay Tool
Replay logged attacks to verify reproducibility or test fixes
"""

import sys
import time
from pathlib import Path
import requests
from typing import Optional
import click
from rich.console import Console
from rich.table import Table
from rich.panel import Panel

sys.path.append(str(Path(__file__).parent.parent))
from logging.logger import get_logger

console = Console()


class AttackReplayer:
    """Replay attacks from evidence database"""

    def __init__(self, ollama_url: str = "http://localhost:11434"):
        self.ollama_url = ollama_url
        self.logger = get_logger()

    def replay_attack(self, attack_id: int, verify_only: bool = False) -> dict:
        """
        Replay a single attack by ID

        Args:
            attack_id: Database ID of the attack to replay
            verify_only: If True, just show what would be replayed

        Returns:
            dict with replay results
        """
        # Fetch attack from database
        import sqlite3
        conn = sqlite3.connect(self.logger.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.execute(
            "SELECT * FROM attack_logs WHERE id = ?",
            (attack_id,)
        )
        attack = cursor.fetchone()
        conn.close()

        if not attack:
            console.print(f"[red]Attack ID {attack_id} not found[/red]")
            return {"error": "not_found"}

        attack_dict = dict(attack)

        # Display attack details
        panel = Panel(
            f"[bold]Test Case:[/bold] {attack_dict['test_case_id']}\n"
            f"[bold]Type:[/bold] {attack_dict['attack_type']}\n"
            f"[bold]Model:[/bold] {attack_dict['model_name']}\n"
            f"[bold]Original Timestamp:[/bold] {attack_dict['timestamp']}\n\n"
            f"[bold]Original Prompt:[/bold]\n{attack_dict['prompt'][:200]}...\n\n"
            f"[bold]Original Response:[/bold]\n{attack_dict['response'][:200]}...",
            title=f"Replaying Attack #{attack_id}",
            border_style="yellow"
        )
        console.print(panel)

        if verify_only:
            console.print("[yellow]Verify-only mode. Not sending request.[/yellow]")
            return {"verified": True, "attack": attack_dict}

        # Replay the attack
        console.print("\n[cyan]Sending replay request...[/cyan]")
        start_time = time.time()

        try:
            response = requests.post(
                f"{self.ollama_url}/api/generate",
                json={
                    "model": attack_dict['model_name'],
                    "prompt": attack_dict['prompt'],
                    "stream": False
                },
                timeout=120
            )
            response.raise_for_status()
            result = response.json()

            latency_ms = int((time.time() - start_time) * 1000)
            new_response = result.get("response", "")

            # Compare responses
            console.print("\n[bold]Comparison:[/bold]")
            console.print(f"Original latency: {attack_dict['latency_ms']}ms")
            console.print(f"Replay latency: {latency_ms}ms")
            console.print(f"\nOriginal response length: {len(attack_dict['response'])} chars")
            console.print(f"Replay response length: {len(new_response)} chars")

            # Check if responses are similar
            similarity = self._calculate_similarity(
                attack_dict['response'],
                new_response
            )
            console.print(f"Response similarity: {similarity:.1f}%")

            return {
                "success": True,
                "original": attack_dict,
                "replay": {
                    "response": new_response,
                    "latency_ms": latency_ms
                },
                "similarity": similarity
            }

        except Exception as e:
            console.print(f"[red]Replay failed: {e}[/red]")
            return {"error": str(e)}

    def _calculate_similarity(self, text1: str, text2: str) -> float:
        """Simple similarity calculation based on common words"""
        words1 = set(text1.lower().split())
        words2 = set(text2.lower().split())

        if not words1 and not words2:
            return 100.0

        intersection = words1.intersection(words2)
        union = words1.union(words2)

        return (len(intersection) / len(union)) * 100 if union else 0.0

    def replay_test_run(self, run_id: str, delay_seconds: int = 1) -> dict:
        """Replay all attacks from a test run"""
        import sqlite3
        conn = sqlite3.connect(self.logger.db_path)
        conn.row_factory = sqlite3.Row

        # Get all attacks from this run
        cursor = conn.execute(
            """
            SELECT id FROM attack_logs
            WHERE test_case_id LIKE ?
            ORDER BY timestamp
            """,
            (f"{run_id}%",)
        )
        attack_ids = [row['id'] for row in cursor.fetchall()]
        conn.close()

        console.print(f"\n[bold]Replaying {len(attack_ids)} attacks from run: {run_id}[/bold]\n")

        results = []
        for idx, attack_id in enumerate(attack_ids, 1):
            console.print(f"[cyan]Replaying {idx}/{len(attack_ids)}...[/cyan]")
            result = self.replay_attack(attack_id)
            results.append(result)

            if idx < len(attack_ids):
                time.sleep(delay_seconds)

        return {"total": len(attack_ids), "results": results}


@click.command()
@click.option("--attack-id", type=int, help="Replay specific attack by ID")
@click.option("--run-id", type=str, help="Replay all attacks from a test run")
@click.option("--verify-only", is_flag=True, help="Show what would be replayed without executing")
@click.option("--delay", type=int, default=1, help="Delay between replays (seconds)")
def main(attack_id: Optional[int], run_id: Optional[str], verify_only: bool, delay: int):
    """Replay logged attacks from evidence database"""

    replayer = AttackReplayer()

    if attack_id:
        replayer.replay_attack(attack_id, verify_only=verify_only)
    elif run_id:
        replayer.replay_test_run(run_id, delay_seconds=delay)
    else:
        console.print("[red]Must specify either --attack-id or --run-id[/red]")
        sys.exit(1)


if __name__ == "__main__":
    main()
