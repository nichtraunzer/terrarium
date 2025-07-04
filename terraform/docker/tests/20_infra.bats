#!/usr/bin/env bats
# ↳ Infra tools unrelated to AWS / Terraform

load 'test_helper/common.bash'

# bats file_tags=infra

@test "Consul CLI" { check_binary consul; }

@test "Packer CLI" { check_binary packer; }

@test "Sops CLI" { check_binary sops; }

# bats test_tags=crypto
@test "age‑keygen works" {
  tempfile=$(mktemp /tmp/agekey.XXXXXX)
  rm -f "$tempfile" # ensure it does not exist
  run age-keygen -o "$tempfile"
  assert_success
  [ -s "$tempfile" ]
  rm -f "$tempfile"
}
