<!-- flow-run n=1 id=0bcc00e93b9548f1972e1a468aa21a6a -->
## Run 1 - issue #1 as read

EVIDENCE OF WHAT THIS RUN READ, not a second statement of the contract.
The issue is the authority; read it. This copy exists so a later check can
report that the source moved. It does not graduate.

- Issue:        #1
- Read at:      2026-10-25T22:34:23Z
- updatedAt:    2026-04-12T13:13:53Z   (context only - moves on comments and labels)
- Body digest:  8a3bd4dabb9205b3ebf4c9be2c2c334729bf13a761c292436d9d6f82ac497a0b   (sha256 of the FULL body; the verdict keys on this)
- Stored bytes: 955 of 955 (cap 16384)

### Body as read
## Problem

Woodpecker CI agent runs deploy steps as root inside Docker containers. The deploy script bind-mounts the host workspace (e.g. `/home/cooneycw/Projects/voice-bot-acs`) and runs `make deploy` as root. This causes the following directories to become root-owned on the host:

- `.venv`
- `.runtime`
- `scripts`
- `.woodpecker`

Subsequent local development commands (`uv sync`, `make test`, etc.) fail with **permission denied** errors because the current user no longer owns these paths.

## Fix

A `make fix-ownership` Makefile target has been added to all three affected repos:

- `voice-bot-acs`
- `personas-service`
- `whisper-stt-bench`

This target is wired as the final step of each repo's `woodpecker_deploy.sh`. It uses the ownership of `.git/HEAD` as the reference for the correct host UID:GID and chowns the affected directories back to the original user.

## Repos updated

Commits pushed to `main` in all three repos on 2026-04-12.

<!-- end of body -->
