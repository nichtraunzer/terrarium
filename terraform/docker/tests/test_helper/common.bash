#!/usr/bin/env bash
# Common helper functions / variables

 load 'test_helper/bats-support/load'
 load 'test_helper/bats-assert/load'

 # Ensure the user-local bin directory is searchable even for non-login shells
 export PATH="$PATH:$HOME/.local/bin:/opt/bundle/bin"

 # Short helper for “binary exists and prints a version”
 check_binary() {
   local exe="$1"
   run "$exe" --version
   assert_success
 }

# Return "gid:<gid>" for a group, or empty if not found
get_gid_of_group() {
  local grp="$1"
  getent group "$grp" | awk -F: '{print "gid:"$3}'
}
# Assert a path is group-owned by `devtools` AND has setgid bit
assert_devtools_setgid_dir() {
  local p="$1"
  run bash -lc 'stat -c "%G %a %A %n" '"$p"
  assert_success
  # Expect group=devtools
  [[ "${output}" == devtools* ]] || {
    echo "Expected group 'devtools' for $p, got: ${output}" >&2
    return 1
  }
  # Expect setgid bit (2xxx) and at least g+rwX (775 typical)
  # Check via find -perm -2000
  run bash -lc 'test -d '"$p"' && find '"$p"' -maxdepth 0 -perm -2000 -print -quit'
  assert_success
  [[ -n "${output}" ]] || {
    echo "Expected setgid bit on directory $p" >&2
    return 1
  }
}

# Echo 1 if PATH contains a segment, else 0
path_contains() {
  local seg="$1"
  case ":$PATH:" in
    *":$seg:"*) echo 1;;
    *) echo 0;;
  esac
}
