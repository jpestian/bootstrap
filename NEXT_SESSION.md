# Next Session — Handoff

## State

Working tree **clean**, in sync with `origin/main`. HEAD is `1aea36d`
("Remove obsidian-vault from bootstrap repositories", 2026-08-01 11:23), which
dropped one line from `config/github_repos.txt` — the list is now five repos:
`bootstrap`, `nlp-core`, `ManifoldExperiments`, `litreview`, `sacredtext`.

Everything else this session was documentation. `README.md`,
`README.obsidian.md`, and this file were regenerated; no source or config was
touched.

**Correction carried forward:** the previous `README.md` and `NEXT_SESSION.md`
described a repository that no longer exists — a twelve-step `bootstrap.sh`, a
`docs/` directory, `project_template/`, and
`config/installed_packages_apt.txt`. None of those are present. The tree was
restructured to the lab scaffold in commit `1487ee8`, and the docs were never
caught up; several doc-only sessions since then propagated the stale
description. The regenerated docs are written against the actual current files.
Prior handoff items about a `name: base` / `nlp-core` mismatch breaking the env
step were based on that stale reading — see item 1 below for what the real
situation is.

Nothing is blocked.

## Next steps (ordered)

1. **Delete or rename `config/nlp_core_environment.yml`.** It is an accidental
   `conda env export` of a *base* environment: `name: base`, Python 3.13.12,
   conda/anaconda toolchain only, no ML libraries. Nothing reads it —
   `bootstrap.sh` line 10 points at `config/nlp-core.yml`. Its only effect is
   to make readers think it's the real spec (it misled the last several
   sessions of documentation). Removing it is a one-line change with no
   runtime risk. Highest value for the effort.

2. **Reconcile `WORKFLOW.md` with the script.** Four claims in the runbook
   describe automation that doesn't exist:
   - §8 — the `~/research`, `~/artifacts`, `~/containers`, `~/notebooks`,
     `~/papers`, `~/scripts`, `~/config`, `~/tmp` tree. Not created.
   - §7 / §17.4 — "detects GPU via `nvidia-smi` and installs the correct
     PyTorch build." Doesn't happen; `torch==2.5.1` is a fixed PyPI pin.
   - §17.4 — `MINICONDA_MODULE=… source bootstrap.sh`. No such variable; the
     module string is hardcoded at `bootstrap.sh:33`.
   - Repo cloning from `config/github_repos.txt`. Not automated.

   Decide per item whether to **implement** it in the script or **reword** the
   runbook as a manual checklist. Rewording is cheaper and probably right for
   the directory tree and cloning; the `MINICONDA_MODULE` override is worth
   actually implementing (see item 3).

3. **Add the `MINICONDA_MODULE` override.** One line at `bootstrap.sh:33`:
   `module load "${MINICONDA_MODULE:-miniconda3/24.1.2-py310}"`. OSC rotates
   module versions, and today a rotation means editing and committing the
   script on every machine. This makes §17.4 true as written.

4. **Decide on GPU-aware Torch.** If lab or OSC GPU work is expected, the pip
   pin needs a CUDA index URL (or a conda-forge `pytorch-cuda` dependency)
   rather than the default wheel. If CPU-only is the intent, say so explicitly
   in `config/nlp-core.yml` so nobody has to infer it. Requires a decision
   before it can be implemented — see open questions.

5. **Clean up the strays.** `.push_test` (two lines of auto-push test output
   from 2026-07-09) and `scripts/files.zip` (2.6 KB, unreferenced, provenance
   unknown — inspect before deleting).

## Open questions / risks

- **Is GPU acceleration expected from this environment?** The verify step
  prints CUDA availability, which reads as though CUDA is being provisioned,
  but nothing installs for it. Someone could run GPU work on a CPU wheel and
  only notice via wall-clock. This is the one open question with a real
  correctness consequence.
- **Is `config/github_repos.txt` aspirational or vestigial?** It's a
  well-maintained manifest — updated as recently as this session — that no code
  reads. Either wire it into `bootstrap.sh` as a clone step or document it as a
  human reference list.
- **What is `scripts/files.zip`?** Not referenced anywhere. Unknown whether it
  matters.
- **`set -euo pipefail` in a sourced script.** The script must be sourced for
  `conda activate` to persist, but that means the strict-mode options apply to
  the interactive shell and any failure closes the user's terminal. Works fine
  on the happy path; hostile when something breaks. Consider a trap or a
  wrapper function.
- **No tests.** `bash -n bootstrap.sh` catches syntax only. Real verification
  is running it on a clean machine, which is slow and not something CI does.
- **Docs drift is the recurring failure mode here.** The stale README survived
  several sessions because each doc pass regenerated from the previous doc
  rather than from the tree. Read `bootstrap.sh` and `ls config/` first next
  time.

## Context pointers

```bash
cd ~/projects/bootstrap

# the script — read this before trusting any doc
cat bootstrap.sh              # 5 STEP blocks; env file at line 10, module at 33

# what's actually here
ls config/ scripts/           # nlp-core.yml is the real spec
cat config/nlp-core.yml

# checks
bash -n bootstrap.sh          # syntax only
source bootstrap.sh           # full run; STEP 5 verifies imports
conda env list                # nlp-core present + active?

# history
git log --oneline -10
git show 1487ee8 --stat       # the restructure the old docs missed
```

- Environment spec: `config/nlp-core.yml` — Python 3.11, conda-forge scientific
  stack, pip `torch==2.5.1` / transformers / sentence-transformers /
  umap-learn / hdbscan / tqdm.
- Runbook: `WORKFLOW.md` at repo root (not `docs/`) — accurate for the manual
  Ubuntu/Syncthing/OSC steps, inaccurate about the script. See step 2.
- Regenerate the env export, if it is kept:
  `conda env export --no-builds -n nlp-core > config/nlp_core_environment.yml`
