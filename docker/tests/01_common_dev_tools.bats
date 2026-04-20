#!/usr/bin/env bats

load 'test_helper/common.bash'

# bats file_tags=common_dev_tools

# --- Moved from 00_core.bats ------------------------------------------------

@test "jq is installed" {
  check_binary jq
}

@test "GNU parallel is installed" {
  run parallel --version
  assert_success
  assert_output --partial "GNU parallel"
}

# --- Moved from 90_extras.bats ----------------------------------------------

@test "Go is installed" {
  run go version
  assert_success
}

# --- New: common dev tools that previously had no tests ----------------------

@test "make is installed" { check_binary make; }

@test "git is installed" { check_binary git; }

@test "openssl CLI is installed" {
  run openssl version
  assert_success
}

@test "curl is installed" { check_binary curl; }

@test "sudo is installed" { check_binary sudo; }
