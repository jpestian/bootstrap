#!/usr/bin/env bash

set -euo pipefail

#############################################
# Machine profile
#############################################

MACHINE_TYPE=${1:-workstation}

echo
echo "============================================="
echo "Research Workstation Bootstrap"
echo "Machine type: $MACHINE_TYPE"
echo "============================================="
echo

#############################################
# Detect OS
#############################################

if [[ "$(uname)" != "Linux" ]]; then
    echo "This script is intended for Linux."
    exit 1
fi

#############################################
# Utility functions
#############################################

create_dir () {
    if [ -d "$1" ]; then
        echo "EXISTS   $1"
    else
        mkdir -p "$1"
        echo "CREATED  $1"
    fi
}

#############################################
# STEP 1 — Directory structure
#############################################

echo
echo "STEP 1 — Create directory structure"
echo

create_dir ~/projects

create_dir ~/research
create_dir ~/research/datasets
create_dir ~/research/datasets/raw
create_dir ~/research/datasets/processed
create_dir ~/research/embeddings

create_dir ~/research/models
create_dir ~/research/models/trained
create_dir ~/research/models/checkpoints

create_dir ~/artifacts
create_dir ~/artifacts/manifolds
create_dir ~/artifacts/clustering
create_dir ~/artifacts/visualizations

create_dir ~/containers
create_dir ~/containers/defs
create_dir ~/containers/images
create_dir ~/containers/experiments

create_dir ~/notebooks
create_dir ~/papers
create_dir ~/scripts
create_dir ~/config
create_dir ~/tmp

#############################################
# STEP 2 — Ensure scripts directory in PATH
#############################################

echo
echo "STEP 2 — Ensure scripts directory in PATH"

if grep -q "$HOME/scripts" ~/.bashrc; then
    echo "PATH already configured"
else
    echo 'export PATH=$PATH:$HOME/scripts' >> ~/.bashrc
    echo "Added ~/scripts to PATH"
fi

#############################################
# STEP 3 — Install core utilities
#############################################

echo
echo "STEP 3 — Install core utilities"

sudo apt update

sudo apt install -y \
git \
wget \
curl \
build-essential \
tmux \
htop \
tree \
ripgrep \
fd-find \
jq \
cmake

#############################################
# STEP 4 — Install Miniconda
#############################################

echo
echo "STEP 4 — Install Miniconda"

if [ -d "$HOME/miniconda3" ]; then
    echo "Miniconda already installed"
else

    cd /tmp

    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

    bash Miniconda3-latest-Linux-x86_64.sh -b -p "$HOME/miniconda3"

    rm Miniconda3-latest-Linux-x86_64.sh

    echo "Miniconda installed"

fi

#############################################
# STEP 5 — Initialize Conda
#############################################

echo
echo "STEP 5 — Initialize Conda"

source "$HOME/miniconda3/etc/profile.d/conda.sh"

#############################################
# STEP 6 — Restore conda environment
#############################################

echo
echo "STEP 6 — Restore conda environment"

if [ -f "$HOME/config/nlp_core_environment.yml" ]; then

    if conda env list | grep -q "nlp-core"; then
        echo "Environment 'nlp-core' already exists"
    else
        echo "Creating NLP environment..."
        conda env create -f "$HOME/config/nlp_core_environment.yml"
    fi

    conda activate nlp-core

else
    echo "No conda environment file found in ~/config"
fi

#############################################
# STEP 7 — Install additional apt packages
#############################################

echo
echo "STEP 7 — Install additional system packages"

if [ -f "$HOME/config/installed_packages_apt.txt" ]; then
    sudo apt install -y $(awk '{print $1}' "$HOME/config/installed_packages_apt.txt")
else
    echo "No apt package list found"
fi

#############################################
# STEP 8 — Configure git
#############################################

echo
echo "STEP 8 — Configure git"

git config --global init.defaultBranch main

if ! git config --global user.name >/dev/null; then
    git config --global user.name "John Pestian"
fi

if ! git config --global user.email >/dev/null; then
    git config --global user.email "your_email_here"
fi

#############################################
# STEP 9 — Ensure SSH key
#############################################

echo
echo "STEP 9 — Ensure SSH key"

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then

    ssh-keygen -t ed25519 -C "research" -f "$HOME/.ssh/id_ed25519" -N ""

    echo
    echo "SSH key created:"
    cat "$HOME/.ssh/id_ed25519.pub"

else
    echo "SSH key already exists"
fi

#############################################
# STEP 10 — Clone repositories
#############################################

echo
echo "STEP 10 — Clone repositories"

cd ~/projects

REPOS=(
"https://github.com/jpestian/nlp-core.git"
)

for repo in "${REPOS[@]}"; do

    name=$(basename "$repo" .git)

    if [ ! -d "$HOME/projects/$name" ]; then
        echo "Cloning $name ..."
        git clone "$repo"
    else
        echo "$name already present"
    fi

done

#############################################
# STEP 11 — Machine-specific configuration
#############################################

echo
echo "STEP 11 — Machine profile configuration"

case "$MACHINE_TYPE" in

workstation)
    echo "Applying workstation settings"
    ;;

server)
    echo "Applying server settings"
    ;;

nas)
    echo "Applying NAS settings"
    ;;

*)
    echo "Unknown machine type"
    ;;

esac

#############################################
# STEP 12 — System summary
#############################################

echo
echo "============================================="
echo "SYSTEM SUMMARY"
echo "============================================="

echo
echo "Hostname:"
hostname

echo
echo "CPU:"
lscpu | grep "Model name"

echo
echo "Memory:"
free -h

echo
echo "Disks:"
lsblk

echo
echo "============================================="
echo "Bootstrap complete"
echo "============================================="
echo
