# Stage 1: Extract the application from the official image
FROM voapi/voapi:latest AS extractor
RUN mkdir -p /extracted
RUN cp /voapi /extracted/voapi

# Stage 2: Create the final integrated image
FROM alpine:latest

# Install dependencies: mysql, redis, supervisor
RUN apk add --no-cache mysql mysql-client redis supervisor netcat-openbsd

# Create necessary directories
RUN mkdir -p /app /var/lib/mysql /var/run/mysqld /public /file /docker-entrypoint-initdb.d
RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# Copy the application from the extractor stage
COPY --from=extractor /extracted/voapi /app/voapi

# Copy configuration and initialization files
COPY config.yml /app/config.yml
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY init-db.sql /docker-entrypoint-initdb.d/init-db.sql
COPY entrypoint.sh /entrypoint.sh
COPY wait-for-services.sh /wait-for-services.sh
RUN chmod +x /entrypoint.sh /wait-for-services.sh

# Expose the application port
EXPOSE 6800

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
