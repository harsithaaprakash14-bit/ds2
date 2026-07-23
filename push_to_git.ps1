# Smart Livestock AI - Git Repository Deployment Script
# Automatically detects git installation and handles repository synchronization.
# If Git CLI is not installed locally, it offers a secure fallback to upload code directly using the GitHub REST API.

$repoUrl = "https://github.com/harsithaaprakash14-bit/SMART-LIVESTOCK-AI.git"
$owner = "harsithaaprakash14-bit"
$repoName = "SMART-LIVESTOCK-AI"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "         SMART LIVESTOCK AI DEPLOYMENT SYSTEM             " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Repository: $repoUrl" -ForegroundColor Yellow
Write-Host "Checking local environment for Git command-line interface..." -ForegroundColor Gray

# Check if git command exists
$gitExists = $false
try {
    $null = Get-Command git -ErrorAction SilentlyContinue
    $gitExists = $true
} catch {}

if ($gitExists) {
    Write-Host "[SUCCESS] Git Command Line Interface detected." -ForegroundColor Green
    Write-Host "Running Git initialization commands..." -ForegroundColor Cyan
    
    # Git commands
    git init
    
    # Check remote
    $remotes = git remote
    if ($remotes -contains "origin") {
        git remote remove origin
    }
    git remote add origin $repoUrl
    
    git add .
    git commit -m "feat: Add Smart AI-Based Livestock Monitoring & Animal Classification System with Gender Detection"
    git branch -M main
    
    Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "Pushing code to GitHub repository..." -ForegroundColor Yellow
    Write-Host "Note: If prompted, please authenticate in the popup window or credential assistant." -ForegroundColor Gray
    
    git push -u origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[SUCCESS] Code successfully pushed to $repoUrl" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Git command failed. If this is due to credentials or lack of Git SSH key, you can run this script again and select the API Fallback." -ForegroundColor Red
    }
} else {
    Write-Host "[NOTICE] Git CLI is not installed or configured in the system PATH." -ForegroundColor Red
    Write-Host "We will now deploy files directly to your GitHub repository using the GitHub REST API." -ForegroundColor Cyan
    Write-Host "You will need a GitHub Personal Access Token (PAT) with 'repo' scope." -ForegroundColor Yellow
    Write-Host "Get a token here: https://github.com/settings/tokens" -ForegroundColor Gray
    Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
    
    $token = Read-Host -Prompt "Please enter your GitHub Personal Access Token (PAT)"
    if ([string]::IsNullOrWhiteSpace($token)) {
        Write-Host "[ERROR] Token cannot be empty. Aborting deployment." -ForegroundColor Red
        exit
    }
    
    $headers = @{
        "Authorization" = "token $token"
        "Accept"        = "application/vnd.github.v3+json"
    }
    
    # List files to upload
    $filesToUpload = @("index.html", "styles.css", "app.js", "app.py", "start_server.ps1", "README.md")
    
    foreach ($file in $filesToUpload) {
        $filePath = Join-Path $PSScriptRoot $file
        if (-not (Test-Path $filePath)) {
            Write-Host "Skipping $file (Not found in workspace)." -ForegroundColor Yellow
            continue
        }
        
        Write-Host "Preparing to upload: $file..." -ForegroundColor Gray
        
        # Read file contents and convert to Base64
        $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
        $fileBase64 = [System.Convert]::ToBase64String($fileBytes)
        
        # Check if file already exists in repo to get SHA
        $apiUrl = "https://api.github.com/repos/$owner/$repoName/contents/$file"
        $sha = $null
        try {
            $existingFile = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers -ErrorAction SilentlyContinue
            $sha = $existingFile.sha
            Write-Host "Existing file version found in repo ($file)." -ForegroundColor Gray
        } catch {}
        
        # Build payload
        $body = @{
            "message" = "Upload $file - Smart AI-Based Livestock Monitoring & Classification with Gender Detection"
            "content" = $fileBase64
        }
        if ($sha) {
            $body.Add("sha", $sha)
        }
        
        $jsonBody = ConvertTo-Json -InputObject $body -Depth 10
        
        try {
            Write-Host "Uploading $file via REST API..." -ForegroundColor Cyan
            $uploadResult = Invoke-RestMethod -Uri $apiUrl -Method Put -Headers $headers -Body $jsonBody -ContentType "application/json"
            Write-Host "[SUCCESS] Uploaded $file" -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] Failed to upload $file : $_" -ForegroundColor Red
        }
    }
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "             DEPLOYMENT TASK COMPLETED                    " -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
}
