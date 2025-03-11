#!/bin/bash
#Restore script

docker compose down -v  # CAUTION! Deletes all Immich data to start from scratch
## Uncomment the next line and replace DB_DATA_LOCATION with your Postgres path to permanently reset the Postgres database
# rm -rf DB_DATA_LOCATION # CAUTION! Deletes all Immich data to start from scratch
docker compose pull  # Update to latest version of Immich (if desired)
docker compose create  # Create Docker containers for Immich apps without running them
docker start immich_postgres  # Start Postgres server
sleep 10  # Wait for Postgres server to start up
# Check the database user if you deviated from the default
sudo gunzip < "/PATH/TO/DB_BACKUP/immich_db_2025-01-01_00-00-00.sql.gz" \
| sed "s/SELECT pg_catalog.set_config('search_path', '', false);/SELECT pg_catalog.set_config('search_path', 'public, pg_catalog', true);/g" \
| sudo docker exec -i immich_postgres psql --dbname=postgres --username=postgres  # Restore Backup
docker compose up -d            # Start remainder of Immich apps
