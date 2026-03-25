#!/usr/bin/env bats
load 'test_helper/common.bash'

# bats file_tags=aws,azure,gcp,openstack

# @aws
@test "AWS CLI" { check_binary aws; }

# @aws
@test "AWS SAM CLI" { check_binary sam; }

# @aws
@test "AWS CDK CLI" { check_binary cdk; }


# @azure
@test "Azure CLI (az) is available" {
  if command -v az >/dev/null; then
    run az --version
    assert_success
  else
    # Installed via `uv sync --directory /tmp`; run it from that project env
    run uv run --directory /tmp az --version
    assert_success
  fi
}

# @gcp
@test "GCP CLI (gcloud) is available" {
  run gcloud version
  assert_success
}

# @openstack
@test "openstack CLI is installed and on PATH" {
    run which openstack
    assert_success
}

# @openstack
@test "openstack CLI runs and shows version" {
    run openstack --version
    assert_success
    assert_output --partial "openstack"
}

# @openstack
@test "openstack help includes secret commands (barbican)" {
    run openstack secret store --help
    assert_success
    assert_output --partial "secret"
}
