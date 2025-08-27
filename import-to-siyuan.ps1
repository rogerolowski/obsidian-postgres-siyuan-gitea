# Import GitHub/Gitea Repository to SiYuan
# Usage: .\import-to-siyuan.ps1 -RepoUrl "https://github.com/user/repo" -NotebookName "MyProject"

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$NotebookName,
    
    [string]$SiYuanWorkspace = ".\siyuan\workspace"
)

$ErrorActionPreference = "Stop"

Write-Host "🧠 Importing repository to SiYuan..." -ForegroundColor Green
Write-Host "Repository: $RepoUrl" -ForegroundColor Cyan
Write-Host "Notebook: $NotebookName" -ForegroundColor Cyan

# Ensure SiYuan workspace exists
$workspacePath = Resolve-Path $SiYuanWorkspace -ErrorAction SilentlyContinue
if (-not $workspacePath) {
    Write-Host "❌ SiYuan workspace not found at: $SiYuanWorkspace" -ForegroundColor Red
    Write-Host "💡 Make sure SiYuan is running: docker compose up -d siyuan" -ForegroundColor Yellow
    return
}

$dataPath = Join-Path $workspacePath "data"
$notebookPath = Join-Path $dataPath $NotebookName

Write-Host "🎯 Target notebook path: $notebookPath" -ForegroundColor Yellow

try {
    # Create temp directory for cloning
    $tempDir = Join-Path $env:TEMP "siyuan-import-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    # Clone repository to temp
    Write-Host "📥 Cloning repository..." -ForegroundColor Blue
    $repoName = Split-Path $RepoUrl -Leaf -Resolve:$false -replace '\.git$', ''
    $tempRepoPath = Join-Path $tempDir $repoName
    git clone $RepoUrl $tempRepoPath
    
    # Create notebook directory
    if (-not (Test-Path $dataPath)) {
        New-Item -ItemType Directory -Path $dataPath -Force | Out-Null
    }
    
    if (Test-Path $notebookPath) {
        Write-Host "⚠️ Notebook already exists. Merging content..." -ForegroundColor Yellow
    } else {
        Write-Host "📁 Creating new notebook..." -ForegroundColor Blue
        New-Item -ItemType Directory -Path $notebookPath -Force | Out-Null
    }
    
    # Convert and copy markdown files
    Write-Host "🔄 Converting markdown files for SiYuan..." -ForegroundColor Blue
    $markdownFiles = Get-ChildItem -Path $tempRepoPath -Filter "*.md" -Recurse
    $convertedCount = 0
    
    foreach ($file in $markdownFiles) {
        $relativePath = $file.FullName.Substring($tempRepoPath.Length + 1)
        $targetFile = Join-Path $notebookPath $relativePath
        $targetDir = Split-Path $targetFile -Parent
        
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }
        
        # Copy markdown file (SiYuan can handle markdown directly)
        Copy-Item $file.FullName $targetFile -Force
        $convertedCount++
    }
    
    # Copy other relevant files (images, etc.)
    $assetExtensions = @("*.png", "*.jpg", "*.jpeg", "*.gif", "*.svg", "*.pdf")
    foreach ($extension in $assetExtensions) {
        $assetFiles = Get-ChildItem -Path $tempRepoPath -Filter $extension -Recurse
        foreach ($asset in $assetFiles) {
            $relativePath = $asset.FullName.Substring($tempRepoPath.Length + 1)
            $targetFile = Join-Path $notebookPath $relativePath
            $targetDir = Split-Path $targetFile -Parent
            
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            
            Copy-Item $asset.FullName $targetFile -Force
        }
    }
    
    # Create notebook configuration
    $configPath = Join-Path $notebookPath ".siyuan"
    if (-not (Test-Path $configPath)) {
        New-Item -ItemType Directory -Path $configPath -Force | Out-Null
        
        $configFile = Join-Path $configPath "conf.json"
        @{
            "name" = $NotebookName
            "closed" = $false
            "refCreateSavePath" = ""
            "createDocNameTemplate" = ""
            "dailyNoteSavePath" = "/daily note/{{now | date \"2006/01\"}}"
            "dailyNoteTemplatePath" = ""
        } | ConvertTo-Json -Depth 3 | Set-Content $configFile
    }
    
    Write-Host "✅ Repository imported to SiYuan!" -ForegroundColor Green
    Write-Host "📊 Converted $convertedCount markdown files" -ForegroundColor Yellow
    Write-Host "📱 Access SiYuan at: http://localhost:6806" -ForegroundColor Cyan
    Write-Host "🔄 Refresh SiYuan to see the new notebook" -ForegroundColor Yellow
    
    # Cleanup
    Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
    
} catch {
    Write-Host "❌ Error during import: $_" -ForegroundColor Red
}

Write-Host "🎉 SiYuan import completed!" -ForegroundColor Green

# Instructions for user
Write-Host "" -ForegroundColor White
Write-Host "📋 Next steps:" -ForegroundColor Blue
Write-Host "  1. Open SiYuan: http://localhost:6806" -ForegroundColor White
Write-Host "  2. Enter access code: siyuan123" -ForegroundColor White
Write-Host "  3. Look for '$NotebookName' in the notebook list" -ForegroundColor White
Write-Host "  4. If not visible, restart SiYuan container: docker compose restart siyuan" -ForegroundColor White
