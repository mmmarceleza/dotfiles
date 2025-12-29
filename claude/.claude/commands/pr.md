---
description: Create a Pull Request with Jira ticket and auto-generated description (user)
allowed-tools: Bash(git:*), Bash(gh:*), AskUserQuestion
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
- Patterns: `RUN-1234`, `PROJ-567`, `TEAM-89` (UPPERCASE letters, hyphen, numbers)
- Extract this ticket if present for use in the PR title

### Step 5: Analyze Changes
Examine the changes between the current branch and the default branch:
- Get list of commits: `git log origin/<default>..HEAD --oneline`
- Get diff summary: `git diff origin/<default> --stat`
- Understand the scope and nature of the changes (feature, fix, refactor, etc.)

### Step 6: Generate PR Title
Create a concise, descriptive title:
- **With Jira ticket**: `[RUN-1234] Brief description of changes`
- **Without Jira ticket**: `Brief description of changes`

Rules:
- Use imperative mood (e.g., "Add feature" not "Added feature")
- Keep it concise (max 72 characters)
- Describe the "what" not the "how"

### Step 7: Generate PR Description
Create a clear description based on the commits and changes:

**Template:**
```markdown
## Summary
- [2-4 bullet points describing the main changes]

## Changes
- [List of affected areas, components, or files]
```

Rules:
- Be concise but informative
- Focus on what changed and why
- All text in English

### Step 8: Ask About Reference Links
Ask the user: "Do you want to include reference links (Jira, Slack, etc.)?"

If yes, ask for each link:
- Jira ticket URL (e.g., https://company.atlassian.net/browse/RUN-1234)
- Slack thread URL (optional)
- Any other relevant links

Add these as a "References" section at the end of the description:
```markdown
## References
- [Jira ticket](URL)
- [Slack discussion](URL)
```

### Step 9: Confirm PR Content with User
**Always show the complete PR title and description before proceeding.**

Display:
- The proposed title
- The complete description

Ask: "Do you want to create this PR?"

If the user wants changes, adjust accordingly and confirm again.

### Step 10: Push Branch (if needed)
Check if the branch is pushed to the remote:
- Run `git status` to check if branch has upstream
- If not pushed, ask the user: "Branch is not pushed to remote. Do you want to push it now?"
- If confirmed, push with: `git push -u origin <branch-name>`
- If push fails, inform the user and stop

### Step 11: Create Pull Request
Once confirmed and branch is pushed, create the PR:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<description here>
EOF
)"
```

### Step 12: Show Result
Display:
- The PR URL returned by `gh pr create`
- Confirmation that the PR was created successfully

## Examples

**PR Title Examples:**
```
[RUN-4426] Add Kyverno WIF policy for GKE clusters
[PROJ-123] Fix null pointer exception in payment service
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
- [RUN-4426](https://company.atlassian.net/browse/RUN-4426)
- [Architecture discussion](https://company.slack.com/archives/...)
```
