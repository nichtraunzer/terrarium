#!/usr/bin/env bash
# Common helper functions / variables

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

# Ensure the user-local bin directory is searchable even for non‑login shells
export PATH="$PATH:$HOME/.local/bin:/opt/bundle/bin"

# Short helper for “binary exists and prints a version”
check_binary() {
  local exe="$1"
  run "$exe" --version
  assert_success
}


# Usage: check_version xorriso -version
check_version() {
  local exe="$1"; shift
  run "$exe" "$@"
  assert_success
}
