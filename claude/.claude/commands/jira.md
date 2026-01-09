---
description: View Jira issues or create new ones based on code changes
allowed-tools: Bash(acli:*), Bash(git:*), AskUserQuestion
---

# Jira Issue Manager

## Context
- Current branch: !`git branch --show-current`
- Arguments: $ARGUMENTS
- Git status: !`git status --short 2>/dev/null || echo "not a git repo"`

## Instructions

This command supports two modes:
- **View mode**: `/jira PROJ-123` - View issue details
- **Create mode**: `/jira create` - Create a new issue

### Step 1: Determine Mode

Check `$ARGUMENTS`:
- If it matches a Jira issue pattern (e.g., `PROJ-123`): **View mode**
- If it is `create` or `new`: **Create mode**
- If empty: Try to extract issue from branch name. If found, **View mode**. Otherwise, ask the user what they want to do.

---

## View Mode

### Step V1: Get Issue Key
Use the issue key from arguments or extracted from branch name.

### Step V2: Verify ACLI Authentication
Run `acli jira auth status` to ensure the user is authenticated.
If not authenticated, inform the user to run `acli jira auth login`.

### Step V3: Fetch Issue Details
Run:
```bash
acli jira workitem view <ISSUE_KEY> --output json
```

If the command fails, inform the user that the issue was not found.

### Step V4: Display Formatted Information
Parse the JSON output and display:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  <ISSUE_KEY>: <Summary>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Status:     <status>
Type:       <issue type>
Priority:   <priority>
Assignee:   <assignee or Unassigned>
Reporter:   <reporter>
Created:    <created date>
Updated:    <updated date>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Description
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

<description text>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Acceptance Criteria (if present)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

<acceptance criteria if available>
```

### Step V5: Show Jira Link
Get the Jira site from `acli jira auth status` and display:
```
Link: https://<site>/browse/<ISSUE_KEY>
```

### Step V6: Show Related Information
If available, show:
- **Parent issue**: Key and summary
- **Subtasks**: Key, summary, and status
- **Linked issues**: Relationship and key

### Step V7: Suggest Next Actions
Based on status:
- "To Do"/"Open": Suggest `/branch` to start work
- "In Progress" + matching branch: Suggest `/commit`
- "In Review": Mention PR review

---

## Create Mode

### Step C1: Verify ACLI Authentication
Run `acli jira auth status` to ensure the user is authenticated.
If not authenticated, inform the user to run `acli jira auth login`.

### Step C2: Check Git Repository
Determine if we're in a git repository:
```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

### Step C3: Analyze Git Changes (if in git repo)
If in a git repository, analyze the current state:

1. **Check for changes**:
   ```bash
   git status --short
   git diff --stat
   git diff --cached --stat
   ```

2. **Analyze modified/created files**:
   - Identify file types and locations (e.g., `src/auth/`, `tests/`, `config/`)
   - Determine the nature of changes (new feature, bug fix, refactor, config, docs)
   - Look at the actual diff content for context:
     ```bash
     git diff
     git diff --cached
     ```

3. **Check recent commits** (if on a feature branch):
   ```bash
   git log --oneline -5
   ```

4. **Generate suggestions** based on analysis:
   - Suggest issue type (Task, Bug, Story, etc.)
   - Suggest summary based on changes
   - Suggest description with technical details

### Step C4: Ask for Project
Ask the user: "Which Jira project should this issue be created in?"
- Suggest extracting from branch name if pattern exists
- User provides project key (e.g., `PROJ`, `TEAM`)

### Step C5: Ask for Issue Type
Ask the user to select issue type:
- **Task**: General work item
- **Bug**: Something is broken
- **Story**: User-facing feature
- **Subtask**: Part of a larger issue

If git analysis suggested a type, recommend it.

### Step C6: Generate Summary
Based on git analysis (if available):
1. Propose a summary that describes the work
2. Show the user: "Suggested summary based on your changes: `<summary>`"
3. Ask if they want to use it, modify it, or write their own

Rules for summary:
- Imperative mood (e.g., "Add authentication" not "Added authentication")
- Concise but descriptive (max 100 characters)
- In English

### Step C7: Generate Description
Based on git analysis (if available):
1. Create a description that includes:
   - What the change does
   - Which files/areas are affected
   - Technical context if relevant

2. Show the proposed description and ask for confirmation

Template:
```
## Overview
<Brief description of what needs to be done>

## Technical Details
- Files affected: <list of main files/directories>
- Type of change: <feature/bugfix/refactor/config>

## Acceptance Criteria
- [ ] <criterion 1>
- [ ] <criterion 2>
```

### Step C8: Confirm Issue Details
Display the complete issue before creation:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  New Issue Preview
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Project:    <PROJECT>
Type:       <type>
Summary:    <summary>

Description:
<description>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Ask: "Do you want to create this issue?"

### Step C9: Create Issue
Once confirmed:
```bash
acli jira workitem create \
  --project <PROJECT> \
  --type <TYPE> \
  --summary "<summary>" \
  --description "$(cat <<'EOF'
<description>
EOF
)"
```

Capture the created issue key from the output.

### Step C10: Auto-Assign to Current User
Automatically assign the newly created issue to the current user:

1. Get the current user's email:
```bash
acli jira auth status | grep Email | awk '{print $2}'
```

2. Assign the issue:
```bash
acli jira workitem assign <NEW_KEY> --assignee "<user_email>"
```

If assignment fails, warn the user but continue (the issue was still created successfully).

### Step C11: Show Result
Display:
- The created issue key
- The Jira URL: `https://<site>/browse/<NEW_KEY>`
- Assignee confirmation
- Success confirmation

### Step C12: Offer Next Steps
Ask the user:
"Issue created and assigned to you! Do you want to create a branch for this issue now?"

If yes, suggest running `/branch` with the new issue key.

---

## Examples

**View issue:**
```
/jira PROJ-123
```

**Create issue (in git repo with changes):**
```
/jira create

# Analyzes your staged/unstaged changes and suggests:
# Summary: "Add user authentication middleware"
# Description based on modified files in src/auth/
```

**Create issue (no git or no changes):**
```
/jira create

# Asks for all details interactively
```
