# Local Woodpecker History Scan (2026-04-09)

## Repo Inventory

Detected git repos with active Woodpecker configs:

1. claude-power-pack
2. codex-power-pack
3. personas-service
4. voice-bot-acs
5. whisper-stt-bench

## Commit Volume Snapshot (woodpecker config paths)

- claude-power-pack: 8 commits
- codex-power-pack: 12 commits
- personas-service: 19 commits
- voice-bot-acs: 83 commits
- whisper-stt-bench: 16 commits

## High-Signal Recurring Fix Clusters

1. Auth bootstrap and credential flow
- recurring fixes for `.netrc`, gh hosts token bootstrapping, and CI auth propagation
- examples: voice-bot-acs `e189c72`, `a84304c`, `2b9e2e0`; personas-service `4cd2af0`, `1660ae9`

2. Deploy race and contention on shared Docker hosts
- deploy lock added to prevent concurrent collisions
- docker cleanup moved to cron with lock coordination
- examples: voice-bot-acs `eb8d873`, `6e68bd9`; personas-service `b55816a`

3. Shared script contract drift management
- shared hash manifest + checker used to enforce synchronized scripts across repos
- examples: voice-bot-acs `a39bb57`, `a04576c`; whisper-stt-bench `d6fe152`

4. Canonical checkout and stale commit protections
- deploy scripts compare latest branch SHA and skip stale commits
- canonical host workspace sync before deploy
- examples: voice-bot-acs `2e344f5`, `ad83e23`, `57a8ac9`

5. Readiness mismatch fixes
- latest focused finding: service ping passed but secret fetch readiness failed
- PR #691 merged 2026-04-09 (`4f12c13`) added second gate to verify actual secret retrieval before migrations

## Recent Focused Finding: voice-bot-acs PR #691

- Merge commit: `4f12c138dc25da6ccabb753a70f30c331b78b064`
- Title: `fix(deploy): wait for secrets agent to serve secrets, not just ping (#691)`
- Date: 2026-04-09
- Impact:
  - closes deploy race where `/ping` was healthy before secret payload availability
  - introduces a two-phase readiness check:
    1. ping readiness
    2. actual secret fetch readiness with bounded retries
- Baseline implication:
  - health checks for critical dependencies must validate capability, not only liveness

## Current Pattern Strengths

- disciplined use of `labels` to route CI/deploy workloads to specific agents/hosts
- deployment scripts centralize operational guards
- fanout orchestration includes loop prevention and contract validation

## Current Pattern Gaps

- heavy host-coupling in absolute volume mounts can reduce portability
- some quality/security checks are intentionally non-blocking (`failure: ignore`) and need explicit rationale tracking
- fanout behavior still includes optional best-effort mode that may mask partial rollout failures if not monitored
