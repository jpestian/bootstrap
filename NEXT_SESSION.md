# Next Session — Handoff

## State

Documentation-only pass just completed. `README.md`, `README.obsidian.md`, and
this file were regenerated to match the current tree. No source code changed.

Git state:

- Working tree is clean and up to date with `origin/main`; the config and doc
  work from prior sessions is committed and merged (latest: `0e9df7f`).
- Only untracked item is `.push_test` (a throwaway artifact — safe to delete;
  not part of the project).
- Config baseline in `main`:
  - `config/github_repos.txt` — SSH remotes; six repos (`bootstrap`,
    `nlp-core`, `ManifoldExperiments`, `litreview`, `sacredtext`,
    `obsidian-vault`).
  - `config/nlp_core_environment.yml` — re-exported pins; `name:` is `base`.

## Next steps (ordered)

1. **Fix the env-name mismatch.** `config/nlp_core_environment.yml` declares
   `name: base`, but `bootstrap.sh` STEP 6 checks for and activates `nlp-core`.
   Either set the YAML back to `name: nlp-core` (likely correct) or update the
   script. As-is, `conda env create -f` would target `base`, and the activate
   step would fail on a clean machine.
2. **Decide what belongs in the env.** The current export is only the
   conda/anaconda base toolchain — no numpy/torch/transformers/etc. Either
   populate `nlp-core` with the real ML stack and re-export, or document that a
   separate environment holds the ML libraries.
3. **Refresh `docs/WORKFLOW.md`.** It still says
   `git clone …/workstation-bootstrap.git` and `bash setup_research_environment.sh`.
   Current names are `bootstrap` and `bootstrap.sh`. Update both.
4. **Confirm SSH-clone prerequisite.** With SSH remotes, STEP 10 needs the
   machine's key registered on GitHub first (STEP 9 generates and prints it,
   but does not upload it). Consider a note/pause in the script.
5. **Tidy up.** Remove the stray `.push_test` file if it is not needed.

## Open questions / risks

- Is `name: base` in the env file intentional (e.g. exported straight from the
  active base env by accident) or a mistake? Treat as a mistake until confirmed.
- Should the ML libraries live in `nlp-core`, or is a bare base env the
  intended baseline with libs installed per-project?
- The top-level `artifacts/ data/ notebooks/ results/ scripts/ src/
  environment/` dirs are empty and untracked — are they meant to be here, or
  are they stray copies of `project_template/`?
- `installed_packages_apt.txt` is a full `dpkg --get-selections` dump (~2,300
  packages) from one machine — many are desktop/OS defaults. Fine to reinstall
  wholesale, but worth knowing it is not a curated list.

## Context pointers

- Main script: `bootstrap.sh` (twelve numbered STEP blocks).
- Configs: `config/github_repos.txt`, `config/nlp_core_environment.yml`,
  `config/installed_packages_apt.txt`.
- Runbook: `docs/WORKFLOW.md` (stale names — see step 3).
- Regenerate manifests:
  - `conda env export --no-builds > config/nlp_core_environment.yml`
  - `dpkg --get-selections > config/installed_packages_apt.txt`
- Recent history: `git log --oneline -5`
