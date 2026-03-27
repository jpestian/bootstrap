cd ~/projects/bootstrap

cat > bootstrap.sh << 'EOF'
#!/bin/bash

# =====================================================
# Pestian Lab Bootstrap (PROJECT-CENTRIC ONLY)
# =====================================================

set -e

PROJECT_ROOT="$(pwd)"

echo "----------------------------------------"
echo "Initializing project at:"
echo "$PROJECT_ROOT"
echo "----------------------------------------"

# -----------------------------------------------------
# SAFETY CHECK — must be inside ~/projects
# -----------------------------------------------------
if [[ "$PROJECT_ROOT" != *"/projects/"* ]]; then
    echo "ERROR: Run this inside ~/projects/<project_name>"
    exit 1
fi

# -----------------------------------------------------
# CREATE PROJECT STRUCTURE (LOCAL ONLY)
# -----------------------------------------------------
mkdir -p "$PROJECT_ROOT/data/raw"
mkdir -p "$PROJECT_ROOT/data/processed"

mkdir -p "$PROJECT_ROOT/models/checkpoints"
mkdir -p "$PROJECT_ROOT/models/final"

mkdir -p "$PROJECT_ROOT/notebooks"
mkdir -p "$PROJECT_ROOT/scripts"

mkdir -p "$PROJECT_ROOT/outputs/figures"
mkdir -p "$PROJECT_ROOT/outputs/results"

mkdir -p "$PROJECT_ROOT/docs"

# -----------------------------------------------------
# ENVIRONMENT
# -----------------------------------------------------
if [ ! -f "$PROJECT_ROOT/environment.yml" ]; then
cat <<EOT > "$PROJECT_ROOT/environment.yml"
name: nlp-core
channels:
  - conda-forge
dependencies:
  - python=3.11
  - numpy
  - pandas
  - scikit-learn
  - matplotlib
  - jupyterlab
EOT
fi

# -----------------------------------------------------
# README
# -----------------------------------------------------
if [ ! -f "$PROJECT_ROOT/README.md" ]; then
cat <<EOT > "$PROJECT_ROOT/README.md"
# Project

## Structure
- data/
- models/
- notebooks/
- scripts/
- outputs/
- docs/

## Setup
conda env create -f environment.yml
conda activate nlp-core
EOT
fi

# -----------------------------------------------------
# GITIGNORE
# -----------------------------------------------------
if [ ! -f "$PROJECT_ROOT/.gitignore" ]; then
cat <<EOT > "$PROJECT_ROOT/.gitignore"
__pycache__/
*.pyc
.env
.ipynb_checkpoints/
outputs/
data/
models/
EOT
fi

echo "----------------------------------------"
echo "Bootstrap complete (project-scoped)"
echo "----------------------------------------"
EOF
