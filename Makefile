# Makefile — vendor key management + Docker build/test helpers
# Usage:
#   make                # shows help
#   make docker-build   # build runtime image
#   make docker-test    # build test stage then run bats tests in a disposable container
#   make docker-test-exec CONTAINER_NAME=terrarium  # run bats inside an existing container

# Ensure bash; fail fast and on broken pipelines for every recipe.
SHELL := /usr/bin/env bash
SHELLFLAGS := -eu -o pipefail -c

# ---------------- Configuration ----------------
# Keys management
KEYS_SCRIPT ?= terraform/docker/vendor-keys/refresh-vendor-keys.sh
ENV_FILE    ?= terraform/docker/vendor-keys/vendor-keys.env  # optional: where to stash shell-style pins

# Docker build/test
DOCKERFILE       ?= terraform/docker/Dockerfile.terrarium
DOCKER_CONTEXT   ?= terraform/docker
IMAGE            ?= terrarium
TAG              ?= latest
TEST_STAGE       ?= test                     # Dockerfile stage that runs tests
TEST_TAG         ?= test                     # Tag for test-stage image: $(IMAGE):$(TEST_TAG)
CONTAINER_NAME   ?= terrarium                # Used by docker-test-exec and as a default name
TEST_REPORT_DIR  ?= test-reports             # Host folder for JUnit/XML reports
BATS_TEST_PATH   ?= /home/terrarium/tests    # In-container path to your bats tests

# Docker cache control
# Usage: make docker-build NO_CACHE=1
#        make docker-build-test NO_CACHE=1
NO_CACHE         ?= 0

# CPU count (Linux, macOS, generic fallback)
NPROC := $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)

