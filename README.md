# Research Workstation Bootstrap

This repository provisions a reproducible research workstation for NLP and
machine-learning work. A single idempotent shell script (`bootstrap.sh`)
creates a standard directory layout, installs core tooling and Miniconda,
restores a Conda environment, configures Git and SSH, and clones the working
set of research repositories. The goal is that any freshly installed Linux
machine can be brought to a known-good, identical-across-machines state with
one command.

The script is safe to run repeatedly — every step checks for existing state
before acting.

## Status

This is a working setup repo, actively maintained by hand. The config changes
and documentation from recent sessions are committed and merged into `main`.
The most recent config work:

- **`config/github_repos.txt`** — switched from HTTPS to SSH (`git@github.com:…`)
  remotes and expanded the clone list to six repos: `bootstrap`, `nlp-core`,
  `ManifoldExperiments`, `litreview`, `sacredtext`, and `obsidian-vault`.
- **`config/nlp_core_environment.yml`** — refreshed pinned package versions
  from a current machine export (conda 26.1.1, Python 3.13.12, etc.).

> **Known inconsistencies (not yet resolved):**
> - The environment file now declares `name: base`, but `bootstrap.sh`
>   (STEP 6) still creates and activates an environment called `nlp-core`.
>   These need to be reconciled before the env step will behave as intended.
> - The exported environment currently contains only the conda/anaconda base
>   toolchain — it does **not** pin any NLP/ML libraries (no numpy, torch,
>   transformers, etc.).
> - `docs/WORKFLOW.md` still refers to an older repo name
>   (`workstation-bootstrap`) and script name (`setup_research_environment.sh`).
>   The current names are `bootstrap` and `bootstrap.sh`.

## Setup and usage

Clone the repository into `~/projects` (the script expects it at
`~/projects/bootstrap`) and run the bootstrap script:

```bash
git clone git@github.com:jpestian/bootstrap.git ~/projects/bootstrap
cd ~/projects/bootstrap
bash bootstrap.sh
```

An optional machine profile can be passed as the first argument (defaults to
`workstation`):

```bash
bash bootstrap.sh workstation
bash bootstrap.sh server
bash bootstrap.sh nas
```

The profile currently only prints which settings would be applied — it is a
placeholder for future machine-specific configuration.

### Requirements

- Linux (the script exits on any non-Linux OS).
- `sudo` access — several steps run `apt update` / `apt install`.
- For SSH clone URLs, a GitHub-registered SSH key. STEP 9 generates
  `~/.ssh/id_ed25519` if one does not exist and prints the public key; add it
  to GitHub before the clone step can succeed.

## What `bootstrap.sh` does

Twelve sequential, guarded steps:

1. **Directory structure** — creates the standard `~/research`, `~/artifacts`,
   `~/containers`, `~/notebooks`, `~/papers`, `~/scripts`, `~/config`, `~/tmp`,
   and `~/projects` tree.
2. **PATH** — appends `~/scripts` to `PATH` in `~/.bashrc` if absent.
3. **Core utilities** — `apt install` git, wget, curl, build-essential, tmux,
   htop, tree, ripgrep, fd-find, jq, cmake.
4. **Miniconda** — installs to `~/miniconda3` if not already present.
5. **Conda init** — sources `conda.sh`.
6. **Conda environment** — creates `nlp-core` from
   `config/nlp_core_environment.yml` if it does not exist, then activates it.
   (See the env-name caveat above.)
7. **Additional apt packages** — installs everything listed in
   `config/installed_packages_apt.txt`.
8. **Git** — sets `init.defaultBranch main` and default user name/email if unset.
9. **SSH key** — generates an ed25519 key if missing and prints the public key.
10. **Clone repositories** — clones every non-comment line in
    `config/github_repos.txt` into `~/projects`.
11. **Machine profile** — prints the profile-specific message (placeholder).
12. **System summary** — prints hostname, CPU, memory, and disk layout.

## Standard directory layout

The script creates this tree in the user's home directory:

```
~/projects                      # Git repositories
~/research
  datasets/{raw,processed}      # datasets
  embeddings
  models/{trained,checkpoints}
~/artifacts                     # experiment outputs
  {manifolds,clustering,visualizations}
~/containers
  {defs,images,experiments}
~/notebooks
~/papers
~/scripts                       # operational utilities (added to PATH)
~/config
~/tmp
```

## Repository layout

```
bootstrap.sh                    # the main provisioning script
config/
  github_repos.txt              # repos to clone (SSH URLs, one per line)
  nlp_core_environment.yml      # exported Conda environment
  installed_packages_apt.txt    # `apt` package manifest (dpkg --get-selections)
docs/
  README.md                     # earlier project README (superseded by this file)
  WORKFLOW.md                   # full bare-metal → running-workstation runbook
project_template/               # scaffold copied when starting a new project
  {data,src,scripts,notebooks,artifacts,results,docs,environment}/
  README.md
artifacts/ data/ notebooks/ results/ scripts/ src/ environment/
                                # empty working dirs mirroring the template
```

Note: the top-level `artifacts/`, `data/`, `notebooks/`, `results/`,
`scripts/`, `src/`, and `environment/` directories are empty scaffolding and
are not tracked in Git.

## Regenerating the config manifests

The two config manifests are exports from a reference machine and are meant to
be regenerated when the environment changes:

```bash
# Conda environment
conda env export --no-builds > config/nlp_core_environment.yml   # or with builds

# apt package selections
dpkg --get-selections > config/installed_packages_apt.txt
```

## Related docs

- `docs/WORKFLOW.md` — end-to-end runbook covering USB creation, Ubuntu
  install, running bootstrap, and Syncthing setup (note the stale names above).
- `project_template/README.md` — template README for new research projects.

## Author

John Pestian
