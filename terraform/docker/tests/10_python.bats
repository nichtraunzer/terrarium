#!/usr/bin/env bats

load 'test_helper/common.bash'

# bats file_tags=python

@test "Python $PYTHON_VERSION is the global interpreter" {
  run python --version
  assert_success
  assert_output --partial "$PYTHON_VERSION"
}

@test "uv CLI is installed" {
  check_binary uv
}

@test "uv is the default Python launcher" {
  run uv --version
  assert_success
  assert_output --partial "uv"
}

@test "pyenv is installed" {
  check_binary pyenv
}
