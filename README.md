# Delete GitHub Repository Action

This GitHub Action deletes a specified GitHub repository using the GitHub API. It returns the result of the delete attempt, indicating success or failure, along with an error message if the operation fails.

## Features
- Deletes a GitHub repository by making a DELETE request to the GitHub API.
- Verifies the HTTP status code to confirm the deletion.
- Outputs the result of the delete attempt (`success` or `failure`) and an error message if applicable.
- Requires a GitHub token with repository administration permissions for authentication.

## Inputs
| Name        | Description                                              | Required | Default |
|-------------|----------------------------------------------------------|----------|---------|
| `repo-name` | The name of the repository to delete.                    | Yes      | N/A     |
| `token`     | GitHub token with repository administration permissions. | Yes      | N/A     |
| `owner`     | The owner of the repository (user or organization).      | Yes      | N/A     |

## Outputs
| Name           | Description                                         |
|----------------|-----------------------------------------------------|
| `result`       | Result of the delete attempt (`success` or `failure`). |
| `error-message`| Error message if the delete attempt fails.          |

## Usage
1. **Add the Action to Your Workflow**:
   Create or update a workflow file (e.g., `.github/workflows/delete-repo.yml`) in your repository.

2. **Reference the Action**:
   Use the action by referencing the repository and version (e.g., `v1`).

3. **Example Workflow**:
   ```yaml
   name: Delete Repository
   on:
     workflow_dispatch:
       inputs:
         repo-name:
           description: 'Name of the repository to delete'
           required: true
   jobs:
     delete-repo:
       runs-on: ubuntu-latest
       steps:
         - name: Delete Repository
           id: delete
           uses: lee-lott-actions/delete-repo@v1.0.0
           with:
             repo-name: ${{ github.event.inputs.repo-name }}
             token: ${{ secrets.GITHUB_TOKEN }}
             owner: ${{ github.repository_owner }}
         - name: Print Result
           run: |
             if [[ "${{ steps.delete.outputs.result }}" == "success" ]]; then
               echo "Repository ${{ github.repository_owner }}/${{ github.event.inputs.repo-name }} successfully deleted."
             else
               echo "Error: ${{ steps.delete.outputs.error-message }}"
               exit 1
             fi
