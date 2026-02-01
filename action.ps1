function Remove-GitHubRepository {
    param(
        [string]$RepoName,
        [string]$Token,
        [string]$Owner
    )

    # Validate required parameters
    if ([string]::IsNullOrEmpty($RepoName) -or
        [string]::IsNullOrEmpty($Token) -or
        [string]::IsNullOrEmpty($Owner)) {
        Write-Host "Error: Missing required parameters"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Missing required parameters: repo-name, token, and owner must be provided."
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        return
    }

    Write-Host "Attempting to delete repository $Owner/$RepoName"

    # Use MOCK_API if set, otherwise default to GitHub API
    $apiBaseUrl = $env:MOCK_API
    if (-not $apiBaseUrl) { $apiBaseUrl = "https://api.github.com" }
    $uri = "$apiBaseUrl/repos/$Owner/$RepoName"

    $headers = @{
        Authorization  = "Bearer $Token"
        Accept         = "application/vnd.github+json"
        "Content-Type" = "application/json"
        "User-Agent"   = "pwsh-action"
    }

    try {
        $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Delete

        if ($response.StatusCode -eq 204) {
            Write-Host "Repository $Owner/$RepoName successfully deleted"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
        } else {
			$errorMsg = "Error: Failed to delete repository. HTTP Status: $($response.StatusCode)"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
			Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
			Write-Host $errorMsg
        }
    } catch {
		$errorMsg = "Error: Failed to delete repository $Owner/$RepoName. Exception: $($_.Exception.Message)"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
		Write-Host $errorMsg
    }
}