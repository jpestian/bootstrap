# bootstrap

Reproducible Conda environment setup for Pestian Lab NLP/ML work. A single
idempotent script (`bootstrap.sh`) creates or updates the `nlp-core` Conda
environment from a checked-in spec, activates it, and verifies that the core
scientific and NLP libraries import cleanly. The same script runs on lab
workstations, GPU boxes, and OSC HPC nodes: it loads Miniconda via the module
system only on a real HPC node, discovers a local Conda install otherwise, and
deliberately leaves a working CUDA PyTorch alone on GPU hosts. The repository
also carries the standard lab project scaffold (`data/`, `models/`, `outputs/`,
`logs/`) so a research project can start from a known layout.

`WORKFLOW.md` is the broader runbook: bare-metal Ubuntu install through
Syncthing setup and OSC account provisioning.

## Status

Working tree clean, in sync with `origin/main`.

**This session rewrote `bootstrap.sh`.** The script is now genuinely idempotent
and considerably safer than the version the previous docs described. The
substantive changes:

- **Provisioning runs in a subshell** (`bootstrap.sh:117-135`). When sourced, a
  mid-script failure no longer closes your terminal — only `conda activate`
  touches your interactive shell, and only on success. The old warning about
  `set -euo pipefail` killing the terminal no longer applies.
- **`--prune` is opt-in.** `NO_PRUNE=1` is the default, so an update keeps
  hand-installed packages. Pass `NO_PRUNE=0` to allow the destructive prune.
- **`DRY_RUN=1`** prints the plan and changes nothing.
- **HPC-gated module load.** `module purge` / `module load` fire only when a
  real HPC node is detected (`LMOD_SYSHOST` / `OSC_CLUSTER` set), not merely
  because a `module` command exists. This protects a GPU workstation's tuned
  environment.
- **`MINICONDA_MODULE` override now exists** (`bootstrap.sh:28`), defaulting to
  `miniconda3/24.1.2-py310`. OSC module rotations no longer require editing the
  script.
- **Conda discovery** falls back to standard install roots (`~/miniconda3`,
  `~/anaconda3`, `~/miniforge3`, `~/mambaforge`, `/opt/conda`, …) when `conda`
  is not on `PATH` — important in non-interactive shells.
- **GPU / torch policy (STEP 2b).** On a GPU host the script detects the card
  with `nvidia-smi`; if a working CUDA PyTorch is already present it strips
  `torch` from the spec and leaves the tuned build untouched. If a GPU is present
  but no working CUDA torch, it *warns* and installs nothing — you install a
  driver-matched build by hand. On a non-GPU host, torch comes from the spec.
- **torch pin loosened** to `torch>=2.5` in `config/nlp-core.yml`.

> [!note] Documentation reconciliation still pending
> `WORKFLOW.md` still describes some automation the script does not perform —
> the `~/research`/`~/artifacts`/… directory tree and cloning repos from
> `config/github_repos.txt`. Those remain manual. The `MINICONDA_MODULE` and
> GPU-detection claims that were previously wrong are now **correct** after this
> session's rewrite. See `NEXT_SESSION.md`.

## Setup

```bash
git clone git@github.com:jpestian/bootstrap.git ~/projects/bootstrap
cd ~/projects/bootstrap
source bootstrap.sh
```

**Source it, do not execute it.** `bash bootstrap.sh` runs in a subshell, so the
`conda activate nlp-core` at the end does not persist in your terminal. When
sourced, the script activates `nlp-core` in your current shell on success.

### Requirements

- Conda (Miniconda/Anaconda/Miniforge) reachable via `conda info --base` or in a
  standard install root, or — on an HPC node — an environment-modules system
  providing a Miniconda module.
- Network access for the conda-forge and PyPI downloads.
- No `sudo` — the script installs nothing at the system level.

### Options

```bash
DRY_RUN=1   source bootstrap.sh   # show the plan, change nothing
NO_PRUNE=0  source bootstrap.sh   # allow destructive --prune on update
MINICONDA_MODULE=miniconda3/24.1.2-py310 source bootstrap.sh   # HPC module override
```

