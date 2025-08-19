#!/usr/bin/env bats
load 'test_helper/common.bash'

# bats file_tags=

# @k8s
@test "kubectl present (skipped if absent)" {
  if ! command -v kubectl >/dev/null; then
    skip "kubectl not provided in this image"
  fi
  run kubectl version --client
  assert_success
}

# @k8s
@test "Helm present (skipped if absent)" {
  if ! command -v helm >/dev/null; then
    skip "Helm not provided in this image"
  fi
  run helm version
  assert_success
}
