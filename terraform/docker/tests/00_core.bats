#!/usr/bin/env bats

load 'test_helper/common.bash'

# bats file_tags=core

@test "OS is Rocky Linux 8" {
  run cat /etc/os-release
  assert_success
  assert_output --partial "Rocky Linux"
  assert_output --partial "8."
}

@test "Python is installed" {
  check_binary python
}

@test "jq is installed" {
  check_binary jq
}

@test "GNU parallel is installed" {
  run parallel --version
  assert_success
  assert_output --partial "GNU parallel"
}
