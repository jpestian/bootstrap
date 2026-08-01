# bootstrap

Reproducible Conda environment setup for Pestian Lab NLP/ML work. A single
idempotent script (`bootstrap.sh`) creates or updates the `nlp-core` Conda
environment from a checked-in spec, activates it, and verifies that the core
scientific and NLP libraries import cleanly. The same script runs on lab
workstations and on OSC HPC nodes — it loads Miniconda via the module system
when one is present, and via a local install otherwise. The repository also
carries the standard lab project scaffold (`data/`, `models/`, `outputs/`,
`logs/`) so a research project can be started from a known layout.

`WORKFLOW.md` is the broader runbook: bare-metal Ubuntu install through
Syncthing setup and OSC account provisioning.

## Status

Stable, working tree clean, in sync with `origin/main`.

This session's only substantive change was commit `1aea36d`, which removed
`obsidian-vault` from `config/github_repos.txt`, leaving five repositories in
the list. Everything else this session was documentation.

> **Documentation drift — `WORKFLOW.md` overstates what the script does.**
> Verified against the current `bootstrap.sh`:
>
> - It does **not** create the `~/research`, `~/artifacts`, `~/containers`,
>   `~/notebooks`, `~/papers`, `~/scripts`, `~/config`, `~/tmp` tree described
>   in WORKFLOW.md §8. Only the Conda environment is handled.
> - It does **not** detect a GPU via `nvidia-smi` or select a CUDA-matched
>   PyTorch build. `config/nlp-core.yml` pins `torch==2.5.1` from PyPI — the
>   default wheel. The verify step reports whether CUDA happens to be available;
>   it does not install for it.
> - It does **not** honor a `MINICONDA_MODULE` override. The module string
>   `miniconda3/24.1.2-py310` is hardcoded at line 33.
> - It does not clone repositories; `config/github_repos.txt` is a manifest
>   nothing reads.
>
> These are documentation bugs, not script bugs — the script does what it does
> correctly. See `NEXT_SESSION.md` for the resolution options.

## Setup

```bash
git clone git@github.com:jpestian/bootstrap.git ~/projects/bootstrap
cd ~/projects/bootstrap
source bootstrap.sh
```

**Source it, do not execute it.** `bash bootstrap.sh` runs in a subshell, so
the `conda activate nlp-core` in STEP 4 does not persist in your terminal.

> **Caveat:** the script sets `set -euo pipefail` at the top. When sourced,
> those options apply to your interactive shell, and a failure mid-script will
> close the terminal. If a run fails, open a fresh shell before retrying.

### Requirements

- Conda (Miniconda/Anaconda) reachable via `conda info --base`, or an
  environment-modules system providing `miniconda3/24.1.2-py310`.
- Network access for the conda-forge and PyPI downloads.
- No `sudo` is needed — the script installs nothing at the system level.

### On OSC (Pitzer / Owens)

The module system is detected automatically. If OSC has upgraded and
`miniconda3/24.1.2-py310` no longer exists, check `module avail miniconda` and
edit line 33 of `bootstrap.sh` — there is no override variable despite what
WORKFLOW.md §17.4 says.

## Run, test, build

There is nothing to build, and there is no test suite — this repository is one
shell script plus configuration. The available checks:

```bash
bash -n bootstrap.sh          # syntax parse only
source bootstrap.sh           # full run; STEP 5 is the real verification
conda env list                # confirm nlp-core exists and is active
```

STEP 5 imports `numpy`, `pandas`, `sklearn`, `transformers`,
`sentence_transformers`, `umap`, `hdbscan`, and `torch`, then prints
`ALL GOOD`, the Torch version, and CUDA availability. Any import failure exits
non-zero.

The script is idempotent: an existing `nlp-core` is updated with
`conda env update --prune`; otherwise it is created.

## What `bootstrap.sh` does

Five steps, ~110 lines:

1. **Initialize Conda** — `module purge` + `module load miniconda3/24.1.2-py310`
   if `module` exists, then source `conda.sh` from `$(conda info --base)`. Exits
   if `conda.sh` cannot be found.
2. **Validate repository** — confirm `config/nlp-core.yml` is present.
3. **Environment setup** — `conda env update -n nlp-core --prune` if the env
   exists, else `conda env create`.
4. **Activate** — `conda activate nlp-core`.
5. **Verify** — import the core stack and report Torch/CUDA status.

## Directory layout

```
bootstrap.sh                       # the provisioning script (5 steps)
WORKFLOW.md                        # full runbook: USB → Ubuntu → bootstrap → Syncthing → OSC
config/
  nlp-core.yml                     # THE environment spec — the only file bootstrap.sh reads
  nlp_core_environment.yml         # stale full export; unused (see below)
  github_repos.txt                 # 5 lab repos, SSH URLs; manifest only, nothing reads it
scripts/
  files.zip                        # archive of uncertain provenance — not referenced anywhere
data/{raw,processed,embeddings}/   # project scaffold, .gitkeep placeholders
models/{trained,checkpoints}/
outputs/{results,figures}/
logs/
.push_test                         # leftover from auto-push testing; safe to delete
```

### The two environment files

Only `config/nlp-core.yml` is used. It is a hand-maintained spec:
Python 3.11 with numpy, pandas, scipy, scikit-learn, matplotlib, seaborn, and
jupyterlab from conda-forge, plus `torch==2.5.1`, transformers, 
sentence-transformers, umap-learn, hdbscan, and tqdm from pip.

`config/nlp_core_environment.yml` is a `conda env export` of somebody's **base**
environment — it declares `name: base`, pins Python 3.13.12, and contains only
the conda/anaconda toolchain with no ML libraries. Nothing reads it. It is a
leftover and is a likely source of confusion; deleting it is proposed in
`NEXT_SESSION.md`.

### Git ignore behavior

`.gitignore` excludes `*.parquet`, `*.npy`, `*.pt`, `*.ckpt`, and `*.model`
repo-wide, but re-includes `data/raw/*.{csv,tsv,json,txt,parquet,npy}` so raw
inputs can be committed alongside a project.

## Related docs

- `WORKFLOW.md` — end-to-end workstation and OSC runbook (see the drift note above).
- `NEXT_SESSION.md` — current handoff, open questions, and proposed fixes.

## Author

John Pestian
