#!/usr/bin/env bash
# Pestian Lab Bootstrap — idempotent. Source it: `source bootstrap.sh`
# DRY_RUN=1 source bootstrap.sh   → show plan, change nothing
# NO_PRUNE=0 source bootstrap.sh  → allow --prune (destructive, opt-in)

_bootstrap_main() {
  set -euo pipefail

  local ENV_NAME="nlp-core"
  local REPO_DIR ENV_FILE
  REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[1]:-$0}")" && pwd)"
  ENV_FILE="$REPO_DIR/config/nlp-core.yml"
  local DRY="${DRY_RUN:-0}" NO_PRUNE="${NO_PRUNE:-1}"

  echo; echo "============================================="
  echo "Pestian Lab Bootstrap   host=$(hostname -s)"
  [ "$DRY" = 1 ] && echo "*** DRY RUN — nothing will change ***"
  echo "============================================="
  echo "Repo:     $REPO_DIR"
  echo "Env file: $ENV_FILE"

  echo; echo "STEP 1 — Initialize Conda"
  # Only touch modules on a real HPC node. `module purge` on a GPU
  # workstation can unload a working CUDA environment.
  if command -v module >/dev/null 2>&1 && [ -n "${LMOD_SYSHOST:-${OSC_CLUSTER:-}}" ]; then
    echo "  HPC node detected — loading miniconda module"
    [ "$DRY" = 1 ] || { module purge; module load "${MINICONDA_MODULE:-miniconda3/24.1.2-py310}"; }
  else
    echo "  [skip]  not an HPC node — using local conda"
  fi
  local CONDA_BASE
  CONDA_BASE="$(conda info --base 2>/dev/null)" || { echo "ERROR: conda not found"; return 1; }
  [ -f "$CONDA_BASE/etc/profile.d/conda.sh" ] || { echo "ERROR: no conda.sh under $CONDA_BASE"; return 1; }
  # shellcheck disable=SC1091
  source "$CONDA_BASE/etc/profile.d/conda.sh"
  echo "  [ok]    conda base: $CONDA_BASE"

  echo; echo "STEP 2 — Validate repository"
  [ -f "$ENV_FILE" ] || { echo "ERROR: missing $ENV_FILE"; return 1; }
  echo "  [ok]    $ENV_FILE"

  echo; echo "STEP 3 — Environment setup"
  if conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
    if [ "$NO_PRUNE" = 1 ]; then
      echo "  [made]  updating $ENV_NAME (no --prune; hand-installed packages kept)"
      [ "$DRY" = 1 ] || conda env update -n "$ENV_NAME" -f "$ENV_FILE"
    else
      echo "  [WARN]  updating $ENV_NAME WITH --prune — packages not in spec will be REMOVED"
      [ "$DRY" = 1 ] || conda env update -n "$ENV_NAME" -f "$ENV_FILE" --prune
    fi
  else
    echo "  [made]  creating $ENV_NAME"
    [ "$DRY" = 1 ] || conda env create -f "$ENV_FILE"
  fi

  echo; echo "STEP 4 — Verify (in $ENV_NAME)"
  if [ "$DRY" = 1 ]; then
    echo "  [dry]   would import core stack and report Torch/CUDA"
    return 0
  fi
  conda run -n "$ENV_NAME" python - <<'PY'
import importlib, sys
mods = ["numpy","pandas","sklearn","transformers",
        "sentence_transformers","umap","hdbscan","torch"]
bad = []
for m in mods:
    try: importlib.import_module(m)
    except Exception as e: bad.append((m, e))
if bad:
    print("IMPORT FAILURES:")
    for m, e in bad: print(f"  {m}: {e}")
    sys.exit(1)
import torch
print("ALL GOOD")
print("Torch:", torch.__version__, "| CUDA build:", torch.version.cuda)
if torch.cuda.is_available():
    print("CUDA: True |", torch.cuda.device_count(), "GPU(s) |", torch.cuda.get_device_name(0))
else:
    print("CUDA: False  <-- CPU-only. Expected on a GPU host? Check the torch pin.")
PY
}

# Provision in a subshell so a failure cannot kill your interactive shell.
# Only `conda activate` runs in this shell, because it must.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  _bootstrap_main "$@"
else
  if ( _bootstrap_main "$@" ); then
    if [ "${DRY_RUN:-0}" != 1 ]; then
      source "$(conda info --base)/etc/profile.d/conda.sh"
      conda activate nlp-core
      echo; echo "  active env: $CONDA_DEFAULT_ENV"
    fi
    echo "============================================="
    echo "BOOTSTRAP COMPLETE"
    echo "============================================="
  else
    echo; echo "BOOTSTRAP FAILED — shell preserved, nothing partially activated" >&2
    return 1 2>/dev/null || true
  fi
fi
