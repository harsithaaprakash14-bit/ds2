# Smart Livestock AI Server Launcher
# Uses built-in .NET HttpListener to serve files on localhost
# This enables webcam and TensorFlow.js permissions without installing Python/Node.js.

$port = 8000
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")

Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
Write-Host " SMART LIVESTOCK AI & GENDER MONITOR LOCAL SERVER " -ForegroundColor Cyan
Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
Write-Host "To run the premium Python Flask AI Backend, execute:" -ForegroundColor Yellow
Write-Host "    python app.py" -ForegroundColor Green
Write-Host "The frontend automatically connects and uses the backend!" -ForegroundColor Green
Write-Host "--------------------------------------------------------" -ForegroundColor Cyan

try {
    $listener.Start()
    Write-Host "Server successfully started on http://localhost:$port/" -ForegroundColor Green
    Write-Host "Webcam API and TensorFlow.js require a secure origin (like localhost)." -ForegroundColor Cyan
    Write-Host "Opening web browser now..." -ForegroundColor Gray
    
    # Launch browser
    Start-Process "http://localhost:$port/"
    
    Write-Host "Active. Press Ctrl+C in this terminal window to stop the server." -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------" -ForegroundColor Cyan

    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $url = $request.Url.LocalPath
        if ($url -eq "/") { $url = "/index.html" }

        # Resolve local file path
        $filePath = Join-Path $PSScriptRoot $url.TrimStart('/')
        
        if (Test-Path $filePath -PathType Leaf) {
            # Read file bytes
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            
            # Determine correct Content-Type headers
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $contentType = "text/plain"
            if ($ext -eq ".html" -or $ext -eq ".htm") { $contentType = "text/html" }
            elseif ($ext -eq ".css") { $contentType = "text/css" }
            elseif ($ext -eq ".js") { $contentType = "application/javascript" }
            elseif ($ext -eq ".png") { $contentType = "image/png" }
            elseif ($ext -eq ".jpg" -or $ext -eq ".jpeg") { $contentType = "image/jpeg" }
            elseif ($ext -eq ".svg") { $contentType = "image/svg+xml" }
            
            $response.ContentType = $contentType
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            # File Not Found
            $response.StatusCode = 404
            $errBytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: The file $url could not be resolved.")
            $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
        }
        $response.Close()
    }
} catch {
    Write-Host "Error starting server: $_" -ForegroundColor Red
} finally {
    $listener.Close()
    Write-Host "Server stopped." -ForegroundColor Yellow
}
