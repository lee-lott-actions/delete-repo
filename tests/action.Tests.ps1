Describe "Remove-GitHubRepository" {
    BeforeAll {
        $script:RepoName   = "test-repo"
        $script:Token      = "fake-token"
        $script:Owner      = "test-owner"
        $script:MockApiUrl = "http://127.0.0.1:3000"
        . "$PSScriptRoot/../action.ps1"
    }
    BeforeEach {
        $env:GITHUB_OUTPUT = "$PSScriptRoot/github_output.temp"
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        $env:MOCK_API = $script:MockApiUrl
    }
    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Get-Content $env:GITHUB_OUTPUT; Remove-Item $env:GITHUB_OUTPUT }
        Remove-Variable -Name MOCK_API -Scope Global -ErrorAction SilentlyContinue
    }

    It "delete_repo succeeds with HTTP 204" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{ StatusCode = 204; Content = '{}' }
        }
        Remove-GitHubRepository -RepoName $RepoName -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=success"
    }

    It "delete_repo fails with HTTP 404" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{ StatusCode = 404; Content = '{"message":"Repository not found"}' }
        }
        Remove-GitHubRepository -RepoName $RepoName -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Error: Failed to delete repository. HTTP Status: 404"
    }

    It "delete_repo fails with empty repo_name" {
        Remove-GitHubRepository -RepoName "" -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: repo-name, token, and owner must be provided."
    }

    It "delete_repo fails with empty token" {
        Remove-GitHubRepository -RepoName $RepoName -Token "" -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: repo-name, token, and owner must be provided."
    }

    It "delete_repo fails with empty owner" {
        Remove-GitHubRepository -RepoName $RepoName -Token $Token -Owner ""
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: repo-name, token, and owner must be provided."
    }
	
	It "writes result=failure and error-message on exception" {
		Mock Invoke-WebRequest { throw "API Error" }

		try {
			Remove-GitHubRepository -RepoName $RepoName -Token $Token -Owner $Owner
		} catch {}

		$output = Get-Content $env:GITHUB_OUTPUT
		$output | Should -Contain "result=failure"
		$output | Where-Object { $_ -match "^error-message=Error: Failed to delete repository $Owner/$RepoName\. Exception:" } |
			Should -Not -BeNullOrEmpty
	}	
}