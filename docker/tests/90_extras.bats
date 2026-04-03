#!/usr/bin/env bats
load 'test_helper/common.bash'

# bats file_tags=extras

@test "Taskfile runner" { check_binary task; }

@test "Starship prompt" { check_binary starship; }

@test "Starship default config exists" {
  [ -f "$HOME/.config/starship.toml" ]
}

@test "yq CLI" { check_binary yq; }

@test "zoxide utility" { check_binary zoxide; }
