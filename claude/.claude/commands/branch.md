---
description: Create a new Git branch with Jira ticket and auto-generated description from code changes
allowed-tools: Bash(git:*), Bash(acli:*), AskUserQuestion
---

# Branch Creation

## Context
- Current branch: !`git branch --show-current`
- Git status: !`git status --short`
- Staged changes: !`git diff --cached --stat`
- Unstaged changes: !`git diff --stat`

## Instructions

When this command is invoked, follow these steps:

### Step 1: Verify Git Repository
Confirm this is a git repository. If not, inform the user and stop.

### Step 2: Ask About Jira Ticket
Ask the user: "Is there a Jira ticket associated with this branch?"
- If yes, ask for the ticket ID (format: PROJECT-NUMBER, e.g., PROJ-123)

### Step 3: Validate and Fetch Jira Issue
If a Jira ticket was provided:
1. Validate the ticket exists: `acli jira workitem view <TICKET> --output json`
2. If valid, extract the issue summary and type
3. Show the user: "Found: <TICKET> - <summary> (<type>)"
4. If the command fails, warn the user that the ticket was not found and ask if they want to continue anyway

### Step 4: Analyze Code Changes
Inspect the current changes using `git diff` and `git status`:
- Look at modified, added, and deleted files
- Analyze the nature of the changes (new feature, bug fix, refactor, config change, etc.)
- Generate a brief, descriptive summary in English
- If a Jira summary was fetched, use it to help generate a better description

### Step 5: Generate Description
Based on the code analysis and Jira summary (if available):
- Create a concise description that captures the essence of the changes
- Use lowercase letters and hyphens (no spaces or special characters)
- Keep it meaningful but short (ideally 3-6 words joined by hyphens)
- Examples: `add-user-authentication`, `fix-null-pointer-exception`, `update-kubernetes-config`

If no changes are detected (clean working directory), ask the user to provide a brief description of the planned work, or use the Jira summary if available.

### Step 6: Build Branch Name
Construct the branch name:
- **With Jira ticket**: `<TICKET>-<description>` (e.g., `PROJ-123-add-kyverno-policy`)
- **Without Jira ticket**: `<description>` (e.g., `fix-login-validation`)

Rules:
- Jira ticket stays UPPERCASE
- Description is lowercase with hyphens
- No spaces or special characters
- Keep total length reasonable

### Step 7: Confirm with User
**Always show the proposed branch name and ask for user confirmation before creating.**

Example: "Proposed branch name: `PROJ-123-add-kyverno-wif-policy`. Do you want to create this branch?"

If the user wants changes, adjust accordingly and confirm again.

### Step 8: Create Branch
Once confirmed, create the branch:
```bash
git checkout -b <branch-name>
```

### Step 9: Update Jira Status (Optional)
If a valid Jira ticket was provided, ask the user:
"Do you want to transition <TICKET> to 'In Progress'?"

If yes, run:
```bash
acli jira workitem transition <TICKET> --transition "In Progress"
```

Note: If the transition fails (e.g., invalid transition name), inform the user and suggest they check available transitions in Jira.

### Step 10: Confirm Success
Inform the user that the branch was created successfully and show:
- The current branch name
- Whether Jira was updated (if applicable)
