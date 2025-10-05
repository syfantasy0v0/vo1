#!/bin/sh

# Check if the 'voapi' database has been created.
if [ ! -d "/var/lib/mysql/voapi" ]; then
    echo "Database 'voapi' not found. Creating user and databases..."
    
    # Start mysqld temporarily to initialize users and databases
    /usr/bin/mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid="$!"
    
    # Wait for it to start
    echo "Waiting for temporary MariaDB server to start..."
    sleep 5

    # Execute initialization SQL
    echo "Executing init-db.sql..."
    mariadb -u root < /docker-entrypoint-initdb.d/init-db.sql
    
    # Stop the temporary server
    echo "Stopping temporary MariaDB server..."
    kill "$pid"
    wait "$pid"
    echo "User and database creation complete."
else
    echo "Database 'voapi' already exists. Skipping initialization."
fi

# Start all services managed by supervisord
echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
