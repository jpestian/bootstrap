# Research Workstation Bootstrap Workflow

This document describes the **complete workflow for installing and configuring a new research workstation** so that it matches existing systems.

The goal is to ensure every workstation shares:

- identical directory structure
- identical Conda environments
- synchronized research projects
- consistent dataset paths
- reproducible research infrastructure

---

# 0. Overview

Full setup process:

1. Create Ubuntu installer USB  
2. Boot machine from USB  
3. Install Ubuntu  
4. Update system  
5. Clone bootstrap repository  
6. Run bootstrap script  
7. Install Syncthing  
8. Configure synchronization  
9. Verify environment  

After completion the workstation will behave **identically to existing machines**.

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
git clone https://github.com/jpestian/workstation-bootstrap.git
```

Enter the repository:

```bash
cd workstation-bootstrap
```

---

# 7. Run Bootstrap Script

Execute the bootstrap script:

```bash
bash setup_research_environment.sh
```

The script performs the following:

- creates standardized research directories
- installs Miniconda if missing
- initializes Conda
- restores the NLP environment
- clones research repositories
- configures PATH for scripts

The script is **idempotent**, meaning it can safely run multiple times.

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
nlp-core
```

Activate environment:

```bash
conda activate nlp-core
```

Test Python:

```bash
python
```

Exit Python:

```
exit()
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
|------|------|
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

Verify required libraries load correctly.

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

# Result

The workstation now provides:

- identical research directory structure
- identical Python environment
- synchronized project repositories
- shared dataset access
- reproducible research infrastructure

