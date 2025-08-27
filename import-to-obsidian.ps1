# Import GitHub/Gitea Repository to Obsidian Vault
# Usage: .\import-to-obsidian.ps1 -RepoUrl "https://github.com/user/repo" -VaultPath "C:\Users\$env:USERNAME\ObsidianVault"

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$VaultPath,
    
    [string]$SubfolderName = ""
)

$ErrorActionPreference = "Stop"

Write-Host "📚 Importing repository to Obsidian..." -ForegroundColor Green
Write-Host "Repository: $RepoUrl" -ForegroundColor Cyan
Write-Host "Vault Path: $VaultPath" -ForegroundColor Cyan

# Ensure vault directory exists
if (-not (Test-Path $VaultPath)) {
    Write-Host "📁 Creating Obsidian vault directory..." -ForegroundColor Blue
    New-Item -ItemType Directory -Path $VaultPath -Force | Out-Null
}

# Determine target directory
if ($SubfolderName) {
    $targetPath = Join-Path $VaultPath $SubfolderName
} else {
    $repoName = Split-Path $RepoUrl -Leaf -Resolve:$false
    $repoName = $repoName -replace '\.git$', ''
    $targetPath = Join-Path $VaultPath $repoName
}

Write-Host "🎯 Target path: $targetPath" -ForegroundColor Yellow

try {
    # Clone or update repository
    if (Test-Path $targetPath) {
        Write-Host "🔄 Repository exists, updating..." -ForegroundColor Blue
        Push-Location $targetPath
        git pull
        Pop-Location
    } else {
        Write-Host "📥 Cloning repository..." -ForegroundColor Blue
        git clone $RepoUrl $targetPath
    }
    
    # Create .obsidian folder if it doesn't exist (makes it a valid vault)
    $obsidianFolder = Join-Path $VaultPath ".obsidian"
    if (-not (Test-Path $obsidianFolder)) {
        Write-Host "⚙️ Creating Obsidian configuration..." -ForegroundColor Blue
        New-Item -ItemType Directory -Path $obsidianFolder -Force | Out-Null
        
        # Create basic Obsidian config
        $configPath = Join-Path $obsidianFolder "app.json"
        @{
            "livePreview" = $true
            "legacyEditor" = $false
            "showLineNumber" = $true
        } | ConvertTo-Json | Set-Content $configPath
    }
    
    Write-Host "✅ Repository imported to Obsidian vault!" -ForegroundColor Green
    Write-Host "📱 Open Obsidian and select vault: $VaultPath" -ForegroundColor Cyan
    
    # Count markdown files
    $markdownFiles = Get-ChildItem -Path $targetPath -Filter "*.md" -Recurse
    Write-Host "📄 Found $($markdownFiles.Count) markdown files" -ForegroundColor Yellow
    
} catch {
    Write-Host "❌ Error during import: $_" -ForegroundColor Red
}

Write-Host "🎉 Obsidian import completed!" -ForegroundColor Green
