# Changelog

## 2025-08-08 PR #41 — feat(python): pyenv and uv are now installed (merged 2025‑08‑08)

### Added

- `uv` preinstalled for fast, deterministic Python workflows.
- `pyenv` to build and select CPython; patch‑exact pin via `PYTHON_VERSION` (default `3.12.11`).
- New Bats test `tests/10_python.bats` to verify `python`, `pyenv`, and `uv`.

### Changed

- `Dockerfile.terrarium` now produces Python via `pyenv` and puts pyenv shims first in `PATH`.
- Extra compile deps added to ensure a full‑featured CPython build (e.g. `bzip2‑devel`, `xz‑devel`, `tk‑devel`, etc.).
- Moved the basic Python existence check out of `00_core.bats` (covered by `10_python.bats`).

### Removed

- Reliance on system RPMs (`python3.12*`) baked into the image.

---

## 2025-07-29 PR #40 — feat(ci): add Bats test‑suite for basic successful tool installation checks (merged 2025‑07‑28)

### Added

- Comprehensive Bats smoke/regression suite under `terraform/docker/tests/`:
  - `00_core.bats`, `20_infra.bats`, `30_aws.bats`, `40_terraform.bats`, `50_ruby_ecosystem.bats`, `60_k8s.bats`, `90_extras.bats`.
- Test helper libraries vendored (`bats-support`, `bats-assert`) plus `tests/test_helper/common.bash`.
- New multi‑stage `Dockerfile.terrarium` **test** target that runs the suite and emits a JUnit report at build time.
- CI updated so builds target t Yeah so it's still old it is still old and new in sequence yet he **test** stage across all matrix architectures; failures block image publishing.

### Changed

- CI/workflows refinements (e.g., ARM runner selection, manifest creation, checkout v4) and improved tagging/diagnostics.
- README updated to describe the Bats testing approach.

### Dependencies

- Bumped `rexml` (indirect) to `3.3.9`.

---

## 2024-10-18 Update Tools:

- ruby 3.3.4
- bundler
- inspec and cinc-auditor-bin
- nodejs
- update Gemfile & rebuild Gemfile.lock
- update terraform-docs
- hashicorp tools (e.g. terraform 1.9.4)
- replaced tfenv with tenv (tenv also supports tofu, terragrunt)
- added xorriso, yq, golang & go-task (experimental support for terratest)
- default python version is 3.12
- update python requirements
- update base OS

---

## 2023-04-28 Update Tools:

- ruby 3.2.2
- bundler
- kitchen-terraform
- inspec and cinc-auditor-bin
- hashicorp tools
- nodejs
- default python version is 3.11
- python requirements
- added tflint

---

## 2022-03-15 Initial release.
