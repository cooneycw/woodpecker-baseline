.PHONY: lint test verify report

lint:
	uv run --frozen ruff check .

test:
	uv run --frozen pytest

verify: lint test

report:
	bash scripts/rescan_local_woodpecker_history.sh
