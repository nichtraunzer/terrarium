#!/usr/bin/env bats
load 'test_helper/common.bash'

# bats file_tags=terraform

@test "Terraform via tenv works" {
  run tenv tf list
  assert_success
}

@test "TFLint Installed" { check_binary tflint; }

@test "terraform-docs Installed" { check_binary terraform-docs; }

@test "terraform-config-inspect Installed" {
  run terraform-config-inspect --json
  assert_success
}

@test "tfsec Installed" { check_binary tfsec; }
