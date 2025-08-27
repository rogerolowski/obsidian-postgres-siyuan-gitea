FROM alpine:latest

# Install necessary packages
RUN apk add --no-cache \
    wget \
    unzip \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# Set environment variables
ENV SIYUAN_VERSION=2.10.0
ENV SIYUAN_PORT=6806

# Create siyuan user and directory
RUN addgroup -g 1000 siyuan && \
    adduser -D -s /bin/sh -u 1000 -G siyuan siyuan

# Download and install Siyuan
RUN wget -O /tmp/siyuan.zip https://github.com/siyuan-note/siyuan/releases/download/v${SIYUAN_VERSION}/siuan-${SIYUAN_VERSION}-linux-amd64.zip && \
    unzip /tmp/siyuan.zip -d /opt/ && \
    rm /tmp/siyuan.zip && \
    chown -R siyuan:siyuan /opt/siyuan

# Create workspace directory
RUN mkdir -p /siyuan/workspace && \
    chown -R siyuan:siyuan /siyuan

# Switch to siyuan user
USER siyuan

# Set working directory
WORKDIR /siyuan

# Expose port
EXPOSE ${SIYUAN_PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${SIYUAN_PORT}/api/system/getVersion

# Start Siyuan
CMD ["/opt/siyuan/siyuan", "--workspace", "/siyuan/workspace", "--port", "${SIYUAN_PORT}"]
