# Tasks: woodpecker-baseline-mvp

## Wave 1: Foundation

- [x] T001 Create repo scaffold and .specify structure
- [x] T002 Capture local Woodpecker repo inventory and commit summaries
- [x] T003 Record recent focused finding from voice-bot-acs PR #691
- [x] T004 Capture external Woodpecker and CI/CD references
- [x] T005 Draft baseline specification with trap taxonomy
- [x] T006 Add repeatable local history rescan script

## Wave 2: Hardening

- [ ] T007 Add machine-readable trap catalog (YAML/JSON)
- [ ] T008 Add policy checks that fail on missing mandatory controls
- [ ] T009 Add regression test fixtures for deployment guard scripts
- [ ] T010 Add changelog workflow for baseline versioning

## Wave 3: IPS Trap Integration (2026-04-11)

Findings from insurance-pricing-simulation pipeline failures #548, #552, #553.
Research file: `research/local/ips-pipeline-traps-2026-04-11.md`

- [ ] T011 Add Trap: volatile `apk add` tool install (Alpine regression risk) to catalog
- [ ] T012 Add Trap: git cross-ownership in Docker volume mounts (safe.directory missing)
- [ ] T013 Add Trap: `failure: ignore` as symptom masker (silent capability degradation)
- [ ] T014 Add Pattern: pre-built CI deploy image (Dockerfile.ci-deploy from voice-bot-acs)
- [ ] T015 Add Pattern: stale commit guard before deploy (ls-remote SHA comparison)
- [ ] T016 Extend detection checks: grep rules for `apk add aws-cli` and git-without-safe-directory
- [ ] T017 Rescan IPS repo history into local history scan (IPS was missing from April 9 scan)
