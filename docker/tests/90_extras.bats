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

@test "oc client is present" {
    run oc version --client
    assert_success
}

@test "openstack CLI is installed and on PATH" {
    run which openstack
    assert_success
}

@test "openstack CLI runs and shows version" {
    run openstack --version
    assert_success
    assert_output --partial "openstack"
}

@test "openstack help includes secret commands (barbican)" {
    run openstack secret store --help
    assert_success
    assert_output --partial "secret"
}

@test "trivy is installed" {
  run trivy version
  assert_success
}
