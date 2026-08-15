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
- Display ahead / behind indicators for the current branch.
- Refresh remote data with a visible last fetch indicator.
- Quickly switch between recently opened repositories from the header.
- Show the current branch next to the active repository name.

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
- Branch overview table with main status, remote sync, last commit, and quick actions.
- Selected branch details panel.
- Display ahead / behind indicators for local branches with an upstream.
- Display whether local branches are merged or still contain commits not in main / master.
- Warn before deleting branches that contain commits not in main / master.
- GitHub user avatars integrated.

### Working Directory
- Display modified, added, deleted, and untracked files.
- File-type icons based on extensions.
- Separate staged and unstaged changes into a dedicated staging area.
- Stage / unstage files.
- Stage / unstage all files.
- Support files with both staged and unstaged changes.
- Create commits
  - mandatory commit summary
  - optional commit description
- Amend the latest commit.
- Push commits to the remote repository.
- Display the number of commits waiting to be pushed.
- Create stashes with optional messages.
- List, apply, pop, and drop stashes.
- Discard changes (all files / single file).
- Clear the selected diff after discarding changes.
- Refresh the selected file diff when the app returns to the foreground.
- Copy changed file paths from contextual menus.

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
- Markdown preview for README and Markdown files, while opening them in diff mode by default.

### Commit History
- List commit / merge history.
- Display author, date, and message.
- Show full commit description in scrollable details panel.
- Open a commit details view from the history list.
- Display changed files inside the selected commit details view.
- Visual indicators for selected commits and files.
- Clean and readable chronological view.
- Search commits from the history view.
- Commit diff split view from history.
- Show unpushed commits.
- Display GitHub user avatars for authors.
- Copy commit SHAs and changed file paths from contextual menus.

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

### Branch Management
- Conflict resolution UI.
- Contextual branch graph focused on main and the selected branch.

### UX & Product
- Command palette for frequent Git actions.
