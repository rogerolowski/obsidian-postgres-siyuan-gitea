FROM gitea/gitea:latest

# Install additional tools for health checks
RUN apk add --no-cache wget

# Create necessary directories
RUN mkdir -p /data/gitea/conf

# Copy custom configuration
COPY app.ini /data/gitea/conf/app.ini

# Set proper permissions
RUN chown -R git:git /data

# Expose ports
EXPOSE 3000 22

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/v1/version

# Default command
CMD ["/usr/bin/entrypoint", "/bin/s6-svscan", "/etc/s6"]
