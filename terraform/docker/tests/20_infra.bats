#!/usr/bin/env bats
# ↳ Infra tools unrelated to AWS / Terraform

load 'test_helper/common.bash'

# @infra
@test "Consul CLI" { check_binary consul; }

# @infra
@test "Packer CLI" { check_binary packer; }

# @infra
@test "Sops CLI" { check_binary sops; }

# @infra @crypto
@test "age‑keygen works" {
  tempfile=$(mktemp /tmp/agekey.XXXXXX)
  rm -f "$tempfile" # ensure it does not exist
  run age-keygen -o "$tempfile"
  assert_success
  [ -s "$tempfile" ]
  rm -f "$tempfile"
}
