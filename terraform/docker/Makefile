# Make sure we use bash for targets that source env files.
SHELL := /usr/bin/env bash

KEYS_SCRIPT := vendor-keys/refresh-vendor-keys.sh
ENV_FILE    := vendor-keys/vendor-keys.env  # optional: where to stash shell-style pins

.PHONY: verify-keys print-keys write-keys check-keys

## Re-fetch keys and show current fingerprints (+ diff vs env pins if provided)
verify-keys:
	@$(KEYS_SCRIPT) >/dev/null && echo "OK: refresh completed"

print-keys:
	@$(KEYS_SCRIPT)

## Write shell-style pins to $(ENV_FILE) for CI use (source it later)
write-keys:
	@mkdir -p $(dir $(ENV_FILE))
	@$(KEYS_SCRIPT) print-shell-env > $(ENV_FILE)
	@echo "Wrote $(ENV_FILE)"

## CI check: fail if computed fingerprints differ from the pins in $(ENV_FILE)
check-keys:
	@set -euo pipefail; \
	if [[ -f "$(ENV_FILE)" ]]; then \
	  set -a; source "$(ENV_FILE)"; set +a; \
	fi; \
	$(KEYS_SCRIPT) strict
