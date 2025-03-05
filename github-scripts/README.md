# GitHub PR Review Tools

A collection of command-line tools for streamlining PR reviews and approvals.

## Tools

- `gh-review.sh` - Review PRs with multi-line comments
- `gh-batch-approve.sh` - Approve multiple PRs matching criteria
- `gh-stats.sh` - Get statistics on team PR reviews

## Quick Start

```bash
# Install GitHub CLI if you haven't already
# https://cli.github.com/

# Clone this repository
git clone https://github.com/your-org/github-pr-tools.git
cd github-pr-tools

# Make scripts executable
chmod +x *.sh

# Review a PR with line comments
./gh-review.sh 311
```

## Available Scripts

### gh-review.sh

Review PRs with detailed line-by-line comments:

```bash
./gh-review.sh <PR_NUMBER> [--approve|--request-changes|--comment-only]
```

### gh-batch-approve.sh

Approve multiple PRs matching criteria:

```bash
./gh-batch-approve.sh --author "username" --message "LGTM!"
```

### gh-stats.sh

Get statistics on team PR reviews:

```bash
./gh-stats.sh --days 30 --repo "org/repo"
```

## Templates

PR review templates are stored in the `templates/` directory.

## Contributing

Add your own PR review scripts and templates to make our review process more efficient.
