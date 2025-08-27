# Docker Management Aliases for Knowledge Stack
# Usage: . ./docker-aliases.ps1

# Knowledge Stack Management
function Start-KnowledgeStack { 
    Write-Host "🚀 Starting Knowledge Management Stack..." -ForegroundColor Green
    docker compose up -d 
}

function Stop-KnowledgeStack { 
    Write-Host "🛑 Stopping Knowledge Management Stack..." -ForegroundColor Yellow
    docker compose down 
}

function Status-KnowledgeStack { 
    Write-Host "📊 Knowledge Stack Status:" -ForegroundColor Cyan
    docker compose ps 
}

function Logs-KnowledgeStack { 
    param([string]$Service = "")
    if ($Service) {
        docker compose logs -f $Service
    } else {
        docker compose logs -f
    }
}

# Individual Service Management
function Restart-Gitea { docker compose restart gitea }
function Restart-SiYuan { docker compose restart siyuan }
function Restart-Postgres { docker compose restart postgres }
function Restart-Redis { docker compose restart redis }

# Container Access
function Enter-Gitea { docker exec -it obsidian-gitea bash }
function Enter-SiYuan { docker exec -it obsidian-siyuan bash }
function Enter-Postgres { docker exec -it obsidian-postgres psql -U obsidian_user -d obsidian_vault }
function Enter-Redis { docker exec -it obsidian-redis redis-cli }

# System Management
function Show-ContainerStats { 
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.Status}}"
}

function Clean-Docker { 
    Write-Host "🧹 Cleaning unused Docker resources..." -ForegroundColor Magenta
    docker system prune -f 
}

function Show-ProjectContainers {
    Write-Host "📦 Project Containers:" -ForegroundColor Blue
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | Where-Object { $_ -match "obsidian-|hostel_" }
}

# Aliases
Set-Alias kstart Start-KnowledgeStack
Set-Alias kstop Stop-KnowledgeStack  
Set-Alias kstatus Status-KnowledgeStack
Set-Alias klogs Logs-KnowledgeStack
Set-Alias dstats Show-ContainerStats
Set-Alias dclean Clean-Docker

Write-Host "✅ Docker aliases loaded! Available commands:" -ForegroundColor Green
Write-Host "  kstart    - Start knowledge stack" -ForegroundColor White
Write-Host "  kstop     - Stop knowledge stack" -ForegroundColor White  
Write-Host "  kstatus   - Show stack status" -ForegroundColor White
Write-Host "  klogs     - View logs (klogs gitea)" -ForegroundColor White
Write-Host "  dstats    - Show container stats" -ForegroundColor White
Write-Host "  dclean    - Clean unused resources" -ForegroundColor White
Write-Host "  Enter-Gitea, Enter-SiYuan, etc." -ForegroundColor White
