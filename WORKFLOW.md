# Research Workstation Bootstrap Workflow

This document describes the **complete workflow for installing and configuring
a new research workstation or HPC account** so that it matches existing systems.

The goal is to ensure every machine shares:

- identical directory structure
- identical Conda environments
- synchronized research projects
- consistent dataset paths
- reproducible research infrastructure

---

# 0. Overview

Two machine types are supported:

| Type | Examples | Section |
|------|----------|---------|
| Lab workstation | 5860tower, ms-a2 | Steps 1–16 |
| OSC HPC account | Pitzer, Owens | Step 17 |

Both use the same bootstrap repository and the same `source bootstrap.sh`
command. The script detects the environment automatically.

---

# 1. Create Ubuntu Installation USB

Download Ubuntu ISO:

https://ubuntu.com/download

Example file:

```
ubuntu-24.04.4-desktop-amd64.iso
```

Create the USB installer (Linux):

```bash
sudo dd if=ubuntu-24.04.4-desktop-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Replace `/dev/sdX` with the correct USB device.

To identify the USB device:

```bash
lsblk
```

---

# 2. Boot Machine From USB

Insert the USB installer.

Restart the machine.

Press:

```
F12
```

Open the boot menu.

Select:

```
UEFI: USB Device
```

Start the Ubuntu installer.

---

# 3. Install Ubuntu

Choose:

```
Install Ubuntu
```

Recommended configuration:

Disk layout:

```
System disk: NVMe SSD
Filesystem: ext4
Install type: Erase disk and install Ubuntu
```

User configuration:

```
Username: same username used on other machines
Hostname: machine name (example: ms-a2)
```

Finish installation.

Reboot the machine.

Remove the USB installer.

---

# 4. Confirm Boot Disk

Verify the system booted from the internal drive:

```bash
findmnt /
```

Example output:

```
/dev/nvme0n1p3 /
```

This confirms the OS is running from the internal NVMe disk.

---

# 5. Update System

Open a terminal.

Update the system:

```bash
sudo apt update
sudo apt upgrade -y
```

Install essential tools:

```bash
sudo apt install -y git curl wget build-essential
```

Optional utilities:

```bash
sudo apt install -y htop tmux tree
```

---

# 6. Clone Bootstrap Repository

Navigate to home directory:

```bash
cd ~
```

Clone the workstation bootstrap repository:

```bash
git clone https://github.com/jpestian/bootstrap.git
```

Enter the repository:

```bash
cd bootstrap
```

---

# 7. Run Bootstrap Script

The script must be **sourced**, not executed, so the Conda environment
persists in your shell after it completes:

```bash
source bootstrap.sh
```

The script performs the following automatically:

- loads Miniconda (lab: local install, OSC: module system)
- creates or updates the `nlp-core` Conda environment
- detects GPU via `nvidia-smi` and installs the correct PyTorch build
- verifies all required packages load correctly

The script is **idempotent** — safe to run multiple times. Re-running it
updates an existing environment rather than recreating it.

> **Note:** Do not run as `bash bootstrap.sh`. That spawns a subshell and
> the conda activation will not persist in your terminal.

---

# 8. Standard Research Directory Structure

The bootstrap script creates the following layout:

```
~/projects

~/research
    datasets
        raw
        processed
    embeddings

    models
        trained
        checkpoints

~/artifacts
    manifolds
    clustering
    visualizations

~/containers
    defs
    images
    experiments

