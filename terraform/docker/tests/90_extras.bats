#!/usr/bin/env bats
load 'test_helper/common.bash'

# bats file_tags=extras

@test "Go is installed" {
  run go version
  assert_success
}

@test "Taskfile runner" { check_binary task; }

@test "Starship prompt" { check_binary starship; }

@test "yq CLI" { check_binary yq; }

@test "zoxide utility" { check_binary zoxide; }
