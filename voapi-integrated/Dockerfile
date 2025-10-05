# Stage 1: Extract the application from the official image
FROM voapi/voapi:latest AS extractor
RUN mkdir -p /extracted
RUN cp /voapi /extracted/voapi && \
    cp -r /public /extracted/public && \
    cp -r /file /extracted/file

# Stage 2: Create the final integrated image
FROM alpine:latest

# Install dependencies: mysql, redis, supervisor
RUN apk add --no-cache mysql mysql-client redis supervisor

# Create necessary directories
RUN mkdir -p /app /var/lib/mysql /var/run/mysqld /public /file /docker-entrypoint-initdb.d
RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# Copy the application and assets from the extractor stage
COPY --from=extractor /extracted/voapi /app/voapi
COPY --from=extractor /extracted/public /public
COPY --from=extractor /extracted/file /file

# Copy configuration and initialization files
COPY config.yml /config.yml
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY init-db.sql /docker-entrypoint-initdb.d/init-db.sql
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose the application port
EXPOSE 6800

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
