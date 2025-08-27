FROM alpine:latest

# Install necessary packages
RUN apk add --no-cache \
    git \
    bash \
    curl \
    jq \
    postgresql-client \
    && rm -rf /var/cache/apk/*

# Create obsidian user
RUN addgroup -g 1000 obsidian && \
    adduser -D -s /bin/bash -u 1000 -G obsidian obsidian

# Create directories
RUN mkdir -p /vault /scripts && \
    chown -R obsidian:obsidian /vault /scripts

# Copy sync scripts
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

# Switch to obsidian user
USER obsidian

# Set working directory
WORKDIR /vault

# Set environment variables
ENV VAULT_PATH=/vault
ENV GIT_REPO_URL=""
ENV GIT_USERNAME=""
ENV GIT_EMAIL=""

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD pgrep -f obsidian-sync

# Start sync service
CMD ["/scripts/sync.sh"]
