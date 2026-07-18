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
- Download the latest `.dmg` file (e.g., OpenGit-1.2.1.dmg).
- Open the downloaded `.dmg` file.
- Drag and drop the OpenGit icon into your Applications folder.

---

# ✨ Features

### Repository
- Open a local Git repository.
- Initialize a selected folder as a local Git repository.
- Automatically reopen the last repository on launch.
- Clone a remote repository from a Git URL with progress feedback.
- Display the repository name.
- Pull remote changes with fast-forward-only safety.
- Quickly switch between recently opened repositories from the header.

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
- Group branches by prefix. (feature/, bugfix/).
- Visual Git Graph of commit history, forks, and merges.
- GitHub user avatars integrated.

### Working Directory
- Display modified, added, deleted, and untracked files.
- File-type icons based on extensions.
- Stage / unstage files.
- Stage / unstage all files.
- Keyboard navigation (Arrow Up/Down to navigate, Space to toggle staging).
- Create commits
  - mandatory commit summary
  - optional commit description
- Amend the latest commit.
- Push commits to the remote repository.
- Display the number of commits waiting to be pushed.
- Create stashes with optional messages.
- List, apply, pop, and drop stashes.
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
- Monaco-powered read-only text diffs with language highlighting.
- Language detection for popular file names and extensions.
- Image preview for changed image files.
- SVG source view.

### Commit History
- List commit / merge history.
- Display author, date, and message.
- Show full commit description in scrollable details panel.
- Auto-select first commit and file on feature load.
- Visual indicators for selected commits and files.
- Clean and readable chronological view.
- Search commits from the history view.
- Commit diff split view from history.
- Show unpushed commits.
- Display GitHub user avatars for authors.

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
- Behind/ahead indicators.

### Branch Management
- Conflict resolution UI.

### UX & Product
- Extended keyboard shortcuts coverage (branches, commit history).
