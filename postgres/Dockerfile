FROM postgres:15-alpine

# Install additional tools for health checks
RUN apk add --no-cache postgresql-contrib

# Copy custom configuration
COPY postgresql.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf

# Set custom configuration for initialization
# Note: initdb doesn't use config-file, only runtime postgres does

# Create initialization script directory
RUN mkdir -p /docker-entrypoint-initdb.d

# Copy initialization scripts
COPY init/ /docker-entrypoint-initdb.d/

# Expose port
EXPOSE 5432

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
    CMD pg_isready -U obsidian_user -d obsidian_vault

# Default command
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
