---
title: bootstrap
tags:
  - infrastructure
  - workstation
  - research-ops
  - conda
  - reproducibility
updated: 2026-07-02
---

# Bootstrap

The one-command way to bring a fresh Linux box up to the shared research
workstation baseline. `bootstrap.sh` builds the standard directory tree,
installs core tooling + Miniconda, restores a Conda environment, sets up Git
and SSH, and clones the working repos. Idempotent — re-running it is safe.

> [!note] Purpose
> Every research machine should end up **identical**: same directory layout,
> same Python environment, same cloned projects, same dataset paths. This repo
> is the source of truth for that baseline.

## Recent changes (committed)

- **#repos** — `config/github_repos.txt` moved from HTTPS to SSH remotes and
  grew to six: `bootstrap`, `nlp-core`, `ManifoldExperiments`, `litreview`,
  `sacredtext`, `obsidian-vault`. (The last of these is this very
  [[Obsidian]] vault.)
- **#conda** — `config/nlp_core_environment.yml` re-exported with current
  package pins (conda 26.1.1, Python 3.13.12).

> [!warning] Loose ends to reconcile
> - Env file says `name: base`, but `bootstrap.sh` still creates/activates
>   `nlp-core`. Pick one.
> - The exported env is **base-only** — no numpy/torch/transformers pinned yet.
> - `docs/WORKFLOW.md` still uses old names (`workstation-bootstrap` /
>   `setup_research_environment.sh`); current names are `bootstrap` /
>   `bootstrap.sh`.

## Mental model

Think of it as three manifests plus a driver:

- **Driver** — `bootstrap.sh`, twelve guarded steps.
- **What to clone** — `config/github_repos.txt`.
- **Python env** — `config/nlp_core_environment.yml`.
- **System packages** — `config/installed_packages_apt.txt` (~2,300 entries;
  a full `dpkg --get-selections` dump).

## The twelve steps at a glance

1. dirs → 2. PATH (`~/scripts`) → 3. core apt utils → 4. Miniconda →
5. conda init → 6. restore env → 7. extra apt packages → 8. git config →
9. ssh key → 10. clone repos → 11. machine profile (placeholder) →
12. system summary.

> [!tip] Machine profiles
> `bash bootstrap.sh {workstation|server|nas}` — currently just prints which
> profile is active. Hook for future per-machine divergence.

## Directory baseline

`~/projects` (git) · `~/research/{datasets,embeddings,models}` ·
`~/artifacts/{manifolds,clustering,visualizations}` ·
`~/containers/{defs,images,experiments}` · `~/notebooks` · `~/papers` ·
`~/scripts` · `~/config` · `~/tmp`

## Related notes

- [[Workflow]] — full bare-metal runbook (USB → Ubuntu → bootstrap →
  [[Syncthing]] sync).
- [[Project Template]] — scaffold for a new research project.
- [[nlp-core]] · [[ManifoldExperiments]] · [[litreview]] · [[sacredtext]]

> [!info] Planning prompt
> Next time you touch this: fix the `base` vs `nlp-core` env-name split, decide
> whether the ML libraries belong in the exported env or a separate one, and
> refresh `docs/WORKFLOW.md` to the current repo/script names.
