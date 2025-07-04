#!/usr/bin/env bats
load 'test_helper/common.bash'

# bats file_tags=terraform

@test "Terraform via tenv" {
  run tenv tf list
  assert_success
  assert_output --partial "1.9.4"
  assert_output --partial "1.4.6"
}

@test "TFLint" { check_binary tflint; }

@test "terraform-docs" { check_binary terraform-docs; }

# @test "terraform-config-inspect" { check_binary terraform-config-inspect; }
