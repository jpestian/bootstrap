---
title: bootstrap
tags:
  - infrastructure
  - reproducibility
  - conda
  - nlp
  - hpc
  - pestian-lab
updated: 2026-08-17
---

# Bootstrap

The lab's environment baseline. One sourced script gets any machine — a
workstation, a GPU box, or an [[OSC]] HPC account — to the same `nlp-core` Conda
environment, so results move between machines without a dependency argument.

Repo: `~/projects/bootstrap` · `git@github.com:jpestian/bootstrap.git`

> [!note] The script got a real rewrite this session
> `bootstrap.sh` is now genuinely idempotent and safe to source. Provisioning
> runs in a **subshell**, so a failure no longer closes your terminal. `--prune`
> is opt-in, there's a `DRY_RUN` mode, module loading is gated to actual HPC
> nodes, and it now honors a `MINICONDA_MODULE` override and detects GPUs. The
> job is still exactly one thing: create/update `nlp-core`, activate it, verify
> the imports.

## What it actually does

| Step | Action |
|------|--------|
| 1  | Load Conda — module system **only on an HPC node**, else discover a local install |
| 2  | Check `config/nlp-core.yml` exists |
| 2b | GPU/torch policy — on a GPU host, leave a working CUDA torch alone; never install a CUDA build |
| 3  | `conda env create` / `conda env update` for `nlp-core` (`--prune` only if `NO_PRUNE=0`) |
| 4  | Import numpy, pandas, sklearn, transformers, sentence-transformers, umap, hdbscan, torch → print Torch + CUDA status |
| —  | On success (when sourced): `conda activate nlp-core` in your shell |

Idempotent. Re-running updates rather than recreates.

> [!tip] Source it, don't run it — but it's forgiving now
> `source bootstrap.sh` — `bash bootstrap.sh` puts the activation in a subshell
> that dies on exit. Unlike the old version, a mid-run failure **won't** close
> your terminal: the strict-mode work is fenced inside a subshell.

### Knobs

```bash
DRY_RUN=1   source bootstrap.sh   # plan only
NO_PRUNE=0  source bootstrap.sh   # allow destructive --prune
MINICONDA_MODULE=miniconda3/24.1.2-py310 source bootstrap.sh
```

## The environment

`config/nlp-core.yml` is the single source of truth. Python 3.11, the standard
scientific stack from conda-forge, and the ML layer from pip: `torch>=2.5`,
`transformers>=4.40`, `sentence-transformers>=2.6`, `umap-learn`, `hdbscan`,
`tqdm`.

> [!important] Torch on GPU hosts is hands-off, not auto-installed
> On a GPU box the script **protects** an existing CUDA torch by dropping torch
> from the spec — it does not build or install a CUDA-matched wheel for you. If
> there's a GPU but no working CUDA torch, you get a warning and install one by
> hand. On CPU hosts, torch comes straight from the spec.

There is a second file, `config/nlp_core_environment.yml`, that nothing reads.
It's an accidental export of a **base** env (`name: base`, no ML libraries).
Ignore it, or delete it — see [[Next Session]].

## Current state — #status/stable

Clean tree, synced with `origin/main`. The lab repo list in `github_repos.txt`
is five: `bootstrap`, [[nlp-core]], [[ManifoldExperiments]], [[litreview]],
[[sacredtext]]. That file is a **manifest only** — no code reads it; cloning is
still by hand.

## Things a planner should know #drift

[[Workflow]] still describes some automation the script doesn't do:

- the `~/research` / `~/artifacts` / `~/containers` directory tree — not created
- repo cloning from `github_repos.txt` — not automated

Two claims that *were* wrong are now **true** after this session: the
`MINICONDA_MODULE` override exists (`bootstrap.sh:28`) and GPU detection happens
(STEP 2b). Reconcile the runbook's directory-tree and cloning language next.

## Related

- [[Workflow]] — the bare-metal → running-machine runbook (see drift note)
- [[Next Session]] — the handoff and the ordered fix list
- [[OSC]] — Pitzer / Owens accounts
- [[nlp-core]] — the environment's namesake project
- [[Syncthing]] — how project dirs stay in sync between machines

#pestian-lab #infrastructure #conda
