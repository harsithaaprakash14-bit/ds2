# Smart Livestock AI - Direct GitHub REST API Push Script
# Run this after replacing YOUR_PAT_TOKEN below with your actual GitHub Personal Access Token
# Get token at: https://github.com/settings/tokens (select "repo" scope)

param(
    [Parameter(Mandatory=$true)]
    [string]$Token
)

$owner = "harsithaaprakash14-bit"
$repoName = "SMART-LIVESTOCK-AI"
$branch = "main"
$projectDir = "c:\Users\harsh\OneDrive\Desktop\ds2"

$headers = @{
    "Authorization" = "token $Token"
    "Accept"        = "application/vnd.github.v3+json"
    "User-Agent"    = "SmartLivestockAI-Deployer"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    SMART LIVESTOCK AI - GitHub Deployment (REST API)     " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Repository: https://github.com/$owner/$repoName" -ForegroundColor Yellow
Write-Host ""

# Verify token is valid
Write-Host "Verifying GitHub credentials..." -ForegroundColor Gray
try {
    $userInfo = Invoke-RestMethod -Uri "https://api.github.com/user" -Method Get -Headers $headers
    Write-Host "[OK] Authenticated as: $($userInfo.login)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Token verification failed. Please check your Personal Access Token." -ForegroundColor Red
    Write-Host "Get a token at: https://github.com/settings/tokens" -ForegroundColor Yellow
    exit 1
}

# Check if repo exists, create if not
Write-Host ""
Write-Host "Checking repository..." -ForegroundColor Gray
try {
    $repoInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repoName" -Method Get -Headers $headers
    Write-Host "[OK] Repository found: $($repoInfo.full_name)" -ForegroundColor Green
} catch {
    Write-Host "Repository not found. Creating it..." -ForegroundColor Yellow
    $createBody = @{
        "name"        = $repoName
        "description" = "Smart AI-Based Livestock Monitoring and Animal Classification System with Gender Detection"
        "private"     = $false
        "auto_init"   = $true
    } | ConvertTo-Json
    try {
        $newRepo = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method Post -Headers $headers -Body $createBody -ContentType "application/json"
        Write-Host "[OK] Repository created: $($newRepo.full_name)" -ForegroundColor Green
        Start-Sleep -Seconds 2
    } catch {
        Write-Host "[ERROR] Could not create repository: $_" -ForegroundColor Red
        exit 1
    }
}

# Files to upload
$filesToUpload = @(
    "index.html",
    "styles.css",
    "app.js",
    "app.py",
    "start_server.ps1",
    "README.md"
)

Write-Host ""
Write-Host "Starting file uploads..." -ForegroundColor Cyan
Write-Host "--------------------------------------------------------" -ForegroundColor Gray

$success = 0
$failed  = 0

foreach ($file in $filesToUpload) {
    $filePath = Join-Path $projectDir $file

    if (-not (Test-Path $filePath)) {
        Write-Host "[SKIP] $file not found in workspace." -ForegroundColor Yellow
        continue
    }

    Write-Host "Uploading: $file ..." -NoNewline -ForegroundColor Gray

    # Read and encode file
    $fileBytes  = [System.IO.File]::ReadAllBytes($filePath)
    $fileBase64 = [System.Convert]::ToBase64String($fileBytes)

    # Get existing SHA if file already exists in the repo (needed for update)
    $apiUrl = "https://api.github.com/repos/$owner/$repoName/contents/$file"
    $sha = $null
    try {
        $existing = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers -ErrorAction SilentlyContinue
        $sha = $existing.sha
    } catch {}

    $bodyHash = @{
        "message" = "chore: upload $file - Smart AI Livestock Monitoring System with Gender Detection"
        "content" = $fileBase64
        "branch"  = $branch
    }
    if ($sha) { $bodyHash["sha"] = $sha }

    $jsonBody = ConvertTo-Json -InputObject $bodyHash -Depth 10

    try {
        $null = Invoke-RestMethod -Uri $apiUrl -Method Put -Headers $headers -Body $jsonBody -ContentType "application/json"
        Write-Host " [SUCCESS]" -ForegroundColor Green
        $success++
    } catch {
        Write-Host " [FAILED] $_" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Upload Complete: $success succeeded, $failed failed     " -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })
Write-Host "  View your repo: https://github.com/$owner/$repoName     " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

if ($success -gt 0) {
    Start-Process "https://github.com/$owner/$repoName"
}
