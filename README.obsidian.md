---
title: bootstrap
tags:
  - infrastructure
  - reproducibility
  - conda
  - nlp
  - hpc
  - pestian-lab
updated: 2026-08-01
---

# Bootstrap

The lab's environment baseline. One sourced script gets any machine — a
workstation or an [[OSC]] HPC account — to the same `nlp-core` Conda
environment, so results move between machines without a dependency argument.

Repo: `~/projects/bootstrap` · `git@github.com:jpestian/bootstrap.git`

> [!note] The script is smaller than the docs suggest
> `bootstrap.sh` is five steps and does exactly one job: create/update the
> `nlp-core` Conda environment, activate it, and verify the imports. The
> workstation provisioning narrative in [[Workflow]] — directory trees, GPU
> detection, repo cloning — is a **manual checklist**, not automation. Read it
> that way when planning a new machine build.

## What it actually does

| Step | Action |
|------|--------|
| 1 | Load Conda — module system if present, local install otherwise |
| 2 | Check `config/nlp-core.yml` exists |
| 3 | `conda env create` / `conda env update --prune` for `nlp-core` |
| 4 | `conda activate nlp-core` |
| 5 | Import numpy, pandas, sklearn, transformers, sentence-transformers, umap, hdbscan, torch → print Torch + CUDA status |

Idempotent. Re-running updates rather than recreates.

> [!warning] Source it, don't run it
> `source bootstrap.sh` — `bash bootstrap.sh` puts the activation in a subshell
> that dies on exit. And because the script sets `set -euo pipefail`, sourcing
> it means a mid-script failure closes your terminal. Retry from a fresh shell.

## The environment

`config/nlp-core.yml` is the single source of truth. Python 3.11, the standard
scientific stack from conda-forge, and the ML layer from pip: `torch==2.5.1`,
transformers, sentence-transformers, `umap-learn`, `hdbscan`.

> [!important] Torch is not GPU-aware here
> `torch==2.5.1` is the plain PyPI pin. There is no CUDA-matched wheel
> selection, contrary to [[Workflow]]. Step 5 *reports* CUDA availability —
> it doesn't *arrange* for it. On a GPU box, verify before assuming acceleration.

There is a second file, `config/nlp_core_environment.yml`, that nothing reads.
It's an accidental export of a **base** env (`name: base`, Python 3.13, no ML
libraries). Ignore it, or delete it — see [[Next Session]].

## Current state — #status/stable

Clean tree, synced with `origin/main`. This session removed `obsidian-vault`
from `config/github_repos.txt`, taking the lab repo list to five: `bootstrap`,
[[nlp-core]], [[ManifoldExperiments]], [[litreview]], [[sacredtext]].

Worth knowing: `github_repos.txt` is a **manifest only** — no code reads it.
Cloning is still by hand.

## Things a planner should know #drift

[[Workflow]] describes behavior the script doesn't have:

- the `~/research` / `~/artifacts` / `~/containers` directory tree — not created
- GPU detection via `nvidia-smi` — doesn't happen
- a `MINICONDA_MODULE` override — doesn't exist; the module string
  `miniconda3/24.1.2-py310` is hardcoded at line 33
- repo cloning — not automated

None of these break a run. They break expectations when someone follows the
runbook on a new machine. When OSC upgrades their module, this becomes a real
file edit rather than an env-var.

## Related

- [[Workflow]] — the bare-metal → running-machine runbook (see drift note)
- [[Next Session]] — the handoff and the ordered fix list
- [[OSC]] — Pitzer / Owens accounts
- [[nlp-core]] — the environment's namesake project
- [[Syncthing]] — how project dirs stay in sync between machines

#pestian-lab #infrastructure #conda
