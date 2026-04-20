#!/usr/bin/env bats
load 'test_helper/common.bash'

# bats file_tags=slimdown
# Negative assertions: verify build-time deps and docs were removed from the
# final image to keep it slim. Positive tool tests live in their domain files.

# --- Build deps removed (compiler toolchain should NOT be present) -----------

@test "gcc is removed (build-dep cleanup)" {
  run bash -lc 'command -v gcc'
  assert_failure
}

@test "g++ is removed (build-dep cleanup)" {
  run bash -lc 'command -v g++'
  assert_failure
}

@test "cpp is removed (build-dep cleanup)" {
  run bash -lc 'command -v cpp'
  assert_failure
}

# --- Docs/man pages removed --------------------------------------------------

@test "/usr/share/doc is removed" {
  [ ! -d /usr/share/doc ]
}

@test "/usr/share/man is removed" {
  [ ! -d /usr/share/man ]
}

@test "/usr/share/info is removed" {
  [ ! -d /usr/share/info ]
}
