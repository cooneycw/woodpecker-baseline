<!-- flow-run n=1 id=eb13e4e60d794db5a7c3a358cefbfd40 -->
## Run 1 - issue #4 as read

EVIDENCE OF WHAT THIS RUN READ, not a second statement of the contract.
The issue is the authority; read it. This copy exists so a later check can
report that the source moved. It does not graduate.

- Issue:        #4
- Read at:      2026-10-25T22:43:00Z
- updatedAt:    2026-10-25T22:40:09Z   (context only - moves on comments and labels)
- Body digest:  0b139504b0f164078081378b6e3d63ce9c029e4e1e0910be6815b443b6cde4ae   (sha256 of the FULL body; the verdict keys on this)
- Stored bytes: 1048 of 1048 (cap 16384)

### Body as read
## Problem

Found while running quality gates for #1 (PR #3).

`Makefile` runs `uv run --frozen ruff check . || ruff check .` and `uv run --frozen pytest || pytest`:

- The repo has no `uv.lock`, so `uv run --frozen` always fails (`Unable to find lockfile at uv.lock, but --frozen was provided`).
- `ruff` and `pytest` are declared only as the `dev` optional extra, so even with a lockfile a plain `uv run` would not install them.
- The `|| ruff` / `|| pytest` fallback only works if those tools are installed globally on the host.

Net effect: on a clean host `make lint`, `make test` and `make verify` exit 127. They passed for PR #3 only because `ruff` and `pytest` were installed as `uv tool`s on the host.

## Fix

- Move `pytest`/`ruff` to `[dependency-groups] dev` (installed by `uv sync` by default), run `uv lock`, and commit `uv.lock`.
- Keep `--frozen` once the lockfile exists.

## Also seen (same gate run)

The security gate warns that `.gitignore` is missing `.env.*`, `*.pem`, `*.key`, `secrets.*`, `*.p12`, `.claude/security.yml`.

<!-- end of body -->
