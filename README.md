# OpenGit

### An open source Git client

```bash
fvm flutter clean
fvm flutter pub get
fvm dart run build_runner build -d
```

# 🔐 Allow Push (SSH setup)

To push commits to a remote Git repository (e.g. GitHub), OpenGit uses SSH authentication.
This requires a one-time setup on the user’s machine.

# ✅ Prerequisites

To allow git push, all of the following conditions must be met:

- The user has an SSH key pair on their computer

- The public SSH key is added to the remote repository provider (GitHub, GitLab, etc.)

- The remote host is trusted on the local machine

# 🧩 Step-by-step setup

### 1️⃣ Generate an SSH key (if not already done)

```bash
ssh-keygen -t ed25519 -C "your@email.com"
```

Press Enter to accept the default location

This creates :

- Private key: ~/.ssh/id_ed25519
- Public key: ~/.ssh/id_ed25519.pub

### 2️⃣ Add the public key to GitHub

Copy the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Then add it to:

👉 GitHub → Settings → SSH and GPG keys → New SSH key

### 3️⃣ Verify the SSH connection

Run the following command once:

```bash
ssh -T git@github.com
```

Expected output:

Hi <username>! You've successfully authenticated,
but GitHub does not provide shell access.


✔ This confirms:

The private key matches the public key on GitHub

GitHub is trusted on this machine

You can now use the push feature on OpenGit.
