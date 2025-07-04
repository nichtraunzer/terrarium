#!/usr/bin/env bats
load 'test_helper/common.bash'

# @extras
@test "Go is installed" {
  run go version
  assert_success
}

# @extras
@test "Taskfile runner" { check_binary task; }

# @extras
@test "Starship prompt" { check_binary starship; }

# @extras
@test "yq CLI" { check_binary yq; }

# @extras
@test "zoxide utility" { check_binary zoxide; }
