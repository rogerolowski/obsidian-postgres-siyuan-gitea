#!/bin/bash

# Obsidian Vault Sync Script
# This script handles synchronization of Obsidian vaults with Git repositories

set -e

# Configuration
VAULT_PATH="${VAULT_PATH:-/vault}"
GIT_REPO_URL="${GIT_REPO_URL:-}"
GIT_USERNAME="${GIT_USERNAME:-}"
GIT_EMAIL="${GIT_EMAIL:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

# Check if vault directory exists
if [ ! -d "$VAULT_PATH" ]; then
    error "Vault directory $VAULT_PATH does not exist"
    exit 1
fi

cd "$VAULT_PATH"

# Initialize Git repository if it doesn't exist
if [ ! -d ".git" ]; then
    if [ -n "$GIT_REPO_URL" ]; then
        log "Cloning repository from $GIT_REPO_URL"
        git clone "$GIT_REPO_URL" .
    else
        log "Initializing new Git repository"
        git init
        
        # Configure Git user if provided
        if [ -n "$GIT_USERNAME" ]; then
            git config user.name "$GIT_USERNAME"
        fi
        if [ -n "$GIT_EMAIL" ]; then
            git config user.email "$GIT_EMAIL"
        fi
        
        # Create initial commit
        git add .
        git commit -m "Initial commit: Obsidian vault setup"
    fi
fi

# Function to sync vault
sync_vault() {
    log "Starting vault synchronization..."
    
    # Check for changes
    if git diff-index --quiet HEAD --; then
        log "No changes detected"
        return 0
    fi
    
    # Add all changes
    git add .
    
    # Check if there are staged changes
    if git diff --cached --quiet; then
        log "No changes to commit"
        return 0
    fi
    
    # Commit changes
    COMMIT_MSG="Auto-sync: $(date +'%Y-%m-%d %H:%M:%S')"
    git commit -m "$COMMIT_MSG"
    
    # Push to remote if origin exists
    if git remote get-url origin >/dev/null 2>&1; then
        log "Pushing changes to remote repository"
        git push origin main || git push origin master || warn "Failed to push to remote"
    else
        log "No remote repository configured"
    fi
    
    log "Synchronization completed successfully"
}

# Function to pull changes from remote
pull_changes() {
    if git remote get-url origin >/dev/null 2>&1; then
        log "Pulling changes from remote repository"
        git pull origin main || git pull origin master || warn "Failed to pull from remote"
    fi
}

# Main sync loop
log "Obsidian sync service started"
log "Vault path: $VAULT_PATH"
log "Git repository: $GIT_REPO_URL"

# Initial pull
pull_changes

# Continuous sync loop
while true; do
    # Sync vault
    sync_vault
    
    # Wait before next sync
    log "Waiting 60 seconds before next sync..."
    sleep 60
done


