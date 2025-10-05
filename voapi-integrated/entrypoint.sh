#!/bin/sh

# Check if the database directory is empty
if [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo "Database directory is empty. Initializing MariaDB..."
    # Initialize MariaDB data directory in the background
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql &
    install_pid="$!"

    # Wait for the installation to finish, keeping the container alive
    echo "Waiting for mariadb-install-db to finish..."
    wait "$install_pid"
    echo "mariadb-install-db finished."

    # Start mysqld temporarily to initialize users and databases
    /usr/bin/mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid="$!"
    
    # Wait for it to start
    sleep 10

    # Execute initialization SQL
    mariadb -u root < /docker-entrypoint-initdb.d/init-db.sql

    # Stop the temporary server
    kill "$pid"
    wait "$pid"
    echo "Database initialization complete."
else
    echo "Database already initialized."
fi

# Start all services managed by supervisord
echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
