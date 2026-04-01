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
    # Use a local package to avoid network dependency
    tmpdir="$(mktemp -d)"

    cat >"$tmpdir/package.json" <<'PKGJSON'
{
  "name": "test-global-install",
  "version": "1.0.0",
  "bin": {
    "test-global-install": "bin/test-global-install"
  }
}
PKGJSON

    mkdir -p "$tmpdir/bin"
    cat >"$tmpdir/bin/test-global-install" <<'BIN'
#!/usr/bin/env bash
echo "ok"
BIN
    chmod +x "$tmpdir/bin/test-global-install"

    run npm install -g "$tmpdir"
    assert_success
    # verify the binary was installed in the per-user prefix
    run bash -c 'test -f "$(npm config get prefix)/bin/test-global-install"'
    assert_success
    # cleanup
    npm uninstall -g test-global-install
    rm -rf "$tmpdir"
}

@test "no root-owned files in npm-global" {
    # Ensure the directory exists so the test cannot pass trivially
    run bash -c 'test -d "$HOME/.npm-global"'
    assert_success

    # Verify no root-owned files exist
    run bash -c 'find "$HOME/.npm-global" -user root -print -quit 2>/dev/null'
    assert_success
    assert_output ""
}
