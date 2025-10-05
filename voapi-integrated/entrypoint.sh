#!/bin/sh

# Check if the database directory is empty
if [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo "Database directory is empty. Initializing MariaDB..."
    # Initialize MariaDB data directory
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start mysqld temporarily to initialize users and databases
    /usr/bin/mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid="$!"
    
    # Wait for it to start
    sleep 10

    # Execute initialization SQL
    mysql -u root < /docker-entrypoint-initdb.d/init-db.sql
    
    # Create user specifically for localhost
    mysql -u root -e "CREATE USER 'voapi'@'localhost' IDENTIFIED BY 'voapi123';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON \`voapi%\`.* TO 'voapi'@'localhost';"
    mysql -u root -e "FLUSH PRIVILEGES;"

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
