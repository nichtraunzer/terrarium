#!/usr/bin/env bats

load 'test_helper/common.bash'

# bats file_tags=core

@test "OS is Enterprise Linux 9 family (UBI/RHEL/Rocky/Alma)" {
  run bash -lc '. /etc/os-release; printf "%s %s %s %s\n" "$ID" "$ID_LIKE" "$VERSION_ID" "$PRETTY_NAME"'
  assert_success
  # Accept any EL9 derivative and verify major version is 9
  assert_output --regexp '(rhel|rocky|almalinux|fedora)'
  assert_output --regexp '(^|[^0-9])9(\.|[^0-9]|$)'
}

@test "jq is installed" {
  check_binary jq
}

@test "GNU parallel is installed" {
  run parallel --version
  assert_success
  assert_output --partial "GNU parallel"
}

@test "Node is installed" {
  check_binary node
}