~/notebooks
~/papers
~/scripts
~/config
~/tmp
```

All machines must maintain **exactly the same structure**.

---

# 9. Verify Conda Installation

List environments:

```bash
conda env list
```

Expected environment:

```
nlp-core    *
```

The `*` confirms the environment is active. If it is not active:

```bash
conda activate nlp-core
```

Your prompt should show:

```
(nlp-core) username@hostname:~$
```

---

# 10. Install Syncthing

Install Syncthing:

```bash
sudo apt install syncthing
```

Start Syncthing:

```bash
syncthing
```

Open the interface:

```
http://localhost:8384
```

---

# 11. Connect Research Machines

Add the device ID of the primary workstation.

Approve the connection on both machines.

---

# 12. Configure Syncthing Folders

Recommended configuration:

| Folder | Mode |
|--------|------|
| `~/projects` | Send & Receive |
| `~/scripts` | Send & Receive |
| `~/papers` | Send & Receive |
| `~/notebooks` | Send & Receive |
| `~/artifacts` | Send & Receive |
| `~/research/datasets` | Receive Only |

Datasets remain controlled by the primary workstation.

---

# 13. Optional: Restore APT Packages

If the file exists:

```
~/config/installed_packages_apt.txt
```

Install packages:

```bash
sudo apt install $(awk '{print $1}' ~/config/installed_packages_apt.txt)
```

---

# 14. Validate Environment

Run verification commands:

```bash
ls ~/research
ls ~/projects
conda env list
```

Confirm:

- directories exist
- repositories cloned
- environment loads
- Syncthing connected

---

# 15. Test Research Environment

Navigate to projects:

```bash
cd ~/projects
```

Activate environment:

```bash
conda activate nlp-core
```

Start Python:

```bash
python
```

Verify required libraries load correctly:

```python
import torch
print(torch.__version__)
print(torch.cuda.is_available())
```

---

# 16. Final System Validation

Confirm:

```
Ubuntu installed
System updated
Conda installed
nlp-core environment active
Research directories created
Syncthing connected
```

The workstation is now fully configured.

---

# 17. OSC HPC Setup

This section covers bootstrapping an OSC account on Pitzer or Owens.
The same repository and script are used — the script detects the HPC
environment automatically via the module system.

## 17.1 Log in to OSC

```bash
ssh username@pitzer.osc.edu
# or
ssh username@owens.osc.edu
```

## 17.2 Check the Miniconda module name

Module versions change when OSC upgrades software. Always verify before
running the bootstrap:

```bash
module avail miniconda
```

Note the exact module string shown, for example:

```
miniconda3/24.1.2-py310
miniconda3/24.7.0-py311
```

## 17.3 Clone the bootstrap repository

```bash
cd ~
git clone https://github.com/jpestian/bootstrap.git
cd bootstrap
```

## 17.4 Run the bootstrap script

If the module name matches the default (`miniconda3/24.1.2-py310`):

```bash
source bootstrap.sh
```

If the module name has changed, override it inline:

```bash
MINICONDA_MODULE=miniconda3/24.7.0-py311 source bootstrap.sh
```

The script will:

- purge existing modules and load the correct Miniconda module
- create or update the `nlp-core` environment
- detect the GPU allocation and install the CUDA PyTorch wheel
- verify all packages

## 17.5 Update the default module name (if changed)

If you had to override the module name, update the default in `bootstrap.sh`
so future runs do not require the override:

```bash
# edit the CONFIG block at the top of bootstrap.sh
MINICONDA_MODULE="${MINICONDA_MODULE:-miniconda3/24.7.0-py311}"
```

Then push to GitHub:

```bash
git add bootstrap.sh
git commit -m "update OSC miniconda module version"
git push
```

## 17.6 Future OSC sessions

The bootstrap only needs to run once per OSC account. For subsequent sessions
just activate the environment after logging in:

```bash
module load miniconda3/24.1.2-py310
conda activate nlp-core
```

Or add both lines to your `~/.bashrc` on OSC so they run automatically on
login:

```bash
echo "module load miniconda3/24.1.2-py310" >> ~/.bashrc
echo "conda activate nlp-core" >> ~/.bashrc
```

---

# Result

Every machine — lab workstation or OSC node — provides:

- identical research directory structure
- identical Python environment
- synchronized project repositories
- shared dataset access
- reproducible research infrastructure
