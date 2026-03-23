#!/usr/bin/env bats
load 'test_helper/common.bash'

# bats file_tags=ruby

@test "rbenv lists expected versions" {
  run rbenv versions --bare
  assert_success
}

@test "Default Ruby version" {
  run ruby -e 'print RUBY_VERSION'
  assert_success
}

@test "Bundler present" {
  run bundler --version
  assert_success
}

# bats test_tags=kitchen, slow
@test "Kitchen CLI" { check_binary kitchen; }

# bats test_tags=cinc_auditor, slow
@test "Cinc Auditor CLI" {
  # Fail fast if the binary is missing
  check_binary cinc-auditor

  # Verify that it runs and returns 0
  run cinc-auditor version
  assert_success
}


@test "Kitchen and Cinc Auditor shims are resolvable from PATH (no manual chown needed)" {
  run bash -lc 'command -v kitchen && command -v cinc-auditor'
  assert_success
}
