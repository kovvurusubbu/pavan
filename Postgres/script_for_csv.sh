#!/bin/bash

# Backup folder
BACKUP_PATH="/home/test_devops/Downloads/pg_backup"
mkdir -p "$BACKUP_PATH"

# PostgreSQL connection details
PGHOST="Host"
PGUSER="user_name"
PGDATABASE="db_name"
PGPASSWORD='pwd_name'

export PGPASSWORD

# List of tables to export
TABLES=(
"activity_rating_master"
"agent_codes_masters"
"agent_docking_details"
"AGENTS_CHANNELMAPPING"
"agent_sequence"
"AGENTS_INFO"
"AGENTS_STOREMAPPING"
"agent_uuid_to_agent_code_mapping"
"amendment_order_details"
"ameyo_user_calls"
"d_limit"
"TION_INFO"
"CHANNEL_PARTNER_USER_INFO"
"channel_product_excel_error_log"
"channel_product_records"
"charges_master"
"CHECKLIST"
"claims_excel_error_log"
"claims_excel_records"
"claims_excel_upload_summary"
"coi_master"
"coi_master_test"
"coi_proposal_masters"
"coi_store_details"
"commission_coll"
"commission_completion_bulk_update_log"
"commission_incentive_error_log"
"commission_incentive_master"
"commission_incentive_master_history"
"commission_info"
"commissions_log"
"work_flow_details"
"workments_compensation_data"
)

# Export each table to CSV
for table in "${TABLES[@]}"; do
    # Remove extra spaces if any
    table=$(echo "$table" | xargs)
    echo "Exporting $table to CSV..."
    psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" \
        -c "\copy \"$table\" TO '$BACKUP_PATH/$table.csv' CSV HEADER"
done

echo "All tables exported to $BACKUP_PATH"
