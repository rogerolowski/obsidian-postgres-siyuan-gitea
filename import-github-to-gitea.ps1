# GitHub to Gitea Import Script
# Usage: .\import-github-to-gitea.ps1 -GithubUrl "https://github.com/user/repo" -GiteaRepoName "my-repo"

param(
    [Parameter(Mandatory=$true)]
    [string]$GithubUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$GiteaRepoName,
    
    [string]$GiteaUsername = "gitea-admin",
    [string]$GiteaUrl = "http://localhost:3000"
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Importing GitHub repository to local Gitea..." -ForegroundColor Green
Write-Host "GitHub URL: $GithubUrl" -ForegroundColor Cyan
Write-Host "Gitea Repo: $GiteaRepoName" -ForegroundColor Cyan

# Create temp directory
$tempDir = Join-Path $env:TEMP "gitea-import-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Write-Host "📁 Using temp directory: $tempDir" -ForegroundColor Yellow

try {
    # Step 1: Clone from GitHub
    Write-Host "📥 Cloning from GitHub..." -ForegroundColor Blue
    Push-Location $tempDir
    git clone $GithubUrl $GiteaRepoName
    Push-Location $GiteaRepoName
    
    # Step 2: Create repository in Gitea via API
    Write-Host "🏗️ Creating repository in Gitea..." -ForegroundColor Blue
    $createRepoPayload = @{
        name = $GiteaRepoName
        description = "Imported from $GithubUrl"
        private = $false
        auto_init = $false
    } | ConvertTo-Json
    
    $giteaApiUrl = "$GiteaUrl/api/v1/user/repos"
    Write-Host "ℹ️ You'll need to create the repository manually in Gitea web UI first," -ForegroundColor Yellow
    Write-Host "   or configure API token for automated creation." -ForegroundColor Yellow
    Write-Host "📱 Open: $GiteaUrl and create repository '$GiteaRepoName'" -ForegroundColor Green
    
    Read-Host "Press Enter after creating the repository in Gitea web UI..."
    
    # Step 3: Add Gitea remote and push
    Write-Host "🔗 Adding Gitea remote..." -ForegroundColor Blue
    $giteaRemoteUrl = "$GiteaUrl/$GiteaUsername/$GiteaRepoName.git"
    git remote add gitea $giteaRemoteUrl
    
    Write-Host "📤 Pushing to Gitea..." -ForegroundColor Blue
    git push gitea --all
    git push gitea --tags
    
    Write-Host "✅ Successfully imported repository to Gitea!" -ForegroundColor Green
    Write-Host "🌐 Access at: $GiteaUrl/$GiteaUsername/$GiteaRepoName" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Error during import: $_" -ForegroundColor Red
} finally {
    # Cleanup
    Pop-Location
    Pop-Location  
    Write-Host "🧹 Cleaning up temp directory..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
}

Write-Host "🎉 Import process completed!" -ForegroundColor Green