### On OSC (Pitzer / Owens)

An HPC node is detected via `LMOD_SYSHOST` / `OSC_CLUSTER`, and the Miniconda
module is loaded automatically. If OSC has rotated module versions, set
`MINICONDA_MODULE` to the current one (`module avail miniconda` to find it) —
no script edit required.

## Run, test, build

There is nothing to build and no unit-test suite — this repository is one shell
script plus configuration. The available checks:

```bash
bash -n bootstrap.sh          # syntax parse only
DRY_RUN=1 source bootstrap.sh # dry run: prints the plan, no changes
source bootstrap.sh           # full run; STEP 4 is the real verification
conda env list                # confirm nlp-core exists and is active
```

STEP 4 imports `numpy`, `pandas`, `sklearn`, `transformers`,
`sentence_transformers`, `umap`, `hdbscan`, and `torch` via `conda run`, then
prints `ALL GOOD`, the Torch version, the CUDA build, and whether CUDA is
available. Any import failure exits non-zero.

The script is idempotent: an existing `nlp-core` is updated (`conda env update`,
without `--prune` unless `NO_PRUNE=0`); otherwise it is created.

## What `bootstrap.sh` does

The work is wrapped in `_bootstrap_main()` and run in a subshell when sourced:

1. **STEP 1 — Initialize Conda.** On an HPC node only, `module purge` +
   `module load "${MINICONDA_MODULE:-miniconda3/24.1.2-py310}"`. Then locate the
   Conda base via `conda info --base` or a standard-install-root probe, and
   source `conda.sh`. Errors out if no Conda is found.
2. **STEP 2 — Validate repository.** Confirm `config/nlp-core.yml` is present.
3. **STEP 2b — GPU / torch policy.** Detect a GPU with `nvidia-smi`; if a
   working CUDA torch is present, build a torch-free copy of the spec so the
   tuned build is left alone. Warn (and install nothing) if a GPU is present
   without working CUDA torch.
4. **STEP 3 — Environment setup.** `conda env update -n nlp-core` if the env
   exists (add `--prune` only when `NO_PRUNE=0`), else `conda env create`.
5. **STEP 4 — Verify.** Import the core stack with `conda run -n nlp-core` and
   report Torch / CUDA status.
6. On success, when sourced, `conda activate nlp-core` in the caller's shell.

## Directory layout

```
bootstrap.sh                       # the provisioning script (subshell-wrapped, idempotent)
WORKFLOW.md                        # full runbook: USB → Ubuntu → bootstrap → Syncthing → OSC
config/
  nlp-core.yml                     # THE environment spec — the only file bootstrap.sh reads
  nlp_core_environment.yml         # stale full export of a base env; unused (see below)
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

Only `config/nlp-core.yml` is used. It is a hand-maintained spec: Python 3.11
with numpy, pandas, scipy, scikit-learn, matplotlib, seaborn, and jupyterlab
from conda-forge, plus `torch>=2.5`, `transformers>=4.40`,
`sentence-transformers>=2.6`, `umap-learn`, `hdbscan`, and `tqdm` from pip.

`config/nlp_core_environment.yml` is a `conda env export` of somebody's **base**
environment — it declares `name: base`, pins an old Python, and contains only
the conda/anaconda toolchain with no ML libraries. Nothing reads it. It is a
leftover and a likely source of confusion; deleting it is proposed in
`NEXT_SESSION.md`.

### Git ignore behavior

`.gitignore` excludes `*.parquet`, `*.npy`, `*.pt`, `*.ckpt`, and `*.model`
repo-wide, but re-includes `data/raw/*.{csv,tsv,json,txt,parquet,npy}` so raw
inputs can be committed alongside a project.

## Related docs

- `WORKFLOW.md` — end-to-end workstation and OSC runbook (see the note above).
- `NEXT_SESSION.md` — current handoff, open questions, and proposed fixes.

## Author

John Pestian
