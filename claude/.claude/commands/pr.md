---
description: Create a Pull Request with Jira ticket and auto-generated description
allowed-tools: Bash(git:*), Bash(gh:*), Bash(acli:*), AskUserQuestion
---

# Pull Request Creation

## Context
- Current branch: !`git branch --show-current`
- Git status: !`git status --short`
- Default branch: !`gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`
- Remote tracking: !`git remote -v`

## Instructions

When this command is invoked, follow these steps:

### Step 1: Verify Git Repository
Confirm this is a git repository with a remote configured. If not, inform the user and stop.

### Step 2: Check Prerequisites
- Verify `gh` CLI is installed and authenticated (run `gh auth status`)
- Ensure the current branch is not the default branch (main/master)
- Check if the branch has commits ahead of the default branch
- If any prerequisite fails, inform the user and stop

### Step 3: Detect Default Branch
Use the context to get the default branch name from `gh repo view`. Use this as the base for comparisons.

### Step 4: Extract Jira Ticket
Look for a Jira ticket pattern at the start of the branch name:
- Patterns: `PROJ-1234`, `TEAM-567`, `ABC-89` (UPPERCASE letters, hyphen, numbers)
- Extract this ticket if present for use in the PR title

### Step 5: Validate and Fetch Jira Issue
If a Jira ticket was extracted:
1. Validate it exists: `acli jira workitem view <TICKET> --output json`
2. If valid, extract the issue summary and type for better PR description
3. Get the Jira site URL: `acli jira auth status` (extract the Site field)
4. Build the Jira URL: `https://<site>/browse/<TICKET>`
5. If validation fails, warn the user but continue

### Step 6: Analyze Changes
Examine the changes between the current branch and the default branch:
- Get list of commits: `git log origin/<default>..HEAD --oneline`
- Get diff summary: `git diff origin/<default> --stat`
- Understand the scope and nature of the changes (feature, fix, refactor, etc.)
- Use the Jira issue summary if available to provide context

### Step 7: Generate PR Title
Create a concise, descriptive title:
- **With Jira ticket**: `[PROJ-1234] Brief description of changes`
- **Without Jira ticket**: `Brief description of changes`

Rules:
- Use imperative mood (e.g., "Add feature" not "Added feature")
- Keep it concise (max 72 characters)
- Describe the "what" not the "how"
- If Jira summary is available, use it as inspiration

### Step 8: Generate PR Description
Create a clear description based on the commits, changes, and Jira issue (if available):

**Template:**
```markdown
## Summary
- [2-4 bullet points describing the main changes]

## Changes
- [List of affected areas, components, or files]

## References
- [Jira ticket link if available]
```

Rules:
- Be concise but informative
- Focus on what changed and why
- All text in English
- If Jira ticket exists, automatically include the link in References

### Step 9: Ask About Additional Reference Links
Ask the user: "Do you want to include additional reference links (Slack, docs, etc.)?"

If yes, ask for each link and add to the References section.

### Step 10: Confirm PR Content with User
**Always show the complete PR title and description before proceeding.**

Display:
- The proposed title
- The complete description

Ask: "Do you want to create this PR?"

If the user wants changes, adjust accordingly and confirm again.

### Step 11: Push Branch (if needed)
Check if the branch is pushed to the remote:
- Run `git status` to check if branch has upstream
- If not pushed, ask the user: "Branch is not pushed to remote. Do you want to push it now?"
- If confirmed, push with: `git push -u origin <branch-name>`
- If push fails, inform the user and stop

### Step 12: Create Pull Request
Once confirmed and branch is pushed, create the PR:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<description here>
EOF
)"
```

### Step 13: Show Result
Display:
- The PR URL returned by `gh pr create`
- Confirmation that the PR was created successfully

### Step 14: Update Jira Issue (Optional)
If a valid Jira ticket was found, ask the user:
"Do you want to update <TICKET> in Jira?"

Options to offer:
1. Add PR link as comment
2. Transition to "Code Review" or "In Review"
3. Both
4. Skip

If adding comment:
```bash
acli jira workitem comment <TICKET> --body "Pull Request: <PR_URL>"
```

If transitioning:
```bash
acli jira workitem transition <TICKET> --transition "In Review"
```

Note: Transition names vary by project. If it fails, inform the user to check available transitions.

## Examples

**PR Title Examples:**
```
[PROJ-4426] Add Kyverno WIF policy for GKE clusters
[TEAM-123] Fix null pointer exception in payment service
Refactor authentication middleware for better performance
```

**PR Description Example:**
```markdown
## Summary
- Add new Kyverno policy to enforce Workload Identity Federation
- Configure policy exceptions for system namespaces
- Add unit tests for policy validation

## Changes
- `policies/kyverno/wif-policy.yaml` - New WIF enforcement policy
- `policies/kyverno/exceptions.yaml` - System namespace exceptions
- `tests/kyverno/wif_test.go` - Unit tests

## References
- [PROJ-4426](https://mysite.atlassian.net/browse/PROJ-4426)
- [Architecture discussion](https://slack.com/archives/...)
```
