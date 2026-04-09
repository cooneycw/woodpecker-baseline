# External Woodpecker and CI/CD Pattern Review (2026-04-09)

## Sources Reviewed

1. Woodpecker workflow syntax docs (v3.11)
- https://woodpecker-ci.org/docs/3.11/usage/workflow-syntax

2. Woodpecker workflow syntax docs (v2.8, includes trusted/privileged notes)
- https://woodpecker-ci.org/docs/2.8/usage/workflow-syntax

3. Woodpecker project settings docs (trusted repository behavior)
- https://woodpecker-ci.org/docs/next/usage/project-settings

4. Upstream Woodpecker pipeline examples
- https://github.com/woodpecker-ci/woodpecker/blob/main/.woodpecker/test.yaml
- https://github.com/woodpecker-ci/woodpecker/blob/main/.woodpecker/docker.yaml

5. Curated list references
- https://github.com/sindresorhus/awesome
- https://github.com/cicdops/awesome-ciandcd

## Key Corroborating Signals

### A) Conditional execution and path scoping are first-class controls
Woodpecker docs and upstream `.woodpecker/test.yaml` heavily use `when` filters with branch/event/path scoping. This matches the local success pattern of narrowing deploy workflow triggers and reducing unnecessary pipeline activity.

### B) Dependency ordering is explicit and intentional
Woodpecker supports `depends_on` across workflows/steps. Upstream examples use explicit dependency graphs (`vendor` -> `lint/test` -> publish). This aligns with local fixes where deploy was split from CI and gated on successful prerequisite workflows.

### C) Agent routing via labels is expected design
Docs define labels for selecting capable agents. Local repos use this pattern (`deploy-host`, platform labels) to separate CI and deployment responsibilities.

### D) Trusted mode and privileged operations require caution
Docs highlight privileged execution constraints for trusted repos. Local patterns that mount `docker.sock` and host credentials should be treated as trusted-path operations with explicit guardrails and auditability.

### E) Curated lists are discovery aids, not policy sources
`awesome` and `awesome-ciandcd` are useful for tool discovery breadth. They are not normative operational guidance. Baseline policy should prioritize official docs and proven local evidence.

## External-to-Local Translation

1. Keep deploy workflows isolated and explicitly gated.
2. Use strict `when` conditions for branch/event/path.
3. Encode dependency graphs with `depends_on` instead of implicit sequencing.
4. Treat privileged and host-mounted deploy steps as controlled trust zones.
5. Document optional/non-blocking checks and fallback behavior explicitly.
