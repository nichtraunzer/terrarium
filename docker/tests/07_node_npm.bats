#!/usr/bin/env bats

load 'test_helper/common.bash'

# bats file_tags=node,npm

@test "node is on PATH and version is 24.x" {
    run node --version
    assert_success
    assert_output --partial "v24."
}

@test "npm is on PATH" {
    run npm --version
    assert_success
}

@test "npm global prefix is set to ~/.npm-global" {
    run npm config get prefix
    assert_success
    assert_output --partial ".npm-global"
}

@test "npm bin directory is on PATH" {
    run bash -c 'echo "$PATH"'
    assert_output --partial ".npm-global/bin"
}

@test "npm global install works without sudo" {
    run npm install -g semver
    assert_success
    # verify the binary was installed in the per-user prefix
    run bash -c 'test -f "$(npm config get prefix)/bin/semver"'
    assert_success
    # cleanup
    npm uninstall -g semver
}

@test "no root-owned files in npm-global" {
    run bash -c 'find ~/.npm-global -user root 2>/dev/null | head -1'
    assert_output ""
}
