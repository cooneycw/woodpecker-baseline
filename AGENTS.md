# woodpecker-baseline

## Overview

Repository for Woodpecker deployment baseline specifications, trap taxonomy, and reusable validation patterns derived from local repo history and external references.

## CI/CD Protocol

- Use Makefile targets for lint, test, verify, and report generation.
- Keep `.woodpecker*` updates paired with script or test updates.
- Treat deployment scripts as production code: every hardening change should include deterministic tests or validation checks.

## Quality Gates

- `make lint`
- `make test`
- `make verify`
