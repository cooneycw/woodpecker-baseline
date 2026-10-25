# Root-Owned Host Workspace Trap (2026-04-12)

## Context

Woodpecker deploy steps in `voice-bot-acs`, `personas-service` and `whisper-stt-bench`
run as root inside a Docker container that bind-mounts the canonical host workspace
(e.g. `/home/cooneycw/Projects/voice-bot-acs`) and runs `make deploy` there.
Source: woodpecker-baseline issue #1. Evidence re-checked against each repo's `main`
on 2026-10-25.

---

## Trap: Root-owned host workspace after a root-container deploy (spec taxonomy #8)

**Severity:** HIGH (breaks local development on the deploy host until repaired)

**Pattern detected:**
```yaml
image: ghcr.io/cooneycw/ci-deploy:3.12   # runs as root
volumes:
  - /home/cooneycw/Projects/voice-bot-acs:/home/cooneycw/Projects/voice-bot-acs
commands:
  - bash scripts/woodpecker_deploy.sh     # -> make deploy, as root, in the host tree
```

**Failure mode:** Every path the deploy creates or rewrites in the bind-mounted tree is
owned by `root:root` on the host. Observed: `.venv`, `.runtime`, `scripts`, `.woodpecker`.
The next local `uv sync`, `make test` or editor save fails with `Permission denied`.

**Root cause:** Same as Trap 2 (`ips-pipeline-traps-2026-04-11.md`): the container UID (0)
differs from the host owner of the workspace. Trap 2 is git refusing to read the tree;
this trap is the container leaving the tree unwritable for the host user.

**Proven fix (`make fix-ownership`, shipped 2026-04-12):** take the correct `UID:GID` from
a file the deploy never rewrites and chown the touched paths back. No-op when already
running as that user.

```make
fix-ownership:
	@REF_OWNER=$$(stat -c '%u:%g' .git/HEAD 2>/dev/null || echo ""); \
	if [ -z "$$REF_OWNER" ] || [ "$$REF_OWNER" = "$$(id -u):$$(id -g)" ]; then \
		exit 0; \
	fi; \
	for d in .venv .runtime scripts .woodpecker; do \
		[ -e "$$d" ] && chown -R "$$REF_OWNER" "$$d" 2>/dev/null || true; \
	done; \
	chown "$$REF_OWNER" . 2>/dev/null || true
```

**Variants in the wild:**

| Repo | Target | Reference | Paths repaired | Called from |
|------|--------|-----------|----------------|-------------|
| voice-bot-acs | `Makefile:465` | `.git/HEAD` | `.venv .runtime scripts .woodpecker node_modules` + `.` | `scripts/woodpecker_deploy.sh:93` |
| personas-service | `Makefile:191` | `.git/HEAD` | `.venv .runtime scripts .woodpecker` + `.` | `scripts/woodpecker_deploy.sh:95` |
| whisper-stt-bench | `Makefile:143` | `.` | whole tree (`chown -R .`) | `scripts/woodpecker_deploy.sh:78` |

Prefer `.git/HEAD` as the reference: the repo root itself can be re-owned by a previous
broken run, after which `stat .` reports `0:0` and the repair silently no-ops.

**Remaining gap - repair skipped on failure:** all three scripts run under
`set -euo pipefail` and call `make fix-ownership` as their last line. Only the deploy
lock release is registered on `trap ... EXIT`. A deploy that fails (a red `make deploy`,
a failed post-deploy gate) exits before the repair, leaving the tree root-owned exactly
when the developer starts debugging locally. Inferred from reading the scripts; not yet
reproduced on a real failed deploy.

Fix: run the repair from the exit handler, not the happy path:
```bash
on_exit() {
  rc=$?
  make -C "$HOST_CANONICAL_WORKSPACE" fix-ownership || true
  deploy_lock_release
  exit "$rc"
}
trap on_exit EXIT
```

**Alternative (avoid the trap entirely):** run the step as the host owner instead of
repairing afterwards, e.g. `docker run --user "$(stat -c %u:%g .git/HEAD)" ...`. Tradeoff:
the step then needs that UID to reach the Docker socket (group `docker`) and any
root-only paths, which is why the repair pattern was chosen first.

**Detection check:** any deploy script executed in a root container against a bind-mounted
host workspace must (a) call an ownership repair and (b) register it on `trap ... EXIT`.
Heuristic: `grep -n 'fix-ownership' scripts/woodpecker_deploy.sh` must match a line inside
the function passed to `trap ... EXIT`, not only a top-level line.

---

## Remediation Status

| Repo | Repair target | Wired into deploy | Runs on failure |
|------|---------------|-------------------|-----------------|
| voice-bot-acs | ✅ | ✅ | ❌ Open |
| personas-service | ✅ | ✅ | ❌ Open |
| whisper-stt-bench | ✅ (`.` reference) | ✅ | ❌ Open |
