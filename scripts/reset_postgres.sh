#!/bin/bash

# BEWARE !!! Script has ability to drop/recreate all CDK databases
# Strongly recommended to run only for testing and not production use cases

# For testing, follow these steps:
# 1. kurtosis clean --all (clear existing resources)
# 2. update PGPASSWORD, PGUSER, and PGHOST params per your use case (modify configs)
# 3. run ./scripts/reset_postgres.sh (drop/recreate dbs and permissions)
# 4. kurtosis run --enclave cdk-v1 --args-file params.yml . (deploy with fresh dbs)
DB_NAMES=("madara_explorer_db")
DB_USERS=("madara_explorer_user")

# User must update credentials with master postgres IP/hostname and username
# TO DO: add env var support for credentials
PGPASSWORD='postgres'
PGUSER='postgres'
PGHOST='your_server_ip'
PGPORT=5432

for i in "${!DB_NAMES[@]}"; do
    DB_NAME="${DB_NAMES[$i]}"
    DB_USER="${DB_USERS[$i]}"

    # Initially connect as master postgres user to drop/recreate dbs
    PGPASSWORD="$PGPASSWORD" psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" <<EOF
    DROP DATABASE IF EXISTS "$DB_NAME";
    CREATE DATABASE "$DB_NAME";
    GRANT ALL PRIVILEGES ON DATABASE "$DB_NAME" TO "$DB_USER";
EOF

    # Connect to specific database for db initialization
    PGPASSWORD="$PGPASSWORD" psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB_NAME" <<EOF
    GRANT USAGE ON SCHEMA public TO "$DB_USER";
    GRANT CREATE ON SCHEMA public TO "$DB_USER";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "$DB_USER";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO "$DB_USER";
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "$DB_USER";
    GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "$DB_USER";
EOF

    echo "🟢  '$DB_NAME' reset, permissions granted for '$DB_USER'"
done
