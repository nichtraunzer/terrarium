#!/usr/bin/env bats
load 'test_helper/common.bash'

# bats file_tags=azure


# @azure
@test "Azure CLI (az) is available" {
  if command -v az >/dev/null; then
    run az --version
    assert_success
  else
    # Installed via `uv sync --directory /tmp`; run it from that project env
    run uv run --directory /tmp az --version
    assert_success
  fi
}

