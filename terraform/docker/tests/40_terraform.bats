#!/usr/bin/env bats
load 'test_helper/common.bash'

# @terraform
@test "Terraform via tenv" {
  run tenv tf list
  assert_success
  assert_output --partial "1.9.4"
  assert_output --partial "1.4.6"
}

# @terraform
@test "TFLint" { check_binary tflint; }

# @terraform
@test "terraform-docs" { check_binary terraform-docs; }

# @terraform
# @test "terraform-config-inspect" { check_binary terraform-config-inspect; }
