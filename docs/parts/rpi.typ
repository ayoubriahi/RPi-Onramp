#import "../common.typ": *

= General Overview

---

#hl[#text(weight: "bold")[Why Use Raspberry Pi]]

Raspberry Pi is a popular choice for beginners because it is affordable, well-documented, and has a large community. It ships with a familiar Debian-based environment, making it easy to get started with Linux. It is equally suited for advanced users who want to build custom hardware projects, run home servers, or experiment with electronics via its 40-pin GPIO header.

---

#hl[#text(weight: "bold")[What is Raspberry Pi]]

Raspberry Pi is a *low-cost* operating systems. It is a popular platform for single-board computer _capable of running_ Linux-based embedded systems, IoT projects, home automation, education, and prototyping. It was originally developed by the Raspberry Pi Foundation (now Raspberry Pi Ltd.) with the goal of promoting computer science education.

The official operating system is *Raspberry Pi OS* (formerly called Raspbian until May 2020). It is based on the Debian Linux distribution and uses the
`apt` (Advanced Package Tool) package manager.

---

Before installing any software, it is good practice to refresh the local package index and then apply all available upgrades:
```bash
sudo apt update  # refresh the package list
sudo apt full-upgrade  # upgrade packages, handling dependency changes
```

`full-upgrade` is preferred over `upgrade` because it correctly handles cases where packages need to be added or removed to satisfy updated dependencies.

To install a specific package:
```bash
sudo apt install git  # install git
```

== SSH Setup

#title-slide("SSH", "Secure Shell Configuration")

SSH (Secure Shell) is a cryptographic network protocol for secure remote access to a machine over an unsecured network. On Raspberry Pi OS, the `openssh-server` package is already installed but *disabled by default* for security reasons.

---

There are three common ways to enable it:

*Option 1 — raspi-config (recommended for interactive use):*
```bash
sudo raspi-config
# Navigate to: Interface Options → SSH → Enable
```

*Option 2 — systemctl (enable on a running system):*

```bash
sudo systemctl enable ssh  # enable SSH to start on boot
sudo systemctl start ssh  # start the SSH service immediately
```

*Option 3 — headless setup (before first boot):*

Create an empty file named `ssh` (no extension) in the `/boot` or `/bootfs` partition of the SD card. The OS will detect it on first boot, enable the SSH service, and delete the file.

---

Once SSH is enabled, connect from another machine with:
```bash
ssh <username>@<hostname>.local
# e.g. ssh pi@raspberrypi.local
```

#info[Create a new connection profile of type Ethernet on the physical interface enp4s0. The PC will act as a DHCP server and automatically assign an IP address to any device connected via Ethernet (the Pi), while also enabling NAT to share the laptop's internet connection.
  ```bash
  nmcli connection add type ethernet ifname enp4s0 con-name "rpi-share" ipv4.method shared
  ```
  Activate and inspect the connection
  ```bash
  nmcli connection up "rpi-share"
  nmcli connection show "rpi-share"
  ```
  Perform a ping sweep across all 254 addresses, without port scanning
  ```bash
  nmap -sn 10.42.0.0/24
  ```
]

---

=== SSH Key Authentication

Connecting with a password is convenient but less secure. The recommended approach is *public-key authentication*: you generate a key pair on your client machine, then place the public key on the Raspberry Pi. From that point on, no password is needed and brute-force attacks become ineffective.

=== How it works

A key pair consists of two files:

/ Private key _(`~/.ssh/rpi`)_: stays on your machine, never shared.
/ Public key _(`~/.ssh/rpi.pub`)_: copied to the Pi. It can only be used to verify someone who holds the matching private key.

---

=== Generate a key pair (on your local machine)

Ed25519 is the current recommended algorithm: it is compact, fast, and more secure than RSA.
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

