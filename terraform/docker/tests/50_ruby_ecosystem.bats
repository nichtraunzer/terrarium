#!/usr/bin/env bats
load 'test_helper/common.bash'

# @ruby
@test "rbenv lists expected versions" {
  run rbenv versions --bare
  assert_success
  assert_output --partial "3.3.4"
  assert_output --partial "3.2.2"
}

# @ruby
@test "Default Ruby version" {
  run ruby -e 'print RUBY_VERSION'
  assert_success
  assert_output --partial "3.3.4"
}

# @ruby
@test "Bundler 2.5.17 present" {
  run bundler --version
  assert_success
  assert_output --partial "2.5.17"
}

# @ruby @slow
@test "Kitchen CLI" { check_binary kitchen; }

# @ruby @slow
@test "InSpec CLI" {
  run inspec version
  assert_success
}
