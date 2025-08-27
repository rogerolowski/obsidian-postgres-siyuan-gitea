# Master Import Script - Import GitHub repo to Gitea, Obsidian, and SiYuan
# Usage: .\import-repo-everywhere.ps1 -GithubUrl "https://github.com/user/repo" -ProjectName "MyProject"

param(
    [Parameter(Mandatory=$true)]
    [string]$GithubUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [string]$ObsidianVaultPath = "C:\Users\$env:USERNAME\ObsidianVault\$ProjectName",
    [string]$GiteaUsername = "gitea-admin",
    [string]$SkipPlatforms = "" # Options: "gitea", "obsidian", "siyuan" (comma-separated)
)

$ErrorActionPreference = "Stop"

Write-Host "🌟 Master Import: GitHub → Gitea + Obsidian + SiYuan" -ForegroundColor Magenta
Write-Host "📡 Source: $GithubUrl" -ForegroundColor Cyan
Write-Host "📦 Project: $ProjectName" -ForegroundColor Cyan

$skipList = $SkipPlatforms -split ',' | ForEach-Object { $_.Trim().ToLower() }

# 1. Import to Gitea
if ("gitea" -notin $skipList) {
    Write-Host "" -ForegroundColor White
    Write-Host "🔵 [1/3] Importing to Gitea..." -ForegroundColor Blue
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    
    try {
        # Use Gitea's built-in migration feature
        Write-Host "🌐 Opening Gitea for manual import..." -ForegroundColor Yellow
        Start-Process "http://localhost:3000/repo/migrate"
        
        Write-Host "📋 Manual steps for Gitea:" -ForegroundColor Green
        Write-Host "  1. Login with: gitea-admin / admin123" -ForegroundColor White
        Write-Host "  2. Select 'GitHub' as source" -ForegroundColor White
        Write-Host "  3. Enter GitHub URL: $GithubUrl" -ForegroundColor White
        Write-Host "  4. Set Repository Name: $ProjectName" -ForegroundColor White
        Write-Host "  5. Click 'Migrate Repository'" -ForegroundColor White
        
        Read-Host "Press Enter after completing Gitea migration..."
        Write-Host "✅ Gitea import completed!" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Gitea import failed: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "⏭️ Skipping Gitea import" -ForegroundColor Gray
}

# 2. Import to Obsidian  
if ("obsidian" -notin $skipList) {
    Write-Host "" -ForegroundColor White
    Write-Host "🔵 [2/3] Importing to Obsidian..." -ForegroundColor Blue
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    
    try {
        # Ensure vault directory exists
        $vaultDir = Split-Path $ObsidianVaultPath -Parent
        if (-not (Test-Path $vaultDir)) {
            New-Item -ItemType Directory -Path $vaultDir -Force | Out-Null
        }
        
        # Clone repository to Obsidian vault
        if (Test-Path $ObsidianVaultPath) {
            Write-Host "🔄 Repository exists in Obsidian, updating..." -ForegroundColor Yellow
            Push-Location $ObsidianVaultPath
            git pull
            Pop-Location
        } else {
            Write-Host "📥 Cloning to Obsidian vault..." -ForegroundColor Blue
            git clone $GithubUrl $ObsidianVaultPath
        }
        
        # Create .obsidian config if needed
        $obsidianConfigPath = Join-Path (Split-Path $ObsidianVaultPath -Parent) ".obsidian"
        if (-not (Test-Path $obsidianConfigPath)) {
            New-Item -ItemType Directory -Path $obsidianConfigPath -Force | Out-Null
            @{
                "livePreview" = $true
                "readableLineLength" = $true
                "showLineNumber" = $true
            } | ConvertTo-Json | Set-Content (Join-Path $obsidianConfigPath "app.json")
        }
        
        $mdCount = (Get-ChildItem -Path $ObsidianVaultPath -Filter "*.md" -Recurse).Count
        Write-Host "✅ Obsidian import completed! ($mdCount markdown files)" -ForegroundColor Green
        Write-Host "📱 Open Obsidian and select vault: $(Split-Path $ObsidianVaultPath -Parent)" -ForegroundColor Cyan
        
    } catch {
        Write-Host "⚠️ Obsidian import failed: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "⏭️ Skipping Obsidian import" -ForegroundColor Gray
}

# 3. Import to SiYuan
if ("siyuan" -notin $skipList) {
    Write-Host "" -ForegroundColor White
    Write-Host "🔵 [3/3] Importing to SiYuan..." -ForegroundColor Blue
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    
    try {
        $siyuanWorkspace = ".\siyuan\workspace"
        $workspacePath = Resolve-Path $siyuanWorkspace -ErrorAction SilentlyContinue
        
        if (-not $workspacePath) {
            Write-Host "⚠️ SiYuan workspace not found. Starting SiYuan..." -ForegroundColor Yellow
            docker compose up -d siyuan
            Start-Sleep 10
            $workspacePath = Resolve-Path $siyuanWorkspace -ErrorAction SilentlyContinue
        }
        
        if ($workspacePath) {
            # Create temp directory for cloning
            $tempDir = Join-Path $env:TEMP "siyuan-import-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            
            # Clone and process
            $repoName = Split-Path $GithubUrl -Leaf -Resolve:$false -replace '\.git$', ''
            $tempRepoPath = Join-Path $tempDir $repoName
            git clone $GithubUrl $tempRepoPath
            
            # Create SiYuan notebook
            $dataPath = Join-Path $workspacePath "data"
            $notebookPath = Join-Path $dataPath $ProjectName
            
            if (-not (Test-Path $dataPath)) {
                New-Item -ItemType Directory -Path $dataPath -Force | Out-Null
            }
            New-Item -ItemType Directory -Path $notebookPath -Force | Out-Null
            
            # Copy markdown and asset files
            $markdownFiles = Get-ChildItem -Path $tempRepoPath -Filter "*.md" -Recurse
            foreach ($file in $markdownFiles) {
                $relativePath = $file.FullName.Substring($tempRepoPath.Length + 1)
                $targetFile = Join-Path $notebookPath $relativePath
                $targetDir = Split-Path $targetFile -Parent
                
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                }
                Copy-Item $file.FullName $targetFile -Force
            }
            
            # Create notebook config
            $configPath = Join-Path $notebookPath ".siyuan"
            New-Item -ItemType Directory -Path $configPath -Force | Out-Null
            @{
                "name" = $ProjectName
                "closed" = $false
            } | ConvertTo-Json | Set-Content (Join-Path $configPath "conf.json")
            
            Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
            
            Write-Host "✅ SiYuan import completed! ($($markdownFiles.Count) files)" -ForegroundColor Green
            Write-Host "📱 Access SiYuan: http://localhost:6806 (code: siyuan123)" -ForegroundColor Cyan
            
        } else {
            Write-Host "❌ Could not access SiYuan workspace" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "⚠️ SiYuan import failed: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "⏭️ Skipping SiYuan import" -ForegroundColor Gray
}

# Summary
Write-Host "" -ForegroundColor White
Write-Host "🎉 IMPORT COMPLETE!" -ForegroundColor Magenta
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
Write-Host "📊 Project '$ProjectName' imported from:" -ForegroundColor White
Write-Host "   🔗 $GithubUrl" -ForegroundColor Cyan

Write-Host "" -ForegroundColor White
Write-Host "🌐 Access your project:" -ForegroundColor Blue
if ("gitea" -notin $skipList) {
    Write-Host "   📂 Gitea:    http://localhost:3000/$GiteaUsername/$ProjectName" -ForegroundColor White
}
if ("obsidian" -notin $skipList) {
    Write-Host "   📝 Obsidian: $ObsidianVaultPath" -ForegroundColor White
}
if ("siyuan" -notin $skipList) {
    Write-Host "   🧠 SiYuan:   http://localhost:6806 (notebook: $ProjectName)" -ForegroundColor White
}

Write-Host "" -ForegroundColor White
Write-Host "💡 Tip: Use 'kstatus' to check container health" -ForegroundColor Yellow