You will be prompted for:
/ File location: press Enter to accept the default (`~/.ssh/rpi`).
/ Passphrase: strongly recommended. It encrypts the private key on disk so that even if the file is stolen, it cannot be used without the passphrase.

The command produces two files:
```
~/.ssh/rpi      # private key — keep this secret
~/.ssh/rpi.pub  # public key  — this goes on the Pi
```

=== Copy the public key to the Raspberry Pi

The simplest method is `ssh-copy-id`, which handles directory creation and permissions automatically:
```bash
ssh-copy-id <username>@<pi-ip-address>
# e.g. ssh-copy-id pi@10.42.0.39
```

You will be asked for your Pi password one final time. After this step, the public key is appended to `~/.ssh/authorized_keys` on the Pi.

/*
If `ssh-copy-id` is not available _(e.g. on Windows)_, copy it manually:
```bash
cat ~/.ssh/rpi.pub | ssh <username>@<pi-ip-address> \
"mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```
*/

=== Connect using the key
```bash
ssh <username>@<pi-ip-address>
# e.g. ssh pi@192.168.1.123
```

SSH automatically finds and uses `~/.ssh/id_ed25519`. If you set a passphrase, you will be prompted for it once. To avoid re-entering it every session, add the key to the SSH agent:
```bash
eval "$(ssh-agent -s)"   # start the agent
ssh-add ~/.ssh/rpi  # load the key (prompts for passphrase once)
```

=== Disable password login on the Pi

Once key authentication is confirmed to be working, you can disable password logins entirely to harden the Pi against brute-force attacks. Edit the SSH server config:
```bash
sudo vim /etc/ssh/sshd_config
```

Find and set the following lines _(restart the ssh service afterwards)_:
```
PasswordAuthentication no
PubkeyAuthentication yes
```
Then restart the SSH service:
```bash
sudo systemctl restart ssh
```

#warning[Do not disable password login until you have verified that key
  authentication works in a separate terminal session. Locking yourself out
  would require physical access to the Pi to recover.]

== Git and GitHub

#title-slide("Git and GitHub", "Version Control and Collaboration")

Git is a distributed version control system that tracks changes to files and directories over time. It allows you to commit snapshots of your work, branch off for experiments, and merge changes back together.

GitHub is a cloud-based hosting platform for Git repositories. It adds collaboration features such as pull requests, issues, and Actions on top of standard Git.

To install Git:
```bash
sudo apt install git
```

---

Basic initial configuration:
```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

To clone an existing repository from GitHub:
```bash
git clone https://github.com/a-mhamdi/rpi-onramp.git
```

---

*Using a key with GitHub*

The same key pair `rpi` and `rpi.pub` can authenticate you to GitHub, removing the need for HTTPS tokens when pushing code.

/*
```bash
cat ~/.ssh/rpi.pub
```
*/

Display your public key and copy the output. Then go to `GitHub` → `Settings` → `SSH and GPG keys` → `New SSH key`, paste it in, and save. Test the connection:
```bash
ssh -T git@github.com
# Expected: Hi <username>! You've successfully authenticated...
```

To switch an existing local repository from HTTPS to SSH:
```bash
git remote set-url origin git@github.com:<user>/<repo>.git
```

---

*Lazygit*

Lazygit is a terminal UI for Git that makes complex operations simple — stage individual lines, perform interactive rebases, and cherry-pick commits, all without memorising obscure flags.  It runs directly in your terminal, so there is no need to switch between your editor and a separate GUI application.  It is especially useful on the Raspberry Pi where you are often working entirely over SSH with no desktop environment.

To install it on Raspberry Pi OS:
```bash
sudo apt install lazygit
```

Launch it from inside any Git repository by simply running `lazygit`. Press `?` at any time to view the full list of keybindings.

#align(center)[
  #image("../images/lazygit.png", width: 70%)
]

For full documentation and source code, see #link("https://github.com/jesseduffield/lazygit")[github.com/jesseduffield/lazygit].
