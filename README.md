# woodpecker-baseline

Baseline repository for analyzing Woodpecker deployment evolution across local projects and codifying stable patterns.

## Scope

- Identify repeat failure traps in Woodpecker-based deployment pipelines.
- Capture successful remediation patterns and turn them into enforceable checks.
- Maintain a spec-first baseline that can be applied to new repos.

## Inputs Included

- Local history scan across repos with `.woodpecker` or `.woodpecker.yml`:
  - `claude-power-pack`
  - `codex-power-pack`
  - `personas-service`
  - `voice-bot-acs`
  - `whisper-stt-bench`
- Focused recent finding in `voice-bot-acs`:
  - PR `#691` merged on `2026-04-09` (`4f12c13`): deploy readiness race fix for secrets agent fetch readiness.
- Online augmentation:
  - Woodpecker official docs
  - Woodpecker upstream pipeline YAML examples
  - Curated CI/CD list references (`awesome`, `awesome-ciandcd`)

## Key Outputs

- Baseline spec: `.specify/specs/woodpecker-baseline-mvp/spec.md`
- Implementation plan: `.specify/specs/woodpecker-baseline-mvp/plan.md`
- Tasks: `.specify/specs/woodpecker-baseline-mvp/tasks.md`
- Local evidence: `research/local/woodpecker-history-scan-2026-04-09.md`
- External evidence: `research/online/woodpecker-external-patterns-2026-04-09.md`

## Running A Refresh

```bash
bash scripts/rescan_local_woodpecker_history.sh
```
