#!/bin/sh

# Check if database is initialized
if [ ! -d "/var/lib/mysql/voapi" ]; then
    echo "Database not found. Initializing..."
    # Initialize MySQL data directory
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Start mysql for initialization
    /usr/bin/mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid="$!"
    # Wait for mysql to start
    sleep 10

    # Run initialization scripts
    mysql -u root < /docker-entrypoint-initdb.d/init-db.sql
    mysql -u root -e "CREATE USER 'voapi'@'localhost' IDENTIFIED BY 'voapi123';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON \`voapi%\`.* TO 'voapi'@'localhost';"
    mysql -u root -e "FLUSH PRIVILEGES;"

    # Stop mysql
    kill "$pid"
    # Wait for process to die
    wait "$pid"
    echo "Database initialized."
else
    echo "Database already initialized."
fi

# Start all services managed by supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
