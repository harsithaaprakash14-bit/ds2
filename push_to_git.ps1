# FarmVision AI - Git Repository Deployment Script
# Automatically detects git installation and handles repository synchronization.
# If Git CLI is not installed locally, it offers a secure fallback to upload code directly using the GitHub REST API.
# Also renames the GitHub repository from SMART-LIVESTOCK-AI to FarmVision-AI.

$owner       = "harsithaaprakash14-bit"
$oldRepoName = "SMART-LIVESTOCK-AI"
$newRepoName = "FarmVision-AI"
$repoUrl     = "https://github.com/$owner/$newRepoName.git"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "            FARMVISION AI DEPLOYMENT SYSTEM               " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "  1. Rename the GitHub repo from '$oldRepoName' to '$newRepoName'" -ForegroundColor Yellow
Write-Host "  2. Push all updated project files to the new repo" -ForegroundColor Yellow
Write-Host ""
Write-Host "You will need a GitHub Personal Access Token (PAT) with 'repo' scope." -ForegroundColor Gray
Write-Host "Get a token here: https://github.com/settings/tokens" -ForegroundColor Gray
Write-Host "--------------------------------------------------------" -ForegroundColor Cyan

$token = Read-Host -Prompt "Please enter your GitHub Personal Access Token (PAT)"
if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "[ERROR] Token cannot be empty. Aborting." -ForegroundColor Red
    exit
}

$headers = @{
    "Authorization" = "token $token"
    "Accept"        = "application/vnd.github.v3+json"
    "Content-Type"  = "application/json"
}

# ─────────────────────────────────────────────────────────────
# STEP 1: Rename the GitHub repository via API
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[STEP 1] Renaming GitHub repo '$oldRepoName' → '$newRepoName'..." -ForegroundColor Cyan

$renameBody = @{ "name" = $newRepoName } | ConvertTo-Json
$renameUrl  = "https://api.github.com/repos/$owner/$oldRepoName"

try {
    $renameResult = Invoke-RestMethod -Uri $renameUrl -Method Patch -Headers $headers -Body $renameBody
    Write-Host "[SUCCESS] Repo renamed to '$newRepoName'!" -ForegroundColor Green
    Write-Host "          New URL: $($renameResult.html_url)" -ForegroundColor Green
} catch {
    $errMsg = $_.Exception.Message
    # If already renamed or doesn't exist under old name, try the new name directly
    if ($errMsg -match "404" -or $errMsg -match "Not Found") {
        Write-Host "[INFO] Repo '$oldRepoName' not found - it may already be renamed to '$newRepoName'. Continuing..." -ForegroundColor Yellow
    } else {
        Write-Host "[WARNING] Rename failed: $errMsg" -ForegroundColor Red
        Write-Host "          Continuing with file upload using existing repo name..." -ForegroundColor Yellow
    }
}

# ─────────────────────────────────────────────────────────────
# STEP 2: Upload / push updated project files
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[STEP 2] Uploading project files to GitHub..." -ForegroundColor Cyan

# Check if git is available — prefer Git CLI, fallback to REST API
$gitExists = $false
try {
    $null = Get-Command git -ErrorAction SilentlyContinue
    $gitExists = $true
} catch {}

if ($gitExists) {
    Write-Host "[INFO] Git CLI detected. Using Git push." -ForegroundColor Green

    git init

    $remotes = git remote
    if ($remotes -contains "origin") {
        git remote remove origin
    }
    git remote add origin $repoUrl

    git add .
    git commit -m "feat: Rebrand to FarmVision AI - Intelligent Livestock Monitoring & Classification System"
    git branch -M main

    Write-Host "Pushing to $repoUrl ..." -ForegroundColor Yellow
    git push -u origin main

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[SUCCESS] Code successfully pushed to $repoUrl" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Git push failed. Check credentials and try again." -ForegroundColor Red
    }

} else {
    Write-Host "[INFO] Git CLI not found. Using GitHub REST API fallback." -ForegroundColor Yellow

    $filesToUpload = @("index.html", "styles.css", "app.js", "app.py", "start_server.ps1", "README.md", "push_to_git.ps1")

    foreach ($file in $filesToUpload) {
        $filePath = Join-Path $PSScriptRoot $file
        if (-not (Test-Path $filePath)) {
            Write-Host "  Skipping $file (not found)." -ForegroundColor Yellow
            continue
        }

        Write-Host "  Uploading: $file..." -ForegroundColor Gray

        $fileBytes  = [System.IO.File]::ReadAllBytes($filePath)
        $fileBase64 = [System.Convert]::ToBase64String($fileBytes)

        $apiUrl = "https://api.github.com/repos/$owner/$newRepoName/contents/$file"
        $sha    = $null
        try {
            $existing = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers -ErrorAction SilentlyContinue
            $sha = $existing.sha
        } catch {}

        $body = @{
            "message" = "rebrand: Update $file for FarmVision AI"
            "content" = $fileBase64
        }
        if ($sha) { $body.Add("sha", $sha) }

        $jsonBody = ConvertTo-Json -InputObject $body -Depth 10

        try {
            $null = Invoke-RestMethod -Uri $apiUrl -Method Put -Headers $headers -Body $jsonBody -ContentType "application/json"
            Write-Host "  [SUCCESS] $file uploaded." -ForegroundColor Green
        } catch {
            Write-Host "  [ERROR] Failed to upload $file : $_" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "         FARMVISION AI DEPLOYMENT COMPLETE!               " -ForegroundColor Green
Write-Host "  Repo: https://github.com/$owner/$newRepoName           " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
