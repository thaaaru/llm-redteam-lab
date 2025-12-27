#!/bin/bash

# ============================================================
# Reset LLM Red Team Lab
# Clears all evidence and logs, resets to clean state
# ============================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ⚠️  RESET RED TEAM LAB ⚠️"
echo "  This will DELETE all logs and evidence"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Are you sure you want to reset? (yes/NO): " -r
echo
if [[ ! $REPLY == "yes" ]]; then
    echo "Reset cancelled."
    exit 0
fi

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$LAB_DIR"

echo "[1/4] Stopping all services..."
./stop_lab.sh

echo "[2/4] Backing up evidence (if desired)..."
if [ -f evidence/redteam.db ]; then
    BACKUP_FILE="evidence/redteam_backup_$(date +%Y%m%d_%H%M%S).db"
    cp evidence/redteam.db "$BACKUP_FILE"
    echo "  ✓ Backup created: $BACKUP_FILE"
fi

echo "[3/4] Clearing evidence and logs..."
rm -f evidence/redteam.db
rm -f evidence/*.jsonl
rm -f evidence/*.log

echo "[4/4] Reinitializing database..."
source venv/bin/activate
sqlite3 evidence/redteam.db < logging/schema.sql

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Lab Reset Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "The lab is now in a clean state."
echo "To start: ./start_lab.sh"
echo ""
