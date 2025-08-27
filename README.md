# Obsidian + PostgreSQL + Siyuan + Redis + Gitea Docker Environment

A comprehensive Docker Compose setup for managing knowledge with Obsidian, PostgreSQL for vault storage, Siyuan for knowledge management, Redis for caching, and Gitea for Git repository management.

## Services Overview

### 🐘 PostgreSQL (Port 5432)
- **Purpose**: Database backend for Obsidian vault metadata and Gitea
- **Features**: 
  - Optimized configuration for Obsidian vault storage
  - Full-text search capabilities with pg_trgm extension
  - JSONB support for flexible metadata storage
  - Health checks and monitoring

### 🔴 Redis (Port 6379)
- **Purpose**: Caching and session management
- **Features**:
  - Optimized memory management
  - Persistence with AOF and RDB
  - Health monitoring

### 🐙 Gitea (Port 3000, SSH: 222)
- **Purpose**: Self-hosted Git service for vault version control
- **Features**:
  - PostgreSQL backend
  - SSH access for Git operations
  - Web interface for repository management
  - Health checks

### 📚 Siyuan (Port 6806)
- **Purpose**: Knowledge management and note-taking system
- **Features**:
  - Markdown-based notes
  - Knowledge graph visualization
  - Plugin ecosystem
  - Health monitoring

### 🔄 Obsidian Sync Service
- **Purpose**: Automated synchronization of Obsidian vaults
- **Features**:
  - Git-based version control
  - Automatic commit and push
  - Conflict resolution
  - Health monitoring

## Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM available
- 10GB+ disk space

## Quick Start

1. **Clone or download this repository**
   ```bash
   git clone <repository-url>
   cd obsidian-postgres-siyuan-gitea
   ```

2. **Start all services**
   ```bash
   docker-compose up -d
   ```

3. **Access services**
   - **Gitea**: http://localhost:3000
   - **Siyuan**: http://localhost:6806
   - **PostgreSQL**: localhost:5432
   - **Redis**: localhost:6379

## Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
# PostgreSQL
POSTGRES_DB=obsidian_vault
POSTGRES_USER=obsidian_user
POSTGRES_PASSWORD=obsidian_password

# Gitea
GITEA_DB_NAME=gitea
GITEA_DB_USER=gitea_user
GITEA_DB_PASSWORD=gitea_password

# Obsidian Sync
GIT_REPO_URL=https://your-gitea-instance.com/user/vault.git
GIT_USERNAME=your-username
GIT_EMAIL=your-email@example.com
```

### Service Dependencies

The services start in the following order with health checks:

1. **PostgreSQL** - Database backend
2. **Redis** - Caching layer
3. **Gitea** - Waits for PostgreSQL to be healthy
4. **Siyuan** - Independent service
5. **Obsidian Sync** - Waits for Gitea and PostgreSQL to be healthy

## Usage

### Setting up Obsidian Vault

1. **Create a new repository in Gitea**
   - Access Gitea at http://localhost:3000
   - Create a new repository for your Obsidian vault

2. **Configure Obsidian Sync Service**
   - Update the `.env` file with your Gitea repository URL
   - Restart the obsidian-sync service

3. **Access your vault**
   - The vault will be automatically synchronized
   - Use Obsidian desktop app to open the vault folder

### Database Access

**PostgreSQL Connection:**
```bash
docker exec -it obsidian-postgres psql -U obsidian_user -d obsidian_vault
```

**Redis CLI:**
```bash
docker exec -it obsidian-redis redis-cli
```

### Backup and Restore

**PostgreSQL Backup:**
```bash
docker exec obsidian-postgres pg_dump -U obsidian_user obsidian_vault > backup.sql
```

**PostgreSQL Restore:**
```bash
docker exec -i obsidian-postgres psql -U obsidian_user -d obsidian_vault < backup.sql
```

## Health Checks

All services include health checks:

- **PostgreSQL**: `pg_isready` command
- **Redis**: `redis-cli ping` command
- **Gitea**: HTTP API endpoint check
- **Siyuan**: HTTP API endpoint check
- **Obsidian Sync**: Process monitoring

## Monitoring

### Service Status
```bash
docker-compose ps
```

### Service Logs
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs postgres
docker-compose logs gitea
docker-compose logs siyuan
```

### Health Check Status
```bash
docker inspect --format='{{.State.Health.Status}}' obsidian-postgres
docker inspect --format='{{.State.Health.Status}}' obsidian-redis
docker inspect --format='{{.State.Health.Status}}' obsidian-gitea
docker inspect --format='{{.State.Health.Status}}' obsidian-siyuan
docker inspect --format='{{.State.Health.Status}}' obsidian-sync
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 5432, 6379, 3000, 6806, and 222 are available
2. **Permission issues**: Check file permissions in mounted volumes
3. **Database connection**: Verify PostgreSQL is healthy before starting dependent services

### Reset Environment

```bash
# Stop and remove all containers
docker-compose down

# Remove all volumes (WARNING: This will delete all data)
docker-compose down -v

# Rebuild and start
docker-compose up --build -d
```

## Security Considerations

- Change default passwords in production
- Use strong passwords for database users
- Consider enabling SSL for database connections
- Restrict network access to services
- Regular security updates

## Performance Tuning

### PostgreSQL
- Adjust `shared_buffers` and `effective_cache_size` based on available RAM
- Monitor query performance with `log_min_duration_statement`

### Redis
- Adjust `maxmemory` based on available RAM
- Monitor memory usage and eviction policies

### Gitea
- Configure appropriate worker processes
- Monitor repository size and cleanup old repositories

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `docker-compose up --build`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Check the troubleshooting section
- Review service logs
- Open an issue on the repository


