#!/bin/bash
# GitHub CLI (gh) Commands for Multi-Line Code Reviews

# === BASIC REVIEW WORKFLOW ===

# Start a review for PR #311
gh pr review 311 --comment

# This opens your default editor where you can write comments like:
# > src/Components/tabComponent/certificateDetailsTab/CertListTab.jsx:1-2
# Good cleanup adding useState to the main React import.
#
# > src/Components/tabComponent/certificateDetailsTab/CertListTab.jsx:6-10
# Several imports were removed - please confirm they're no longer used.

# === MULTI-LINE COMMENT OPTIONS ===

# Option 1: Submit a complete review with multiple line comments
gh pr review 311 --body "Overall the changes look good but have some concerns." \
--comment "src/Components/tabComponent/certificateDetailsTab/CertListTab.jsx:230-240 The URL-based selection logic needs a fallback mechanism." \
--comment "src/Components/tabComponent/certificateDetailsTab/CertListTab.jsx:240 Using window.location.href as a dependency has issues with React."

# Option 2: Add individual comments to specific lines or ranges
gh pr comment 311 --body "This reset was added but not explained in the PR description." \
--path "src/Components/tabComponent/certificateDetailsTab/CertListTab.jsx" --line 176

gh pr comment 311 --body "The dependency array change could cause re-render issues." \
--path "src/Components/tabComponent/certificateDetailsTab/CertListTab.jsx" --line-start 240 --line-end 240

# === SUGGESTING CHANGES ===

# Suggest specific code changes (only works for single-line comments)
gh pr comment 311 --body "```suggestion
useEffect(() => {
  // Your effect code
}, [certificateId]);
```" \
--path "src/Components/tabComponent/certificateDetailsTab/CertListTab.jsx" --line 240

# === APPROVING OR REQUESTING CHANGES ===

# Approve the PR with comments
gh pr review 311 --approve --body "Looks good with the minor comments addressed."

# Request changes
gh pr review 311 --request-changes --body "Please address the URL parameter handling issues."

# === BATCH PROCESSING MULTIPLE PRS ===

# Review all PRs from a specific author
for PR in $(gh pr list --author "priypatel_expedia" --json number --jq '.[].number'); do
  gh pr review $PR --comment --body "Standard team review for URL parameter handling changes."
done

# === CREATE A REVIEW TEMPLATE ===

# Save this as review-template.md
# ```
# ### Overall Assessment
# [Your overall thoughts]
# 
# ### Line Comments
# > src/path/to/file.jsx:10-15
# [Comment on these lines]
# 
# > src/another/file.js:20,25
# [Comment on these non-consecutive lines]
# 
# ### Summary
# - [ ] Approve
# - [ ] Request changes
# - [ ] Comment only
# ```

# Then use it with:
gh pr review 311 --body "$(cat review-template.md)"
