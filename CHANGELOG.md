# Changelog

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
