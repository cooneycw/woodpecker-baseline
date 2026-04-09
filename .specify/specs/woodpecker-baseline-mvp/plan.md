# Implementation Plan: woodpecker-baseline-mvp

## Summary

Build a baseline package containing: evidence corpus, trap/success specification, and a repeatable re-scan workflow.

## Workstreams

1. Local History Mining
- enumerate Woodpecker repos
- summarize deployment-related commit trajectories
- capture latest critical finding (`voice-bot-acs` PR #691)

2. Pattern Codification
- convert observed failures into trap checklist
- convert proven mitigations into baseline controls
- define mandatory vs optional controls

3. External Corroboration
- map controls to Woodpecker docs semantics (`when`, `depends_on`, labels, trust)
- compare with upstream Woodpecker pipeline patterns
- annotate curated CI/CD list references

4. Baseline Delivery
- finalize spec, tasks, and evidence docs
- include refresh script

## Risks

- Drift between repos can invalidate shared assumptions quickly.
- Overfitting baseline to one host topology may reduce portability.
- Curated list references can be broad or stale; weight official docs higher.

## Validation

- Manual review that each trap has evidence + control.
- Verify refresh script runs and produces output file.
- Verify README links all required artifacts.
