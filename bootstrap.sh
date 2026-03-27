#!/usr/bin/env bash
set -euo pipefail

#############################################
# CONFIG
#############################################

ENV_NAME="nlp-core"
ENV_FILE="$HOME/projects/bootstrap/config/nlp-core.yml"

#############################################
# HEADER
#############################################

echo
echo "============================================="
echo "OSC Bootstrap (Pitzer + Ascend Ready)"
echo "============================================="
echo

#############################################
# Detect HPC
#############################################

if command -v module >/dev/null 2>&1; then
    HPC_ENV=true
else
    echo "ERROR: This script is for OSC environments"
    exit 1
fi

#############################################
# STEP 1 — Load Conda
#############################################

echo "STEP 1 — Load Conda"

module purge
module load miniconda3/24.1.2-py310

eval "$(conda shell.bash hook)"

#############################################
# STEP 2 — Create / Update Environment
#############################################

echo "STEP 2 — Environment setup"

if conda env list | grep -q "$ENV_NAME"; then
    echo "Environment exists — updating from YAML"
    conda env update -n $ENV_NAME -f "$ENV_FILE" --prune
else
    echo "Creating environment from YAML"
    conda env create -f "$ENV_FILE"
fi

#############################################
# STEP 3 — Activate Environment
#############################################

echo "STEP 3 — Activate environment"

conda activate $ENV_NAME

#############################################
# STEP 4 — Ensure PyTorch (GPU-ready)
#############################################

echo "STEP 4 — Ensure PyTorch"

if ! python -c "import torch" >/dev/null 2>&1; then
    echo "Installing PyTorch"
    pip install torch --index-url https://download.pytorch.org/whl/cu121
else
    echo "PyTorch already installed"
fi

#############################################
# STEP 5 — Directory Structure
#############################################

echo "STEP 5 — Directories"

mkdir -p ~/projects
mkdir -p ~/research/{datasets/{raw,processed},embeddings,models/{trained,checkpoints}}
mkdir -p ~/artifacts/{manifolds,clustering,visualizations}
mkdir -p ~/notebooks ~/papers ~/scripts ~/config ~/tmp

#############################################
# STEP 6 — GPU check (robust)
#############################################

echo "STEP 6 — GPU check"

if python - <<EOF
import torch
exit(0 if torch.cuda.is_available() else 1)
EOF
then
    echo "GPU available to job"
    python -c "import torch; print(torch.cuda.get_device_name(0))"
else
    echo "No GPU available (expected on Pitzer or login node)"
fi

#############################################
# STEP 7 — Verify Environment
#############################################

echo "STEP 7 — Verify"

python - <<EOF
import numpy, pandas, sklearn
import transformers, sentence_transformers
import umap, hdbscan
import torch

print("ALL GOOD")
print("Torch:", torch.__version__)
print("CUDA:", torch.cuda.is_available())
EOF

#############################################
# STEP 8 — Export Clean YAML (optional sync)
#############################################

echo "STEP 8 — Export environment snapshot"

conda env export | grep -v "^prefix:" > "$ENV_FILE"

#############################################
# DONE
#############################################

echo
echo "============================================="
echo "BOOTSTRAP COMPLETE"
echo "============================================="
