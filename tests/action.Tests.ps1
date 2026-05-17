Describe "Remove-GitHubRepository" {
    BeforeAll {
        $script:RepoName   = "test-repo"
        $script:Token      = "fake-token"
        $script:Owner      = "test-owner"
        $script:MockApiUrl = "http://127.0.0.1:3000"
        . "$PSScriptRoot/../action.ps1"
    }

	BeforeEach {
        $env:GITHUB_OUTPUT = New-TemporaryFile
        $env:MOCK_API = $script:MockApiUrl
    }
	
    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        Remove-Item Env:MOCK_API -ErrorAction SilentlyContinue
    }

	Context "Success Cases" {
	    It "unit: RemoveGitHubRepository succeeds with HTTP 204" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 204; Content = '{}' }
	        }
	        Remove-GitHubRepository -RepoName $RepoName -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=success"
	    }
	}

	Context "HTTP Failure Cases" {
	    It "unit: RemoveGitHubRepository fails with HTTP 404" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 404; Content = '{"message":"Repository not found"}' }
	        }
	        Remove-GitHubRepository -RepoName $RepoName -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Error: Failed to delete repository. HTTP Status: 404"
	    }
	}

	Context "Parameter Validation Failure Cases" {
	    It "unit: RemoveGitHubRepository fails with empty RepoName" {
	        Remove-GitHubRepository -RepoName "" -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: repo-name, token, and owner must be provided."
	    }
	
	    It "unit: RemoveGitHubRepository fails with empty Token" {
	        Remove-GitHubRepository -RepoName $RepoName -Token "" -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: repo-name, token, and owner must be provided."
	    }
	
	    It "unit: RemoveGitHubRepository fails with empty Owner" {
	        Remove-GitHubRepository -RepoName $RepoName -Token $Token -Owner ""
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: repo-name, token, and owner must be provided."
	    }	
	}

	Context "Exception Failure Cases" {
		It "unit: RemoveGitHubRepositoryfails with exception" {
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
}
