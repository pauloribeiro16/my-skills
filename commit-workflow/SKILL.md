---
name: commit-workflow
description: "Git workflow automation for committing, pushing, and creating pull requests. Trigger phrases: commit changes, push to remote, create pull request, clean up branches, git workflow"
---

# Commit Workflow

Streamline git operations with commands for committing, pushing, and cleaning up branches. Based on Anthropic's commit-commands plugin.

## When to Use

- Committing changes with appropriate messages
- Pushing branches and creating pull requests
- Cleaning up stale local branches
- Full git workflow automation

## Commands

### /commit

Creates a git commit with an automatically generated commit message.

**What it does**:
1. Analyzes current git status
2. Reviews both staged and unstaged changes
3. Examines recent commit messages to match repository style
4. Drafts an appropriate commit message
5. Stages relevant files
6. Creates the commit

**Usage**:
```bash
/commit
```

**Features**:
- Auto-generated messages matching repo style
- Follows conventional commit practices
- Avoids committing secrets (.env, credentials.json)
- Includes attribution in commit message

### /commit-push-pr

Complete workflow: commit → push → PR creation.

**What it does**:
1. Creates a new branch (if currently on main)
2. Stages and commits changes
3. Pushes branch to origin
4. Creates pull request using `gh pr create`
5. Provides PR URL

**Usage**:
```bash
/commit-push-pr
```

**Features**:
- Analyzes all commits in branch for PR description
- Creates comprehensive PR descriptions with:
  - Summary (1-3 bullet points)
  - Test plan checklist
  - Attribution
- Handles branch creation automatically

**Requirements**: GitHub CLI (`gh`) installed and authenticated

### /clean-gone

Cleans up local branches deleted from remote.

**What it does**:
1. Lists local branches with [gone] status
2. Removes worktrees associated with [gone] branches
3. Deletes stale local branches
4. Reports what was cleaned up

**Usage**:
```bash
/clean-gone
```

**When to use**: After merging and deleting remote branches.

## Best Practices

### /commit
- Review staged changes before committing
- Let the system analyze and match your repo's style
- Trust the automated message, verify it's accurate

### /commit-push-pr
- Ensure all changes are complete and tested
- Review the PR description and edit if needed
- Use when minimizing context switching

### /clean-gone
- Run periodically to keep branch list clean
- Safe: only removes branches already deleted remotely
- Helps maintain tidy local repository

## Workflow Integration

### Quick commit
```
/commit
```

### Feature branch
```
/commit          # First commit
# more changes
/commit          # Second commit
/commit-push-pr  # Ready for PR
```

### Maintenance
```
/clean-gone      # After merging PRs
```

## Requirements

- Git installed and configured
- For `/commit-push-pr`: GitHub CLI (`gh`) installed and authenticated
- Repository with a remote named `origin`