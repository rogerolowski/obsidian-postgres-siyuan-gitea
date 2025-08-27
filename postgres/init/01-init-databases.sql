-- Initialize databases for Obsidian and Gitea
-- This script runs when the PostgreSQL container starts for the first time

-- Create Gitea database and user
CREATE DATABASE gitea;
CREATE USER gitea_user WITH PASSWORD 'gitea_password';
ALTER USER gitea_user CREATEDB;
GRANT ALL PRIVILEGES ON DATABASE gitea TO gitea_user;

-- Connect to gitea database and set up permissions
\c gitea;
GRANT ALL ON SCHEMA public TO gitea_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO gitea_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO gitea_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO gitea_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO gitea_user;

-- Create Obsidian vault database extensions
\c obsidian_vault;

-- Create extensions for Obsidian vault functionality
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- Create tables for Obsidian vault metadata (optional)
CREATE TABLE IF NOT EXISTS vault_metadata (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    file_path TEXT NOT NULL UNIQUE,
    file_name TEXT NOT NULL,
    file_size BIGINT,
    last_modified TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    tags TEXT[],
    metadata JSONB
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_vault_metadata_file_path ON vault_metadata USING gin(to_tsvector('english', file_path));
CREATE INDEX IF NOT EXISTS idx_vault_metadata_tags ON vault_metadata USING gin(tags);
CREATE INDEX IF NOT EXISTS idx_vault_metadata_metadata ON vault_metadata USING gin(metadata);

-- Grant permissions to obsidian_user
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO obsidian_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO obsidian_user;
GRANT ALL PRIVILEGES ON SCHEMA public TO obsidian_user;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO obsidian_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO obsidian_user;


