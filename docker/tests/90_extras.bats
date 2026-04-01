#!/usr/bin/env bats
load 'test_helper/common.bash'

# bats file_tags=extras

@test "Go is installed" {
  run go version
  assert_success
}

@test "Taskfile runner" { check_binary task; }

@test "Starship prompt" { check_binary starship; }

@test "Starship default config exists" {
  [ -f "$HOME/.config/starship.toml" ]
}

@test "yq CLI" { check_binary yq; }

@test "zoxide utility" { check_binary zoxide; }

@test "oc client is present" {
    run oc version --client
    assert_success
}

@test "trivy is installed" {
  run trivy version
  assert_success
}
