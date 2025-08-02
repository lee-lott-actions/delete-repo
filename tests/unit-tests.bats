#!/usr/bin/env bats

# Load the Bash script containing the delete_repo function
load ../action.sh

# Mock the curl command to simulate API responses
mock_curl() {
  local http_code=$1
  local response_file=$2
  echo "$http_code"
  cat "$response_file" > response.json
}

# Setup function to run before each test
setup() {
  export GITHUB_OUTPUT=$(mktemp)
}

# Teardown function to clean up after each test
teardown() {
  cat "$GITHUB_OUTPUT"
  rm -f response.json mock_response.json "$GITHUB_OUTPUT"
}

@test "delete_repo succeeds with HTTP 204" {
  echo '{}' > mock_response.json

  curl() {
    mock_curl "204" mock_response.json
  }
  export -f curl

  run delete_repo "test-repo" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=success" ]
}

@test "delete_repo fails with HTTP 404" {
  echo '{"message": "Repository not found"}' > mock_response.json

  curl() {
    mock_curl "404" mock_response.json
  }
  export -f curl

  run delete_repo "test-repo" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Failed to delete repository. HTTP Status: 404" ]
}

@test "delete_repo fails with empty repo_name" {
  run delete_repo "" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Missing required parameters: repo-name, token, and owner must be provided." ]
}

@test "delete_repo fails with empty token" {
  run delete_repo "test-repo" "" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Missing required parameters: repo-name, token, and owner must be provided." ]
}

@test "delete_repo fails with empty owner" {
  run delete_repo "test-repo" "fake-token" ""

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Missing required parameters: repo-name, token, and owner must be provided." ]
}
