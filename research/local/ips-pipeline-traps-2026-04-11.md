# IPS Pipeline Trap Analysis (2026-04-11)

## Context

Diagnosed from insurance-pricing-simulation Woodpecker pipelines #548, #552, #553 (all failed).
Cross-referenced against voice-bot-acs mature pipeline patterns (83-commit history).

---

## Trap 1: Volatile tool installation via `apk add` in CI steps

**Severity:** HIGH (silent regression, systemic)

**Pattern detected:**
```yaml
image: docker:27-cli   # Alpine-based
commands:
  - apk add --no-cache aws-cli   # ← TRAP
  - aws sts get-caller-identity
```

**Failure mode:** Alpine 3.21 ships a broken `aws-cli` apk. The pyexpat CPython extension
(`pyexpat.cpython-312-x86_64-linux-musl.so`) has an unresolved symbol
`XML_SetAllocTrackerActivationThreshold`. `aws` crashes at import before executing any command.

**Why it keeps recurring:** `failure: ignore` on affected ci.yml steps masks the failure.
Developers assume the step is "handled." engine-container.yml and web-container.yml use the
same `apk add aws-cli` pattern but have NO `failure: ignore` — those pipelines will fail
catastrophically when engine/** or frontend/** paths change.

**Affected files in IPS:**
- `.woodpecker/ci.yml` lines 82, 100 (failure: ignore — masked)
- `.woodpecker/engine-container.yml` line 45 (NO failure: ignore — BLOCKING)
- `.woodpecker/web-container.yml` line 47 (NO failure: ignore — BLOCKING)

**Correct patterns (already in IPS):**
- `infra.yml`: uses `image: amazon/aws-cli:2.15.0` — correct, version-pinned
- `deploy-prod.yml`: uses `pip install --quiet awscli` — correct, Debian-based image

**voice-bot-acs solution:** `Dockerfile.ci-deploy` — pre-baked image using
`python:3.12-slim-bookworm` with `pip install --quiet --no-cache-dir awscli`.
Tools are baked once into a versioned image, not installed fresh on every pipeline run.

**Detection check:** `grep -r 'apk add.*aws-cli' .woodpecker/` must return zero results.

---

## Trap 2: Git cross-ownership failure in Docker volume mounts

**Severity:** HIGH (blocks every deploy)

**Pattern detected:**
```yaml
image: docker:27-cli   # runs as root
volumes:
  - /home/cooneycw/Projects/insurance-pricing-simulation:/home/cooneycw/Projects/...
commands:
  - apk add --no-cache bash git
  - |
    cd /home/cooneycw/Projects/insurance-pricing-simulation
    git fetch origin        # ← EXIT 128: "dubious ownership"
    git checkout $CI_COMMIT_SHA
```

**Failure mode:** Git 2.35.2+ refuses to operate on a `.git` directory owned by a different
user than the current process. Container runs as root; host directory owned by `cooneycw`.
Exit code 128 on every pipeline run.

**Why it keeps recurring:** The fix was never applied. The voice-bot-acs deploy script sets
`git config --global --add safe.directory "*"` on line 4 of `woodpecker_deploy.sh` — IPS
inline deploy-dev.yml was written from scratch without referencing this working pattern.

**Fix:**
```bash
git config --global --add safe.directory "$REPO_DIR"
# or globally:
git config --global --add safe.directory "*"
```
Must be executed BEFORE any `git fetch`, `git checkout`, or `git log` in the step.

**voice-bot-acs evidence:** `scripts/woodpecker_deploy.sh` line 4 — proven fix pattern.

**Detection check:** Any step with both a host-directory volume mount AND a git command must
have a preceding `git config --global safe.directory` call.

---

## Trap 3: `failure: ignore` as a symptom masker

**Severity:** MEDIUM (silent capability degradation)

**Pattern detected:**
```yaml
- name: build-and-push-sidecar
  failure: ignore   # ← TRAP if step does real work
  commands:
    - apk add --no-cache aws-cli   # always fails
    - ...push sidecar image to ECR...
```

**Failure mode:** The ECR sidecar image is never updated. Downstream `deploy-prod` pulls a
stale image. The failure is invisible in pipeline UI — the step shows as "ignored" not "broken."

**Rule:** `failure: ignore` is appropriate for:
- Advisory/informational checks with no downstream dependencies
- Fully best-effort work that is genuinely optional

`failure: ignore` is NOT appropriate for:
- Steps that push artifacts consumed by other pipelines
- Steps where the failure masks an underlying regression

**Detection check:** Every step with `failure: ignore` must have a documented rationale comment
explaining why the failure is acceptable and what degrades when it fails.

---

## Pattern: Pre-built CI deploy image

**Severity:** N/A (recommended pattern, not a trap)

**voice-bot-acs pattern (`Dockerfile.ci-deploy`):**
```dockerfile
FROM python:3.12-slim-bookworm   # Debian, not Alpine — avoids musl regressions

RUN apt-get install -y make curl git bash python3 python3-pip \
    docker-ce-cli docker-compose-plugin

RUN pip install --quiet --no-cache-dir "uv==0.7.12" awscli
```

Built once, tagged `ghcr.io/cooneycw/ci-deploy:3.12`, pulled in pipeline with `pull: false`.

**Benefits:**
- No volatile `apk add` on every run
- Debian-based: avoids Alpine musl-specific package regressions
- `pip install awscli` vs `apk add aws-cli`: stable across OS versions
- `pull: false` uses the locally cached image — fast startup, no registry dependency

**Adoption path for IPS:**
1. Create `deploy/docker/ci-deploy/Dockerfile` using this pattern
2. Add `build-ci-image` step in ci.yml (early, runs once per push)
3. Replace `docker:27-cli` + `apk add aws-cli` steps with `ghcr.io/cooneycw/ci-deploy:3.12`
4. Remove all `apk add aws-cli` lines

---

## Pattern: Stale commit guard in deploy scripts

**voice-bot-acs `woodpecker_deploy.sh`:**
```bash
LATEST_SHA="$(git ls-remote origin "refs/heads/$DEPLOY_BRANCH" | awk '{print $1}')"
DEPLOY_SHA="${CI_COMMIT_SHA:-$(git rev-parse HEAD)}"
if [ "$DEPLOY_SHA" != "$LATEST_SHA" ]; then
  echo "Skipping deploy for stale commit $DEPLOY_SHA; latest $DEPLOY_BRANCH is $LATEST_SHA"
  exit 0
fi
```

IPS has no equivalent guard. If two pushes happen quickly, both deploys run concurrently
against the same host. The second deploy may overwrite the first mid-flight.

---

## IPS-Specific Remediation Priority

| Priority | Fix | Effort | Blocks |
|----------|-----|--------|--------|
| 1 | Add `git config --global safe.directory` to deploy-dev.yml | 1 line | Every push |
| 2 | Fix `apk add aws-cli` in engine-container.yml + web-container.yml | Small | Next engine/web change |
| 3 | Fix `apk add aws-cli` in ci.yml sidecar steps + remove `failure: ignore` | Small | Sidecar ECR push |
| 4 | Adopt pre-built CI deploy image (Dockerfile.ci-deploy pattern) | Medium | Long-term fragility |
| 5 | Add stale commit guard to deploy-dev.yml | Small | Race conditions |
