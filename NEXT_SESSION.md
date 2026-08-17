# Next Session — Handoff

## State

Working tree **clean**, in sync with `origin/main`.

**This session rewrote `bootstrap.sh`** across four commits:

- `30dd334` — idempotent rewrite: no exit-on-source (work fenced in a subshell),
  `--prune` opt-in via `NO_PRUNE`, HPC-gated module load, `DRY_RUN` mode.
- `b3d7073` — discover conda from standard install roots when not on `PATH`.
- `b1e09d6` — loosen torch pin to `>=2.5`; skip torch on GPU hosts to protect
  tuned CUDA builds.
- `1c3831d` — fix `USE_FILE` unbound in STEP 2; declare it early.

Net effect: the script is now genuinely idempotent and safe to source. Several
long-standing doc complaints are **resolved by code** this session — the
`MINICONDA_MODULE` override now exists (`bootstrap.sh:28`), GPU detection now
happens (STEP 2b), and the `set -euo pipefail`-closes-your-terminal hazard is
gone because provisioning runs in a subshell. The README and Obsidian note were
regenerated against the current script.

Nothing is blocked.

## Next steps (ordered)

1. **Reconcile `WORKFLOW.md` with the rewritten script.** Two claims that were
   previously wrong are now correct (`MINICONDA_MODULE`, GPU detection) — verify
   the runbook's wording matches. Two still describe automation that does not
   exist:
   - The `~/research` / `~/artifacts` / `~/containers` / `~/notebooks` / … home
     directory tree — not created by the script.
   - Cloning repos from `config/github_repos.txt` — not automated.

   Decide per item: **implement** in the script, or **reword** the runbook as a
   manual checklist. Rewording is cheaper and probably right for both.

2. **Delete or rename `config/nlp_core_environment.yml`.** It's an accidental
   `conda env export` of a *base* environment (`name: base`, conda/anaconda
   toolchain only, no ML libraries). Nothing reads it — `bootstrap.sh` points at
   `config/nlp-core.yml`. Its only effect is to mislead readers into thinking
   it's the real spec. One-line removal, no runtime risk.

3. **Decide the GPU-torch story and document it.** The script now *protects* an
   existing CUDA torch on a GPU host and installs nothing when one is missing —
   it does not build a CUDA-matched wheel. If the lab wants bootstrap to install
   GPU torch, the spec needs a CUDA index URL / `pytorch-cuda` dependency and
   STEP 2b needs an install branch. If "protect, don't install" is the intended
   policy, state that in `config/nlp-core.yml` and `WORKFLOW.md` so nobody
   expects auto-install. This is the one open question with a correctness
   consequence.

4. **Clean up the strays.** `.push_test` (94 bytes, auto-push test leftover from
   2026-07-09) and `scripts/files.zip` (2.6 KB, unreferenced, provenance
   unknown — inspect before deleting).

5. **Decide `config/github_repos.txt`'s role.** A well-maintained five-repo
   manifest that no code reads. Either wire it into `bootstrap.sh` as a clone
   step or document it explicitly as a human reference list.

## Open questions / risks

- **Is GPU torch expected to be provisioned, or only protected?** See step 3 —
  the current behavior is "leave a working CUDA build alone, never install one."
  If someone expects `source bootstrap.sh` to give them GPU acceleration, they
  will get a CPU wheel (CPU host) or a warning (GPU host without CUDA torch),
  not an install.
- **No tests.** `bash -n bootstrap.sh` catches syntax only; `DRY_RUN=1` exercises
  the control flow without changing anything. Real verification is a clean-machine
  run, which is slow and not in CI.
- **`config/nlp_core_environment.yml`** keeps confusing doc passes — remove it to
  end the recurring drift.
- **Docs drift is the recurring failure mode.** Read `bootstrap.sh` and
  `ls config/` before trusting any doc — the script changes faster than the prose.

## Context pointers

```bash
cd ~/projects/bootstrap

# the script — read this before trusting any doc
cat bootstrap.sh              # _bootstrap_main(): STEP 1, 2, 2b, 3, 4; module override at line 28

# what's actually here
ls config/ scripts/           # nlp-core.yml is the real spec
cat config/nlp-core.yml

# checks
bash -n bootstrap.sh          # syntax only
DRY_RUN=1 source bootstrap.sh # dry run — plan, no changes
source bootstrap.sh           # full run; STEP 4 verifies imports
conda env list                # nlp-core present + active?

# history
git log --oneline -8
git show 30dd334 --stat       # this session's idempotent rewrite
```

- Environment spec: `config/nlp-core.yml` — Python 3.11, conda-forge scientific
  stack, pip `torch>=2.5` / `transformers>=4.40` / `sentence-transformers>=2.6`
  / `umap-learn` / `hdbscan` / `tqdm`.
- Runbook: `WORKFLOW.md` at repo root — accurate for the manual Ubuntu/Syncthing/
  OSC steps; reconcile the directory-tree and cloning language (step 1).
- Regenerate the env export, if it is kept:
  `conda env export --no-builds -n nlp-core > config/nlp_core_environment.yml`
