#!/bin/bash
# GitHub PR Review CLI Tool
# Usage: ./gh-review.sh <PR_NUMBER> [OPTIONS]
# Example: ./gh-review.sh 311 --multi-line

set -e

PR_NUMBER=$1
shift

if [ -z "$PR_NUMBER" ]; then
  echo "Error: PR number is required"
  echo "Usage: ./gh-review.sh <PR_NUMBER> [OPTIONS]"
  exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
  echo "Error: GitHub CLI (gh) is not installed"
  echo "Install it from: https://cli.github.com/"
  exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
  echo "You are not logged in to GitHub CLI"
  echo "Run 'gh auth login' first"
  exit 1
fi

# Parse options
COMMENT_ONLY=false
APPROVE=false
REQUEST_CHANGES=false
USE_TEMPLATE=false
TEMPLATE_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --comment-only)
      COMMENT_ONLY=true
      shift
      ;;
    --approve)
      APPROVE=true
      shift
      ;;
    --request-changes)
      REQUEST_CHANGES=true
      shift
      ;;
    --template)
      USE_TEMPLATE=true
      TEMPLATE_FILE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Function to create a temporary review file
create_review_template() {
  local temp_file=$(mktemp)
  
  cat > "$temp_file" << EOF
# PR Review for #$PR_NUMBER
# Lines starting with # will be ignored

### Overall Assessment
[Your overall thoughts on the PR]

### Line Comments
# Format for consecutive lines: > path/to/file.jsx:10-15
# Format for non-consecutive lines: > path/to/file.jsx:20,25,30
# Example:
# > src/Components/tabComponent/certificateDetailsTab/CertListTab.jsx:230-240
# The URL parameter handling logic needs a fallback mechanism.

### Summary
[Final recommendations]

EOF
  
  echo "$temp_file"
}

# Main review logic
if [ "$USE_TEMPLATE" = true ] && [ -f "$TEMPLATE_FILE" ]; then
  # Use provided template
  gh pr review "$PR_NUMBER" --body "$(cat "$TEMPLATE_FILE")"
elif [ "$COMMENT_ONLY" = true ]; then
  # Start a comment-only review
  temp_file=$(create_review_template)
  ${EDITOR:-vim} "$temp_file"
  gh pr review "$PR_NUMBER" --comment --body "$(grep -v '^#' "$temp_file")"
  rm "$temp_file"
elif [ "$APPROVE" = true ]; then
  # Approve with comments
  temp_file=$(create_review_template)
  ${EDITOR:-vim} "$temp_file"
  gh pr review "$PR_NUMBER" --approve --body "$(grep -v '^#' "$temp_file")"
  rm "$temp_file"
elif [ "$REQUEST_CHANGES" = true ]; then
  # Request changes with comments
  temp_file=$(create_review_template)
  ${EDITOR:-vim} "$temp_file"
  gh pr review "$PR_NUMBER" --request-changes --body "$(grep -v '^#' "$temp_file")"
  rm "$temp_file"
else
  # Default: Open an editor for commenting
  temp_file=$(create_review_template)
  ${EDITOR:-vim} "$temp_file"
  gh pr review "$PR_NUMBER" --comment --body "$(grep -v '^#' "$temp_file")"
  rm "$temp_file"
fi

echo "Review submitted for PR #$PR_NUMBER"
