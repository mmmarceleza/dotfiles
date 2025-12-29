---
description: Create a new Git branch with Jira ticket and auto-generated description from code changes
allowed-tools: Bash(git:*), AskUserQuestion
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
- If yes, ask for the ticket ID (format: PROJECT-NUMBER, e.g., RUN-4426, PROJ-123)

### Step 3: Analyze Code Changes
Inspect the current changes using `git diff` and `git status`:
- Look at modified, added, and deleted files
- Analyze the nature of the changes (new feature, bug fix, refactor, config change, etc.)
- Generate a brief, descriptive summary in English

### Step 4: Generate Description
Based on the code analysis:
- Create a concise description that captures the essence of the changes
- Use lowercase letters and hyphens (no spaces or special characters)
- Keep it meaningful but short (ideally 3-6 words joined by hyphens)
- Examples: `add-user-authentication`, `fix-null-pointer-exception`, `update-kubernetes-config`

If no changes are detected (clean working directory), ask the user to provide a brief description of the planned work.

### Step 5: Build Branch Name
Construct the branch name:
- **With Jira ticket**: `<TICKET>-<description>` (e.g., `RUN-4426-add-kyverno-policy`)
- **Without Jira ticket**: `<description>` (e.g., `fix-login-validation`)

Rules:
- Jira ticket stays UPPERCASE
- Description is lowercase with hyphens
- No spaces or special characters
- Keep total length reasonable

### Step 6: Confirm with User
**Always show the proposed branch name and ask for user confirmation before creating.**

Example: "Proposed branch name: `RUN-4426-add-kyverno-wif-policy`. Do you want to create this branch?"

If the user wants changes, adjust accordingly and confirm again.

### Step 7: Create Branch
Once confirmed, create the branch:
```bash
git checkout -b <branch-name>
```

### Step 8: Confirm Success
Inform the user that the branch was created successfully and show the current branch.
