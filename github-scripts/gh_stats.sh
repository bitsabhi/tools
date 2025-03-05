#!/bin/bash
# GitHub PR Review Statistics
# Usage: ./gh-stats.sh [OPTIONS]

set -e

# Default values
DAYS=30
REPO=""
AUTHOR=""
TEAM=""

# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    --days)
      DAYS="$2"
      shift 2
      ;;
    --repo)
      REPO="$2"
      shift 2
      ;;
    --author)
      AUTHOR="$2"
      shift 2
      ;;
    --team)
      TEAM="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Calculate date from N days ago
DATE_FROM=$(date -v-${DAYS}d +%Y-%m-%d 2>/dev/null || date -d "${DAYS} days ago" +%Y-%m-%d)

# Build query parameters
QUERY_PARAMS="--limit 100"
if [ -n "$REPO" ]; then
  QUERY_PARAMS="$QUERY_PARAMS --repo $REPO"
fi
if [ -n "$AUTHOR" ]; then
  QUERY_PARAMS="$QUERY_PARAMS --author $AUTHOR"
fi

echo "Gathering PR statistics since $DATE_FROM..."

# Get PRs created in the time period
echo "Finding PRs created since $DATE_FROM"
PR_LIST=$(gh pr list $QUERY_PARAMS --json number,title,author,createdAt,state,reviewDecision --search "created:>=$DATE_FROM")

# Get review stats
TOTAL_PRS=$(echo "$PR_LIST" | jq length)
APPROVED_PRS=$(echo "$PR_LIST" | jq '[.[] | select(.reviewDecision == "APPROVED")] | length')
CHANGES_REQUESTED=$(echo "$PR_LIST" | jq '[.[] | select(.reviewDecision == "CHANGES_REQUESTED")] | length')
PENDING_REVIEW=$(echo "$PR_LIST" | jq '[.[] | select(.reviewDecision == "REVIEW_REQUIRED")] | length')

# Group by authors
AUTHOR_STATS=$(echo "$PR_LIST" | jq 'group_by(.author.login) | map({author: .[0].author.login, count: length})')

echo ""
echo "============================================"
echo "         PR STATISTICS ($DAYS DAYS)         "
echo "============================================"
echo ""
echo "Total PRs:           $TOTAL_PRS"
echo "Approved:            $APPROVED_PRS"
echo "Changes Requested:   $CHANGES_REQUESTED"
echo "Pending Review:      $PENDING_REVIEW"
echo ""
echo "Top PR Authors:"
echo "$AUTHOR_STATS" | jq -r 'sort_by(-.count) | .[0:5] | .[] | "  \(.author): \(.count) PRs"'
echo ""

# Get review statistics if a repository is specified
if [ -n "$REPO" ]; then
  echo "Review statistics for $REPO:"
  
  # Get list of reviews
  REVIEW_LIST=$(gh api "repos/$REPO/pulls/reviews" --paginate)
  
  # Get reviewer stats
  REVIEWER_STATS=$(echo "$REVIEW_LIST" | jq '[.[] | select(.submitted_at >= "'$DATE_FROM'")]' | \
    jq 'group_by(.user.login) | map({reviewer: .[0].user.login, count: length})')
  
  echo "Top Reviewers:"
  echo "$REVIEWER_STATS" | jq -r 'sort_by(-.count) | .[0:5] | .[] | "  \(.reviewer): \(.count) reviews"'
  echo ""
fi

echo "============================================"
