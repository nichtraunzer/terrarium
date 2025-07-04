#!/usr/bin/env bats
# shellcheck shell=bash

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

@test "OS is Rocky Linux 8" {
  run cat /etc/os-release
  assert_success
  assert_output --partial "Rocky Linux"
  assert_output --partial "8."
}

@test "Python is installed" {
  run python --version
  assert_success
}

@test "AWS CLI is installed" {
  run aws --version
  assert_success
}

@test "Terraform is installed" {
  run terraform version --json
  assert_success
}

@test "TFLint is installed" {
  run tflint --version
  assert_success
}

@test "Packer is installed" {
  run packer --version
  assert_success
}

@test "Consul is installed" {
  run consul -version
  assert_success
}

@test "terraform-docs is installed" {
  run terraform-docs --version
  assert_success
}

@test "Sops is installed" {
  run sops --version
  assert_success
}

@test "Age is installed" {
  run age --version
  assert_success
}

@test "Node.js is installed" {
  run node --version
  assert_success
}

@test "AWS CDK is installed" {
  run cdk --version
  assert_success
}

@test "Helm present" {
  if ! command -v helm >/dev/null; then
    skip "Helm not installed"
  fi
  run helm version --short
  assert_success
}

@test "Starship is installed" {
  run starship --version
  assert_success
}

@test "Go is installed" {
  run go version
  assert_success
}

@test "Task is installed" {
  run task --version
  assert_success
}

@test "yq is installed" {
  run yq --version
  assert_success
}

@test "Ruby via rbenv is installed" {
  run ruby --version
  assert_success
}

# ---------- CLI basics ----------
@test "jq is installed" {
  run jq --version
  assert_success
}

@test "GNU parallel is installed" {
  run parallel --version
  assert_success
  assert_output --partial "GNU parallel"
}

# ---------- AWS / Serverless ----------
@test "AWS SAM CLI is installed" {
  run sam --version
  assert_success
  # sam outputs e.g. 'SAM CLI, version 1.116.0'
  assert_output --partial "SAM CLI"
}

# ---------- Terraform via tenv ----------
@test "tenv lists both Terraform versions" {
  run tenv tf list
  assert_success
  assert_output --partial "1.9.4"
  assert_output --partial "1.4.6"
}

# ---------- age-keygen ----------
@test "age‑keygen works" {
  tempfile=$(mktemp /tmp/agekey.XXXXXX)
  rm -f "$tempfile" # ensure it does not exist
  run age-keygen -o "$tempfile"
  assert_success
  [ -s "$tempfile" ]
  rm -f "$tempfile"
}

# ---------- zoxide ----------
@test "zoxide is installed" {
  if ! command -v zoxide >/dev/null; then
    PATH="$PATH:$HOME/.local/bin"
  fi
  run zoxide --version
  assert_success
}

# ---------- Ruby ecosystem ----------
@test "rbenv lists expected Ruby versions" {
  run rbenv versions --bare
  assert_success
  assert_output --partial "3.3.4"
  assert_output --partial "3.2.2"
}

@test "Default ruby is 3.3.4" {
  run ruby -e 'print RUBY_VERSION'
  assert_success
  assert_output --partial "3.3.4"
}

@test "Bundler ${BUNDLER_VERSION} available" {
  run bundler --version
  assert_success
  assert_output --partial "${BUNDLER_VERSION}"
}

# Optionally: skip if kubectl not present
@test "kubectl present (if installed)" {
  if ! command -v kubectl >/dev/null; then
    skip "kubectl not installed in this image"
  fi
  run kubectl version --client --short
  assert_success
}

# ----- Kitchen / InSpec (PATH now set, but keep fallback) -----
@test "Kitchen is installed" {
  if ! command -v kitchen >/dev/null; then
    run /opt/bundle/bin/kitchen --version
  else
    run kitchen --version
  fi
  assert_success
}

@test "InSpec is installed" {
  if ! command -v inspec >/dev/null; then
    run /opt/bundle/bin/inspec version
  else
    run inspec version
  fi
  assert_success
}