# Pretty output (no color in dumb terminals)
GREEN  := \033[32m
YELLOW := \033[33m
RED    := \033[31m
BOLD   := \033[1m
RESET  := \033[0m

.DEFAULT_GOAL := help

# ---------------- Internal helpers ----------------
define assert_docker
	command -v docker >/dev/null 2>&1 || { printf "$(RED)Error: docker is not installed or not in PATH$(RESET)\n" >&2; exit 127; }
	docker info >/dev/null 2>&1 || { printf "$(RED)Error: cannot talk to docker daemon. Is it running?$(RESET)\n" >&2; exit 1; }
endef

# $(call assert_file, path)
define assert_file
	test -f "$(1)" || { printf "$(RED)Error: missing file: $(1)$(RESET)\n" >&2; exit 1; }
endef

.PHONY: help verify-keys print-keys write-keys check-keys docker-build docker-build-test docker-test docker-test-exec

# ================== Meta ==================
help: ## Show this help (default)
	@printf "\n  $(BOLD)Targets$(RESET):\n"
	@grep -hE '^[a-zA-Z0-9_\/\.\-]+:.*##' $(MAKEFILE_LIST) \
	| awk 'BEGIN{FS=":.*##"} {printf "    %-22s %s\n", $$1, $$2}'
	@printf "\n  $(BOLD)Configurable vars$(RESET): IMAGE=%s TAG=%s DOCKERFILE=%s TEST_STAGE=%s TEST_REPORT_DIR=%s\n\n" \
	"$(IMAGE)" "$(TAG)" "$(DOCKERFILE)" "$(TEST_STAGE)" "$(TEST_REPORT_DIR)"

# ================== Vendor keys ==================
verify-keys: ## Re-fetch keys and show current fingerprints (+ diff vs env pins if provided)
	@$(call assert_file,$(KEYS_SCRIPT))
	@"$(KEYS_SCRIPT)" >/dev/null
	@printf "$(GREEN)OK: refresh completed$(RESET)\n"

print-keys: ## Print fresh key fingerprints (and show diff vs pins if $(ENV_FILE) exists)
	@$(call assert_file,$(KEYS_SCRIPT))
	@"$(KEYS_SCRIPT)"

write-keys: ## Write shell-style pins to $(ENV_FILE) for CI use (source it later)
	@$(call assert_file,$(KEYS_SCRIPT))
	@mkdir -p "$(dir $(ENV_FILE))"
	@"$(KEYS_SCRIPT)" print-shell-env >"$(ENV_FILE)"
	@printf "$(GREEN)Wrote $(ENV_FILE)$(RESET)\n"

check-keys: ## CI check: fail if computed fingerprints differ from pins in $(ENV_FILE)
	@$(call assert_file,$(KEYS_SCRIPT))
	@set -euo pipefail; \
	if [[ -f "$(ENV_FILE)" ]]; then \
	  set -a; source "$(ENV_FILE)"; set +a; \
	fi; \
	"$(KEYS_SCRIPT)" strict

# ================== Docker ==================
#
# Compose common build options and conditionally add --no-cache
DOCKER_BUILD_OPTS_BASE := --pull --progress=plain
ifeq ($(NO_CACHE),1)
  DOCKER_BUILD_OPTS := $(DOCKER_BUILD_OPTS_BASE) --no-cache
else
  DOCKER_BUILD_OPTS := $(DOCKER_BUILD_OPTS_BASE)
endif

docker-build: ## Build the runtime image: $(IMAGE):$(TAG) from $(DOCKERFILE)
	@$(assert_docker)
	@$(call assert_file,$(DOCKERFILE))
	@printf "$(YELLOW)Building $(IMAGE):$(TAG) with $(DOCKERFILE)...$(RESET)\n"
	@DOCKER_BUILDKIT=1 docker build \
		$(DOCKER_BUILD_OPTS) \
		-t "$(IMAGE):$(TAG)" \
		-f "$(DOCKERFILE)" $(DOCKER_CONTEXT)
	@printf "$(GREEN)Built $(IMAGE):$(TAG)$(RESET)\n"

docker-build-test: ## Build the test stage (runs bats at build-time) -> $(IMAGE):$(TEST_TAG); fails if bats fails
	@$(assert_docker)
	@$(call assert_file,$(DOCKERFILE))
	@printf "$(YELLOW)Building test stage '$(TEST_STAGE)' as $(IMAGE):$(TEST_TAG)...$(RESET)\n"
	@DOCKER_BUILDKIT=1 docker build \
		$(DOCKER_BUILD_OPTS) \
		--target "$(TEST_STAGE)" \
		-t "$(IMAGE):$(TEST_TAG)" \
		-f "$(DOCKERFILE)" $(DOCKER_CONTEXT)
	@printf "$(GREEN)Test stage built: $(IMAGE):$(TEST_TAG)$(RESET)\n"

docker-test: docker-build-test ## Build test stage then run bats in a disposable container; JUnit -> $(TEST_REPORT_DIR)
	@$(assert_docker)
	@mkdir -p "$(TEST_REPORT_DIR)"
	@docker rm -f "$(CONTAINER_NAME)-test-run" >/dev/null 2>&1 || true
	@printf "$(YELLOW)Running bats in container from $(IMAGE):$(TEST_TAG) ...$(RESET)\n"
	@docker run --rm --name "$(CONTAINER_NAME)-test-run" \
		-v "$(PWD)/$(TEST_REPORT_DIR)":/reports \
		"$(IMAGE):$(TEST_TAG)" \
		bash -lc 'if ! command -v bats >/dev/null; then echo "bats not found in image"; exit 127; fi; \
		          bats --report-formatter junit "$(BATS_TEST_PATH)" --output /reports --jobs $(NPROC)'
	@printf "$(GREEN)Tests complete. Reports at: $(TEST_REPORT_DIR)$(RESET)\n"

docker-test-exec: ## Run bats *inside an already-running* container $(CONTAINER_NAME); copies reports to $(TEST_REPORT_DIR)
	@$(assert_docker)
	@docker ps --format '{{.Names}}' | grep -xq '$(CONTAINER_NAME)' || { \
	  printf "$(RED)Error: container '$(CONTAINER_NAME)' is not running. Start it or set CONTAINER_NAME=...$(RESET)\n" >&2; exit 1; }
	@docker exec -i "$(CONTAINER_NAME)" bash -lc 'if ! command -v bats >/dev/null; then echo "bats not found in container"; exit 127; fi; \
		mkdir -p /reports; bats --report-formatter junit "$(BATS_TEST_PATH)" --output /reports --jobs $(NPROC)'
	@mkdir -p "$(TEST_REPORT_DIR)"
	@docker cp "$(CONTAINER_NAME):/reports" "$(TEST_REPORT_DIR)" >/dev/null 2>&1 || true
	@printf "$(GREEN)Tests complete. Reports copied to $(TEST_REPORT_DIR)/reports$(RESET)\n"

