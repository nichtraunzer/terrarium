# Changelog

## [4.8.2] 2026-04-21 — PGP vendor-key unification, tenv expired-key fix, Jenkins-agent tool alignment, Dependabot integration

### Added

- **Unified PGP vendor-key import** — single source of truth for HashiCorp, OpenTofu, AWS CLI, and Node release fingerprints via `docker/vendor-keys/refresh-vendor-keys.sh`. New `print-shell-env` subcommand emits a shell-sourceable `KEY="VAL"` pin file (for `make write-keys`); new `strict` subcommand compares freshly computed fingerprints against the env-pinned values and exits non-zero on drift (for `make check-keys` in CI).
- **OpenTofu vendored via tenv** — no separate install path; tenv handles both Terraform and OpenTofu.
- Dev-tooling OS packages added to the builder stage:
  - `ripgrep` — AI coding agents (Claude Code, Cursor) and `grep -r` power users expect `rg` for fast recursive search.
  - `util-linux-user` — provides `chsh`, required by the devcontainer `common-utils` feature to switch the default shell (e.g. to zsh).
  - `ca-certificates` — keep trust anchors up to date for curl/openssl fetches.
  - `libyaml-devel` — header package kept alongside `libyaml` so downstream images can rebuild native extensions (Ruby psych, Python PyYAML).
- Three new bats smoke tests in `docker/tests/01_common_dev_tools.bats` for the above — `ripgrep`, `chsh`, and the CA bundle.
- `make test` alias for `make docker-build-test` with updated README documentation.
- Local developer helper `scripts/build-test-local.ps1` for line-by-line PowerShell-extension testing.
- `uv` is pinned in `docker/pyproject.toml` as `uv~=0.11.6`; Dockerfile `UV_VERSION` wiring remains commented out / deferred.

### Fixed

- **Terrarium user and devtools group moved into builder stage** — the `terrarium` user (UID 1001), `devtools` group (GID 2001), and bats test helpers (bats-support/bats-assert) were previously created only in the `test` stage. The published image (`final`) shipped without a user entry in `/etc/passwd`, breaking downstream consumers. All three are now in the `builder` stage so every downstream stage inherits them.
- **Removed empty `final` stage** — `builder` is now the complete published image with tests, user, and helpers baked in. The `test` stage remains as a build-time gate that runs bats to validate the image.
- Tests now ship in the published image for runtime health checks — downstream consumers can run `bats /home/terrarium/tests` to verify the container after deployment.
- **`tenv` 4.9.3 → 4.11.1** — `tenv 4.11.0` introduced a fix for PGP signature checking that tolerates the expired HashiCorp release key. The old 4.9.3 pin failed at image-build time because the HashiCorp `.well-known` PGP key had entered the expired window and 4.9.3's `--skip-signature` did not short-circuit before the key was parsed. This unblocks `docker build`.
- `BUNDLED WITH` in `docker/Gemfile.lock` aligned with `BUNDLER_VERSION` so the builder-stage `bundle check` does not encounter lockfile metadata from a bundler version that is not actually installed in the image.

### Changed

