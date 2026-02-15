# 🚀 OpenGit

<p align="center">
  <img src="./assets/app_icons/icon.svg" alt="isolated" width="200"/>
</p>

OpenGit is a modern desktop Git client designed to provide a clear, visual Git experience, while remaining powerful enough for everyday development workflows.

The goal is simple :

Make Git easier to understand, safer to use, and more enjoyable, without hiding how it actually works.

---

# 🖥️ Supported platforms

| Platform | Status |
|----------|--------|
| **macOS** | ✅ Supported |
| **Windows** | ⏳ Soon |
| **Linux** | ⏳ Soon |

# ⚙️ Installation

## macOS (Homebrew) - *Recommended*

```bash
brew tap DevThibautMonin/tap
brew install --cask opengit
```

### To update later 

```bash
brew update
brew upgrade --cask opengit
```

## macOS (Manual)
- Go to the Releases page.
- Download the latest `.dmg` file (e.g., OpenGit-1.0.2.dmg).
- Open the downloaded `.dmg` file.
- Drag and drop the OpenGit icon into your Applications folder.

---

# ✨ Features

### Repository
- Open a local Git repository.
- Automatically reopen the last repository on launch.
- Clone a remote repository using SSH.
- Display the repository name.

### Branches
- List local branches.
- Highlight the current branch.
- Switch between branches.
- Create and checkout a new branch.
- Delete branches.
- Rename local branches.
- Fetch remote branches.
- Show remote branches state (deleted, active).
- Checkout remote branches locally.

### Working Directory
- Display modified, added, deleted, and untracked files.
- File-type icons based on extensions.
- Stage / unstage files.
- Stage / unstage all files.
- Keyboard navigation (Arrow Up/Down to navigate, Space to toggle staging).
- Create commits
  - mandatory commit summary
  - optional commit description
- Push commits to the remote repository.
- Display the number of commits waiting to be pushed.
- Discard changes (all files / single file).

### Files Differences
- File-by-file diff visualization.
- Clear distinction between
  - added lines
  - removed lines
  - unchanged lines
- Line numbers support.
- Support for newly created files.
- Unified / Split view.

### Commit History
- List commit / merge history.
- Display author, date, and message.
- Show full commit description in scrollable details panel.
- Clean and readable chronological view.
- Commit diff split view from history.
- Show unpushed commits.

### SSH & Authentication
- Automatic detection of SSH issues.
- Friendly UI to
  - guide SSH setup
  - handle unknown host verification
  - manage SSH permission errors
- Help converting HTTPS remotes to SSH.

### UX/UI
- Resizeable areas.
- Light / Dark theme supported.

---

# 📦 Roadmap

### Git & Collaboration
- Fetch / Pull with behind/ahead indicators.

### Branch Management
- Conflict resolution UI.

### UX & Product
- Extended keyboard shortcuts coverage (branches, commit history).
