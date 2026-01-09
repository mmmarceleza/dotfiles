---
description: Create a git commit analyzing code changes with conventional commit format
allowed-tools: Bash(git:*), Bash(acli:*), AskUserQuestion
---

# Git Commit

## Context
- Current branch: !`git branch --show-current`
- Git status: !`git status --short`
- Staged changes: !`git diff --cached --stat`
- Staged diff: !`git diff --cached`
- Recent commits: !`git log --oneline -5`

## Instructions

When this command is invoked, follow these steps:

### Step 1: Verify Git Repository
Confirm this is a git repository. If not, inform the user and stop.

### Step 2: Check for Staged Changes
If there are no staged changes, check if there are unstaged changes:
- If unstaged changes exist, ask the user if they want to stage all changes (`git add -A`) or specific files
- If no changes at all, inform the user and stop

### Step 3: Analyze Changes
Examine the staged changes using `git diff --cached`:
- Identify the type of change (feat, fix, refactor, docs, style, test, chore, build, ci, perf)
- Understand the scope/context of the changes
- Identify any breaking changes

### Step 4: Check for Jira Reference
Extract the Jira ticket from the branch name if present:
- Look for patterns like `PROJ-1234`, `TEAM-567` at the start of the branch name
- This will be added to the commit body

### Step 5: Validate Jira Ticket (if found)
If a Jira ticket was extracted from the branch:
1. Validate it exists: `acli jira workitem view <TICKET> --output json`
2. If valid, you may use the issue summary to help write a better commit message
3. If invalid, warn the user but continue (the ticket might be from another Jira instance)

### Step 6: Compose Commit Message
Create a commit message following these rules:

**Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Rules:**
- **Type**: feat, fix, refactor, docs, style, test, chore, build, ci, perf
- **Scope**: Optional, the module/component affected (e.g., auth, api, ui)
- **Subject**: Imperative mood, lowercase, no period (e.g., "add user validation")
- **Body**: Optional, explain what and why (not how)
- **Footer**: Jira reference if available, breaking changes if any
- **No emojis**
- **No "Generated with Claude Code" or "Co-Authored-By" lines**
- **All text in English**

**Examples:**
```
feat(auth): add OAuth2 login support

Implement Google and GitHub OAuth2 providers for user authentication.

Refs: PROJ-1234
```

```
fix(api): handle null response from payment gateway

The payment gateway occasionally returns null on timeout.
Added null check and retry logic.

BREAKING CHANGE: PaymentResponse type now includes nullable fields
Refs: PROJ-567
```

```
refactor: simplify database connection pooling

Reduce complexity by using built-in connection pool manager.
```

### Step 7: Confirm with User
**Always show the proposed commit message and ask for user confirmation before committing.**

Display the full commit message and ask:
"Do you want to create this commit?"

If the user wants changes, adjust accordingly and confirm again.

### Step 8: Create Commit
Once confirmed, create the commit using a heredoc to preserve formatting:
```bash
git commit -m "$(cat <<'EOF'
<commit message here>
EOF
)"
```

### Step 9: Confirm Success
Show the result of the commit and the new commit hash.

### Step 10: Add Jira Comment (Optional)
If a valid Jira ticket was found, ask the user:
"Do you want to add a comment to <TICKET> with the commit info?"

If yes, run:
```bash
acli jira workitem comment <TICKET> --body "Commit: <short-hash> - <subject>"
```

## Conventional Commit Types Reference
- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Formatting, missing semicolons, etc (no code change)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **test**: Adding or correcting tests
- **chore**: Maintenance tasks, dependencies, etc
- **build**: Changes to build system or dependencies
- **ci**: Changes to CI configuration
- **perf**: Performance improvements
