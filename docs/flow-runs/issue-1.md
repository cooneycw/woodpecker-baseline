# Flow run record - issue #1

HISTORICAL RECORD of what was agreed BEFORE the code was written, at the base SHA
each run below names. It is not a description of the shipped system, it is not a
second statement of the issue contract or of a Tier 3 spec, and it does not
graduate. APPEND-ONLY (#1320): each /flow:auto run adds its own `## Run <n>`
section; nothing earlier is edited, and every check reads only its own run.

<!-- flow-run n=1 id=0bcc00e93b9548f1972e1a468aa21a6a -->
## Run 1

- Run-id:            0bcc00e93b9548f1972e1a468aa21a6a
- Run-start:         72433537b7dd27513707eb30c840554faa0507e7
- Issue:             #1
- Base SHA:          72433537b7dd27513707eb30c840554faa0507e7
- Necessity verdict: Partially addressed
- Approval:          granted
- Approver:          cooneycw (repo owner, "approved" in the /flow:auto session)
- Recorded at:       2026-10-25T00:00:00Z

### Section B evidence
- Remediation already shipped on main of all three repos: voice-bot-acs Makefile:465 + scripts/woodpecker_deploy.sh:93; personas-service Makefile:191 + deploy script:95; whisper-stt-bench Makefile:143 + deploy script:78.
- Gap: all three scripts use `set -euo pipefail` and call `make fix-ownership` as the last line; only the lock release is on `trap ... EXIT`, so a failed deploy skips the repair.
- Commits in woodpecker-baseline since 2026-04-12: none (HEAD 7243353).
- Merged PRs: none. Duplicate/superseding issues: none (#2 unrelated); account-wide search for fix-ownership/root-owned: none.

### Section C - the approved plan
1. `research/local/root-owned-workspace-trap-2026-04-12.md` - new trap write-up: severity, failure mode, root cause, proven fix and cross-repo variant comparison, failed-deploy gap, detection check, alternative mitigation, remediation table.
2. `.specify/specs/woodpecker-baseline-mvp/spec.md` - add trap 8 "Root-owned host workspace after root-container deploy" to the taxonomy.
3. `.specify/specs/woodpecker-baseline-mvp/tasks.md` - add T018 (trap entry, done) and T019 (open: exit-handler detection check).

Scope: docs only, 3 files, ~90 lines. Risk: failed-deploy gap is inferred from script reading, not reproduced; fixes to the three app repos are out of scope (owner follow-up).
