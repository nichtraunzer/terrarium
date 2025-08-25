#!/usr/bin/env bats

load 'test_helper/common.bash'

# bats file_tags=core

@test "OS is Rocky Linux 8" {
  run cat /etc/os-release
  assert_success
  assert_output --partial "Rocky Linux"
  assert_output --partial "8."
}


@test "jq is installed" {
  check_binary jq
}

@test "GNU parallel is installed" {
  run parallel --version
  assert_success
  assert_output --partial "GNU parallel"
}

@test "Node is installed" {
  check_binary node
}


@test "Stable devtools group exists with a numeric GID" {
  run getent group devtools
  assert_success
  # Output example: devtools:x:2001:
  [[ "${output}" =~ ^devtools:x:[0-9]+: ]] || {
    echo "Unexpected devtools group line: ${output}" >&2
    return 1
  }
}

@test "/opt/bundle and /opt/rbenv/shims are group-owned by devtools and setgid" {
  assert_devtools_setgid_dir "/opt/bundle"
  assert_devtools_setgid_dir "/opt/rbenv/shims"
}

@test "/opt/pyenv and /opt/tenv are writable by devtools (runtime install support)" {
  # Optional but expected per Dockerfile
  for d in /opt/pyenv /opt/tenv; do
    if [ -d "$d" ]; then
      run bash -lc 'stat -c "%G %A %n" '"$d"
      assert_success
      [[ "${output}" == devtools* ]] || {
        echo "Expected group 'devtools' for $d, got: ${output}" >&2
        return 1
      }
      # quick writable check
      run bash -lc '[ -w '"$d"' ]'
      assert_success
    fi
  done
}

@test "New files/dirs under /opt/bundle inherit devtools group; dirs inherit setgid" {
  work="/opt/bundle/bats_perm_test_$$"
  run bash -lc 'mkdir -p '"$work"' && touch '"$work"'/f && stat -c "%G %A %n" '"$work"' '"$work"'/f'
  assert_success

  # Both dir and file must be group-owned by devtools
  echo "$output" | awk '{print $1}' | while read g; do
    [ "$g" = "devtools" ] || { echo "Non-devtools group seen: $g" >&2; exit 1; }
  done

  # Directory must have setgid bit (files do not)
  run bash -lc 'test -d '"$work"' && find '"$work"' -maxdepth 0 -perm -2000 -print -quit'
  assert_success
  [ -n "${output}" ] || { echo "Expected setgid on $work" >&2; return 1; }

  run bash -lc 'rm -rf '"$work"
  assert_success
}


@test "PATH/rbenv initialization works in a login shell" {
  # -l forces login shell -> /etc/profile.d/* should apply
  run bash -lc 'command -v ruby && command -v rbenv && command -v bundler && echo "$PATH"'
  assert_success
  assert_output --partial "/opt/rbenv/shims"
  assert_output --partial "/opt/rbenv/bin"
  assert_output --partial "/opt/bundle/bin"
  assert_output --partial "/opt/node/bin"
}

@test "PATH/rbenv initialization works in an interactive non-login shell" {
  # -i (interactive) triggers /etc/bashrc -> /etc/bashrc.d/*
  run bash -ic 'command -v ruby && command -v rbenv && command -v bundler && echo "$PATH"'
  assert_success
  assert_output --partial "/opt/rbenv/shims"
  assert_output --partial "/opt/rbenv/bin"
  assert_output --partial "/opt/bundle/bin"
  assert_output --partial "/opt/node/bin"
}


