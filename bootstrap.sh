#!/usr/bin/env bash
set -euo pipefail

#############################################
# CONFIG
#############################################

ENV_NAME="nlp-core"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$REPO_DIR/config/nlp-core.yml"

#############################################
# HEADER
#############################################

echo
echo "============================================="
echo "Pestian Lab Bootstrap"
echo "============================================="
echo
echo "Repo: $REPO_DIR"
echo "Env file: $ENV_FILE"
echo

#############################################
# STEP 1 — Load Conda properly
#############################################

echo "STEP 1 — Initialize Conda"

if command -v module >/dev/null 2>&1; then
    module purge
    module load miniconda3/24.1.2-py310
fi

# CRITICAL FIX: explicitly source conda.sh
if [ -f "$(conda info --base 2>/dev/null)/etc/profile.d/conda.sh" ]; then
    source "$(conda info --base)/etc/profile.d/conda.sh"
else
    echo "ERROR: Could not find conda.sh"
    exit 1
fi

#############################################
# STEP 2 — Validate repo
#############################################

echo
echo "STEP 2 — Validate repository"

if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: Missing $ENV_FILE"
    exit 1
fi

#############################################
# STEP 3 — Create/update env
#############################################

echo
echo "STEP 3 — Environment setup"

if conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
    echo "Updating existing environment"
    conda env update -n "$ENV_NAME" -f "$ENV_FILE" --prune
else
    echo "Creating environment"
    conda env create -f "$ENV_FILE"
fi

#############################################
# STEP 4 — Activate env
#############################################

echo
echo "STEP 4 — Activate environment"

conda activate "$ENV_NAME"

#############################################
# STEP 5 — Verify
#############################################

echo
echo "STEP 5 — Verifying environment"

python - <<EOF
import numpy, pandas, sklearn
import transformers, sentence_transformers
import umap, hdbscan
import torch

print("ALL GOOD")
print("Torch:", torch.__version__)

if torch.cuda.is_available():
    print("CUDA: True")
    print("GPU:", torch.cuda.get_device_name(0))
else:
    print("CUDA: False")
EOF

#############################################
# DONE
#############################################

echo
echo "============================================="
echo "BOOTSTRAP COMPLETE"
echo "============================================="
echo
