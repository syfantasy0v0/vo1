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

# Now, wait for the voapi application to be ready
echo "Starting voapi and waiting for it to be ready..."
# Start the application in the background
"$@" &
app_pid="$!"

# Wait for the app to respond on port 6800
while ! wget -q -T 1 -O /dev/null http://127.0.0.1:6800; do
    # Check if the background process is still alive
    if ! kill -0 "$app_pid" 2>/dev/null; then
        echo "voapi application failed to start."
        exit 1
    fi
    echo "Waiting for voapi to respond on port 6800..."
    sleep 1
done

echo "voapi is ready and responding."

# Bring the application process to the foreground
wait "$app_pid"