- **Tool versions aligned to the ODS Jenkins agent baseline** ([terraform-2408](https://github.com/opendevstack/ods-quickstarters/blob/master/common/jenkins-agents/terraform-2408/docker/Dockerfile.ubi9)):
  - `AGE_VERSION` 1.3.1 → 1.2.0
  - `BUNDLER_VERSION` 4.0.9 → 2.5.17
  - `GO_VERSION` 1.26.1 → 1.21.13
  - `PACKER_VERSION` 1.15.0 → 1.11.2
  - `RUBY_VERSION` 3.4.9 → 3.3.4
  - `TASK_VERSION` 3.49.1 → 3.38.0
  - `TERRAFORM_DOCS_VERSION` v0.21.0 → v0.18.0
  - `TERRAFORM_VERSION` 1.14.7 → 1.9.4
  - `TFLINT_VERSION` 0.61.0 → 0.52.0
- GitHub Actions (addresses outstanding upstream Dependabot PRs):
  - `step-security/harden-runner` 2.16.1 → 2.19.0 — closes [nichtraunzer/terrarium#64](https://github.com/nichtraunzer/terrarium/pull/64).
  - `int128/docker-manifest-create-action` 2.17.0 → 2.18.0 — closes [nichtraunzer/terrarium#65](https://github.com/nichtraunzer/terrarium/pull/65).
  - `github/codeql-action` 4.35.1 → 4.35.2 — closes [nichtraunzer/terrarium#66](https://github.com/nichtraunzer/terrarium/pull/66).
- Ruby gems (via `bundle lock --update=<gem>`; addresses outstanding upstream Dependabot PRs):
  - `syslog` 0.1.2 → 0.4.0 — closes [nichtraunzer/terrarium#58](https://github.com/nichtraunzer/terrarium/pull/58).
  - `mixlib-install` 3.12.30 → 3.16.1 — closes [nichtraunzer/terrarium#67](https://github.com/nichtraunzer/terrarium/pull/67).
  - `irb` 1.14.0 → 1.17.0 — closes [nichtraunzer/terrarium#68](https://github.com/nichtraunzer/terrarium/pull/68).
  - `aws-sdk` 3.2.0 → 3.3.0 — closes [nichtraunzer/terrarium#69](https://github.com/nichtraunzer/terrarium/pull/69).
  - `test-kitchen` 3.6.0 → 3.9.1 — closes [nichtraunzer/terrarium#70](https://github.com/nichtraunzer/terrarium/pull/70).
- Other transitive bumps: `addressable` 2.9.0, `csv` 3.3.0 → 3.3.5, `mutex_m` 0.2.0 → 0.3.0.
- Python tooling: `uv` 0.11.7, `cryptography` 46.0.7.

### Docs

- README: test-layout filenames updated to match `docker/tests/` (`00_os.bats`, `01_common_dev_tools.bats`, `07_node_npm.bats`, `10_python.bats`, `30_cloud_platforms.bats`, `95_slimdown.bats`); dead `python_requirements` link replaced with `docker/pyproject.toml` + `docker/uv.lock` with a `uv lock` refresh hint.
- TOOLS_AND_LICENSES: pinned base-image rows to `ubi9/ubi:9.5` and `rockylinux:9.3` to match Dockerfile ARGs.
- Dockerfile: clarifying comment on the `test` stage explaining it is the deliberate publish target (bats suite intentionally ships in the image for consumer re-runs).

## [4.8.1] - 2026-04-03 — Dockerfile hardening, image slimdown, CI improvements, test reorganisation

### Image slimdown (~350 MB reduction)

- **Build-dep removal**: Compiler toolchain (gcc, gcc-c++, cpp, binutils, autoconf, automake, libtool, kernel-headers, `*-devel` packages) removed from final image after native extensions are compiled.
- **Documentation purge**: `/usr/share/doc`, `/usr/share/man`, `/usr/share/info` removed from final image.
- **dnf `tsflags=nodocs`**: Prevents future `dnf install` from adding documentation.
- **Locale cleanup**: Non-`en_US` locale data and stale locale archive template removed.
- **`.git` metadata stripped**: pyenv and rbenv `.git` directories removed in buildlang stage before COPY into builder.
- **GPG temp files cleaned**: `/opt/keys/tmp` removed after build-time signature verification.
- Retains make, git, openssl, curl, sudo, and all runtime libraries.

### Dockerfile refactoring

- **Centralised version ARGs**: All tool versions defined in a single alphabetically sorted global ARG block at the top of the Dockerfile. Builder ENV block now references `${VAR}` instead of hardcoded values.
- **Pinned base images**: `rockylinux:9.3` (buildlang), `ubi9/ubi:9.5` (builder) for build determinism.
- **Bundle cache reconciliation**: Builder stage runs non-frozen `bundle install` first (reconciles stale GHA cache), then `BUNDLE_FROZEN=true bundle check` as the integrity gate.
- Bumped Bundler 2.7.2 → 4.0.9.

### CI/CD improvements

- **Release workflow**: Added `release: [published]` event trigger. Conditional `latest` tag auto-detects pre-release tags (`-pre`, `-alpha`, `-beta`, `-rc`) and skips `latest` update.
- **Scan workflow**: Path-filtered `push`/`pull_request` triggers (`docker/**`, scan.yaml). Schedule changed from daily to weekly (Monday 06:00 UTC). Added `release: [published]` trigger.
- **GEMFILE_HASH cache-buster**: SHA256 of Gemfile.lock passed as build arg to invalidate stale GHA buildlang cache.
- **Pinned syft**: Makefile sbom target uses syft v1.42.3 with SHA256 checksum verification (replaces curl-pipe-sh installer).

### Test suite reorganisation

- `00_core.bats` → `00_os.bats` — scoped to OS family, devtools group, permissions, PATH, GNUPGHOME.
- New `01_common_dev_tools.bats` — make, git, openssl, curl, sudo, jq, parallel, Go.
- New `95_slimdown.bats` — negative assertions confirming build deps (gcc/g++/cpp) and docs are removed.
- Moved tests to logical homes: trivy → `20_infra.bats`, oc → `60_k8s.bats`, Go → `01_common_dev_tools.bats`.
- Added pip test to `10_python.bats`.
- All 55 original tests preserved; 12 new tests added (67 total).

### Upgraded

- cinc-auditor-bin 5.22.55 → 5.23.6 (with inspec/inspec-core 5.23.6)
- Gemfile.lock regenerated for Ruby 3.4.9 + Bundler 4.0.9

---

## [4.8.0] - 2026-03-23 — Rocky 9 tool upgrades, tfsec→Trivy, GCP CLI and Security Hardening ( PR #42 )

### Security

- **GitHub Actions hardened**: All actions pinned to immutable commit SHAs; mutable tags eliminated
- **GITHUB_TOKEN least privilege**: Workflow-level `permissions: contents: read` enforced; write permissions scoped to specific jobs
- **Context dumps removed**: Debug context gated behind `workflow_dispatch` input; `github.token` no longer serialized to logs
- **Secret isolation verified**: No secrets in global `env:` blocks; GITHUB_TOKEN scoped to login steps only
- **release.yaml reintegrated**: Manual release workflow with all security hardening applied
- **harden-runner**: `step-security/harden-runner` integrated in all workflow jobs (egress audit mode)
- **CODEOWNERS**: Review gates added for workflows, Dockerfile, and security config

### Breaking Changes

- **tfsec removed, replaced by Trivy** — if you reference `tfsec` in scripts/CI, replace with `trivy fs --scanners misconfig`
- **Consul removed** — no longer bundled; install separately if needed
- **Deprecated tool versions removed:** old Terraform 1.4.6, Bundler 2.4.13

### Added

- OpenTofu 1.11.5 via tenv (`OPENTOFU_VERSION` env var, `tenv tofu install/use`)
- Trivy 0.69.3 (IaC security scanner, replaces deprecated tfsec)
- GCP CLI (`gcloud`) via Google Cloud SDK yum repo
- `.github/CODEOWNERS` — require review for security-sensitive paths
- `.github/workflows/release.yaml` — manual release workflow with full hardening
- `TOOLS_AND_LICENSES.md` — tools and OSS license inventory for compliance visibility

### Upgraded

- Python 3.12.11 → 3.13.12 (via pyenv)
- Ruby 3.4.1 → 3.4.9 (via rbenv)
- Bundler 2.7.1 → 2.7.2
- Node.js 24.5.0 → 24.14.0
- Go 1.24.6 → 1.26.1
- tenv 1.2.0 → 4.9.3
- Terraform default 1.12.2 → 1.14.7
- Packer 1.14.1 → 1.15.0
- kubectl 1.33.3 → 1.35.3
- Helm 3.18.4 → 3.20.1
- sops 3.10.2 → 3.12.2 (repo moved from mozilla/sops to getsops/sops)
- age 1.1.0 → 1.3.1
- tflint 0.58.1 → 0.61.0
- terraform-docs v0.20.0 → v0.21.0
- starship 1.23.0 → 1.24.2
- zoxide 0.9.4 → 0.9.9
- bats-core 1.11.0 → 1.13.0
- yq 4.47.1 → 4.52.4
- Task 3.43.1 → 3.49.1

### Removed

- tfsec (EOL — use Trivy instead)
- Consul (no longer used internally)

---

## 2026-03-23 — refactor: move terraform/docker/ → docker/ ( PR #42 )

### Changed

- Moved all build artifacts from `terraform/docker/` to `docker/` to simplify
  the repo layout and remove the misleading `terraform/` prefix.
- Updated all references in Makefile, GitHub Actions workflows, dependabot config,
  .gitignore, README, and CHANGELOG.

---

## 2025-08-22 PR #46 Make Terrarium image UID‑agnostic via stable devtools group; fix Ruby toolchain permissions & PATH for Dev Containers

<https://github.com/nichtraunzer/terrarium/pull/46>

### Changed

- Image is now **UID‑agnostic** by introducing a stable `devtools` group (`DEVTOOLS_GID`, default `2001`) and applying setgid + group‑writable perms to `/opt/bundle` and `/opt/rbenv` (optional: `/opt/pyenv`, `/opt/tenv`).
- Toolchain PATH and `rbenv` init are loaded for **login and non‑login shells** via `/etc/profile.d/10-terrarium-path.sh` and `/etc/bashrc.d/10-terrarium-path.sh`.

### Added

- Cooperative `umask 0002` for dev shells to keep group‑writable files.

### Fixed

- `kitchen` / `cinc-auditor` reliably resolve on PATH; **no more Dev Container `postCreateCommand` chowns** required. Downstream users just add their user to `devtools` (`usermod -aG devtools <user>`).

## 2025-08-18 PR #44 feat(tools): added kubectl and helm with validation tests

<https://github.com/nichtraunzer/terrarium/pull/44>

### Added

- `kubectl` and `helm` installed with install validation tests.

### Changed

- Updated `Dockerfile.terrarium` and `kubectl` to version `1.33.3` and actually install.
- Updated `Dockerfile.terrarium` and `helm` to version `3.18.4` and actually install.
- `k8s` validation tests for `kubectl` and `helm`.

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

## 2024-10-18 Update Tools

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

## 2023-04-28 Update Tools

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

## 2022-03-15 Initial release
