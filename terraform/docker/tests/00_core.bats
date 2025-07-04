#!/usr/bin/env bats

load 'test_helper/common.bash'

# @core
@test "OS is Rocky Linux 8" {
  run cat /etc/os-release
  assert_success
  assert_output --partial "Rocky Linux"
  assert_output --partial "8."
}

# @core
@test "Python is installed" {
  check_binary python
}

# @core
@test "jq is installed" {
  check_binary jq
}

# @core
@test "GNU parallel is installed" {
  run parallel --version
  assert_success
  assert_output --partial "GNU parallel"
}
