# Next Session — Handoff

## State

Documentation-only pass. `README.md`, `README.obsidian.md`, and this file were
regenerated; no source or config was modified.

Git state:

- Working tree **clean**, in sync with `origin/main`. Latest commit: `3874446`
  ("SessionEnd: refresh docs for bootstrap").
- No changes were made to the repo this session beyond these three docs.
- Config baseline in `main`:
  - `config/github_repos.txt` — SSH remotes; six repos (`bootstrap`,
    `nlp-core`, `ManifoldExperiments`, `litreview`, `sacredtext`,
    `obsidian-vault`).
  - `config/nlp_core_environment.yml` — re-exported pins; `name:` is `base`.

Nothing is blocked. The items below are pre-existing, known, and unaddressed.

## Next steps (ordered)

1. **Fix the env-name mismatch.** `config/nlp_core_environment.yml` declares
   `name: base`, but `bootstrap.sh` STEP 6 checks for and activates `nlp-core`.
   Either set the YAML back to `name: nlp-core` (likely correct) or update the
   script. As-is, `conda env create -f` would target `base`, and the activate
   step would fail on a clean machine. **This is the highest-value fix** — it is
   the one bug that would actually break a fresh bootstrap.
2. **Decide what belongs in the env.** The current export is only the
   conda/anaconda base toolchain — no numpy/torch/transformers/etc. Either
   populate `nlp-core` with the real ML stack and re-export, or document that a
   separate environment holds the ML libraries.
3. **Refresh `docs/WORKFLOW.md`.** It still says
   `git clone …/workstation-bootstrap.git` and `bash setup_research_environment.sh`.
   Current names are `bootstrap` and `bootstrap.sh`. Update both.
4. **Confirm SSH-clone prerequisite.** With SSH remotes, STEP 10 needs the
   machine's key registered on GitHub first (STEP 9 generates and prints it,
   but does not upload it). Consider a note or pause in the script.

## Open questions / risks

- Is `name: base` in the env file intentional (e.g. exported straight from the
  active base env by accident) or a mistake? Treat as a mistake until confirmed.
- Should the ML libraries live in `nlp-core`, or is a bare base env the
  intended baseline with libs installed per-project?
- The top-level `artifacts/ data/ notebooks/ results/ scripts/ src/
  environment/` dirs are empty and untracked — are they meant to be here, or
  are they stray copies of `project_template/`?
- `installed_packages_apt.txt` is a full `dpkg --get-selections` dump (~2,300
  packages) from one machine — many are desktop/OS defaults. Reinstalling it
  wholesale on a new box pulls in a lot of unrelated software.
- There is no test suite; correctness of `bootstrap.sh` is only verified by
  running it. `bash -n bootstrap.sh` catches syntax errors but nothing else.

## Context pointers

- Main script: `bootstrap.sh` (twelve numbered STEP blocks; env logic at STEP 6,
  clone logic at STEP 10).
- Configs: `config/github_repos.txt`, `config/nlp_core_environment.yml`,
  `config/installed_packages_apt.txt`.
- Runbook: `docs/WORKFLOW.md` (stale names — see step 3).
- Regenerate manifests:
  - `conda env export --no-builds > config/nlp_core_environment.yml`
  - `dpkg --get-selections > config/installed_packages_apt.txt`
- Syntax check: `bash -n bootstrap.sh`
- Recent history: `git log --oneline -5`
