param(
    [int]$Port = 3000
)

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()

Write-Host "Mock server listening on http://127.0.0.1:$Port..." -ForegroundColor Green

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $path = $request.Url.LocalPath
        $method = $request.HttpMethod
        
        Write-Host "Mock intercepted: $method $path" -ForegroundColor Cyan

        $statusCode = 200
        $responseJson = $null

        # HealthCheck endpoint: GET /HealthCheck
        if ($method -eq "GET" -and $path -eq "/HealthCheck") {
            $statusCode = 200
            $responseJson = @{ status = "ok" } | ConvertTo-Json
        }
        # DELETE /repos/:owner/:repo
        elseif ($method -eq "DELETE" -and $path -match '^/repos/([^/]+)/([^/]+)$') {
            $owner = $Matches[1]
            $repo = $Matches[2]
            Write-Host "Request headers: $($request.Headers | Out-String)"

            if ($owner -eq "invalid-owner" -or $repo -eq "invalid-repo") {
                $statusCode = 404
                $responseJson = @{ message = "Repository not found" } | ConvertTo-Json
            }
            else {
                $statusCode = 204
                $responseJson = $null
            }
        }
        else {
            $statusCode = 404
            $responseJson = @{ message = "Not Found" } | ConvertTo-Json
        }
        
        # Send response
        $response.StatusCode = $statusCode
        if ($statusCode -eq 204) {
            $response.ContentLength64 = 0
        } else {
            $response.ContentType = "application/json"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseJson)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
        $response.Close()
    }
}
finally {
    $listener.Stop()
    $listener.Close()
    Write-Host "Mock server stopped." -ForegroundColor Yellow
}