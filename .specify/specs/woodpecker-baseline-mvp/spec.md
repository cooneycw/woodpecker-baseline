# Feature Specification: woodpecker-baseline-mvp

## Overview

Create a reusable Woodpecker deployment baseline that detects high-probability traps and prescribes proven mitigation patterns validated by local repo history and external references.

## Problem Statement

Across active repos, Woodpecker deployment behavior evolved through repeated fixes in auth bootstrap, stale commit handling, Docker host contention, script drift, and service readiness races. Without a baseline, the same incidents are likely to recur in new or refactored pipelines.

## User Stories

### US1: Trap detection
As a maintainer, I want a trap taxonomy and detection checklist so I can catch common deployment failures before merge.

Acceptance criteria:
- [ ] Trap classes are documented with concrete examples.
- [ ] Each trap has at least one proactive detection check.
- [ ] Each trap has a mitigation pattern with tradeoffs.

### US2: Success pattern reuse
As a maintainer, I want reusable patterns for locks, stale guards, fanout controls, and readiness checks so pipeline hardening is consistent.

Acceptance criteria:
- [ ] Patterns include copy-pasteable guard criteria.
- [ ] Patterns map to concrete repo evidence.
- [ ] Required versus optional controls are clearly separated.

### US3: External corroboration
As a maintainer, I want external references from official docs and real-world pipeline code so baseline choices are not purely local assumptions.

Acceptance criteria:
- [ ] Woodpecker docs references cover workflow filters, dependencies, labels, and trust/security constraints.
- [ ] At least one upstream Woodpecker pipeline YAML is analyzed for pattern comparison.
- [ ] Curated CI/CD references are included with relevance notes.

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| R1 | Baseline defines trap taxonomy with severity and detection method | Must |
| R2 | Baseline defines mandatory controls for production deploy workflows | Must |
| R3 | Baseline defines optional controls for scale/perf optimizations | Should |
| R4 | Baseline includes repo-specific evidence and commit references | Must |
| R5 | Baseline includes external references and compatibility notes | Must |
| R6 | Baseline includes refresh workflow for periodic rescans | Should |

## Trap Taxonomy (Initial)

1. Authentication bootstrap drift
2. Stale commit deployment
3. Cross-project concurrent deploy contention
4. Docker disk pressure and cache race conditions
5. Shared script contract drift across fanout repos
6. False readiness checks (service ping != service usable)
7. Deploy source divergence (CI checkout vs canonical host clone)
8. Root-owned host workspace after root-container deploy (`research/local/root-owned-workspace-trap-2026-04-12.md`)

## Success Criteria

- [ ] A new repo can adopt the baseline without requiring undocumented tribal knowledge.
- [ ] Repeated incident classes from April 2026 (auth, lock, drift, readiness) map to enforceable checks.
- [ ] Baseline can be refreshed with one script command and produce auditable output.
