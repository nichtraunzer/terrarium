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
