#!/usr/bin/env bats
load 'test_helper/common.bash'

# bats file_tags=terraform

@test "Terraform via tenv" {
  run tenv tf list
  assert_success
}

@test "TFLint" { check_binary tflint; }

@test "terraform-docs" { check_binary terraform-docs; }

@test "terraform-config-inspect" {
  run terraform-config-inspect --json
  assert_success
}
