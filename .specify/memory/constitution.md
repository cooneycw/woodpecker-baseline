# Project Constitution

> Governing principles for woodpecker-baseline.

## Core Principles

### P1: Deployment Safety Before Speed
All baseline recommendations must first minimize blast radius and rollback complexity.

### P2: Reproducible Signals
Every trap and success pattern must be backed by concrete evidence (commit history, config examples, or documented behavior).

### P3: Shared Contract Integrity
Cross-repo shared deployment scripts must be hash/version validated before execution.

### P4: Host Contention Awareness
Pipelines sharing Docker hosts must coordinate locks, cleanup cadence, and disk pressure management.

### P5: Spec-Driven Rollout
New baseline controls are accepted only after explicit specification and measurable acceptance criteria.
