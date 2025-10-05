#!/bin/sh
# wait-for-services.sh

# Wait for MySQL
echo "Waiting for MySQL to be ready..."
while ! nc -z 127.0.0.1 3306; do   
  sleep 1 # wait for 1 second before check again
done
echo "MySQL is ready."

# Wait for Redis
echo "Waiting for Redis to be ready..."
while ! nc -z 127.0.0.1 6379; do
  sleep 1
done
echo "Redis is ready."

# Execute the main command
exec "$@"
