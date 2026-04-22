# Tools and OSS Licenses

This file lists all tools bundled in the terrarium container image and their
open-source licenses. Consumers of this image should review these licenses for
compliance with their organization's policies.

> **Last updated:** 2026-04-01
> For a machine-readable SBOM, see the BuildKit SBOM attestation attached to
> published images (`--sbom=true`), or generate one locally with
> `make sbom` (requires [Syft](https://github.com/anchore/syft)).
>
> Please also see the [Maintenance](#maintenance) section at the end of this file for instructions on how to keep this inventory up to date when making changes to the Dockerfile or OS packages etc.

---

## Core Languages & Runtimes

| Tool | Version | License | Source |
|------|---------|---------|--------|
| Python | 3.13.12 (via pyenv) | [PSF-2.0](https://docs.python.org/3/license.html) | github.com/pyenv/pyenv → python.org |
| Ruby | 3.4.9 (via rbenv) | [BSD-2-Clause](https://www.ruby-lang.org/en/about/license.txt) | github.com/rbenv/rbenv → ruby-lang.org |
| Go | 1.26.1 | [BSD-3-Clause](https://go.dev/LICENSE) | go.dev |
| Node.js | 24.14.0 | [MIT](https://github.com/nodejs/node/blob/main/LICENSE) | nodejs.org |

## Version Managers

| Tool | Version | License | Source |
|------|---------|---------|--------|
| pyenv | latest (git clone) | [MIT](https://github.com/pyenv/pyenv/blob/master/LICENSE) | github.com/pyenv/pyenv |
| rbenv | latest (git clone) | [MIT](https://github.com/rbenv/rbenv/blob/master/LICENSE) | github.com/rbenv/rbenv |
| ruby-build | latest (git clone) | [MIT](https://github.com/rbenv/ruby-build/blob/master/LICENSE) | github.com/rbenv/ruby-build |
| tenv | 4.9.3 | [Apache-2.0](https://github.com/tofuutils/tenv/blob/main/LICENSE) | github.com/tofuutils/tenv |
| uv | latest (install script) | [Apache-2.0](https://github.com/astral-sh/uv/blob/main/LICENSE-APACHE) | astral.sh/uv |

## Infrastructure as Code

| Tool | Version | License | Source |
|------|---------|---------|--------|
| Terraform | 1.14.7 (via tenv) | [BUSL-1.1](https://github.com/hashicorp/terraform/blob/main/LICENSE) | releases.hashicorp.com |
| OpenTofu | 1.11.5 (via tenv) | [MPL-2.0](https://github.com/opentofu/opentofu/blob/main/LICENSE) | opentofu.org |
| Packer | 1.15.0 | [BUSL-1.1](https://github.com/hashicorp/packer/blob/main/LICENSE) | releases.hashicorp.com |
| terraform-docs | v0.21.0 | [MIT](https://github.com/terraform-docs/terraform-docs/blob/master/LICENSE) | github.com/terraform-docs/terraform-docs |
| terraform-config-inspect | 0.2.0 | [MPL-2.0](https://github.com/hashicorp/terraform-config-inspect/blob/main/LICENSE) | github.com/nichtraunzer/terraform-config-inspect |
| tflint | 0.61.0 | [MPL-2.0](https://github.com/terraform-linters/tflint/blob/master/LICENSE) | github.com/terraform-linters/tflint |

## Cloud CLIs

| Tool | Version | License | Source |
|------|---------|---------|--------|
| AWS CLI v2 | latest (installer) | [Apache-2.0](https://github.com/aws/aws-cli/blob/v2/LICENSE.txt) | awscli.amazonaws.com |
| AWS SAM CLI | latest (installer/pip) | [Apache-2.0](https://github.com/aws/aws-sam-cli/blob/develop/LICENSE) | github.com/aws/aws-sam-cli |
| AWS CDK | 2.1024.0 (npm) | [Apache-2.0](https://github.com/aws/aws-cdk/blob/main/LICENSE) | npm (aws-cdk) |
| Azure CLI | latest (dnf repo) | [MIT](https://github.com/Azure/azure-cli/blob/dev/LICENSE) | packages.microsoft.com |
| GCP CLI (gcloud) | latest (dnf repo) | [Apache-2.0](https://cloud.google.com/sdk/docs/install) | packages.cloud.google.com |
| OpenStack CLI | 7.1.5 (pip venv) | [Apache-2.0](https://github.com/openstack/python-openstackclient/blob/master/LICENSE) | pypi.org |
| OpenStack Barbican client | 7.3.0 (pip venv) | [Apache-2.0](https://github.com/openstack/python-barbicanclient/blob/master/LICENSE) | pypi.org |

## Kubernetes & Container Tools

| Tool | Version | License | Source |
|------|---------|---------|--------|
| kubectl | 1.35.3 | [Apache-2.0](https://github.com/kubernetes/kubectl/blob/master/LICENSE) | dl.k8s.io |
| Helm | 3.20.1 | [Apache-2.0](https://github.com/helm/helm/blob/main/LICENSE) | get.helm.sh |
| OpenShift CLI (oc) | 4.19.0 | [Apache-2.0](https://github.com/openshift/oc/blob/master/LICENSE) | mirror.openshift.com |

## Security & Secrets

| Tool | Version | License | Source |
|------|---------|---------|--------|
| Trivy | 0.69.3 | [Apache-2.0](https://github.com/aquasecurity/trivy/blob/main/LICENSE) | github.com/aquasecurity/trivy |
| sops | 3.12.2 | [MPL-2.0](https://github.com/getsops/sops/blob/main/LICENSE) | github.com/getsops/sops |
| age | 1.3.1 | [BSD-3-Clause](https://github.com/FiloSottile/age/blob/main/LICENSE) | github.com/FiloSottile/age |

## Shell & Utilities

| Tool | Version | License | Source |
|------|---------|---------|--------|
| Starship | 1.24.2 | [ISC](https://github.com/starship/starship/blob/master/LICENSE) | starship.rs |
| zoxide | 0.9.9 | [MIT](https://github.com/ajeetdsouza/zoxide/blob/main/LICENSE) | github.com/ajeetdsouza/zoxide |
| yq | 4.52.4 | [MIT](https://github.com/mikefarah/yq/blob/master/LICENSE) | github.com/mikefarah/yq |
| Task (go-task) | 3.49.1 | [MIT](https://github.com/go-task/task/blob/main/LICENSE) | taskfile.dev |
| jq | dnf | [MIT](https://github.com/jqlang/jq/blob/master/COPYING) | dnf (EPEL) |
| GNU Parallel | dnf | [GPL-3.0-or-later](https://www.gnu.org/software/parallel/) | dnf (EPEL) |
| xorriso | buildlang stage | [GPL-2.0-or-later](https://www.gnu.org/software/xorriso/) | dnf (Rocky Linux CRB) |

## Testing Frameworks

| Tool | Version | License | Source |
|------|---------|---------|--------|
| bats-core | 1.13.0 | [MIT](https://github.com/bats-core/bats-core/blob/master/LICENSE.md) | github.com/bats-core/bats-core |
| Test Kitchen | Gemfile | [Apache-2.0](https://github.com/test-kitchen/test-kitchen/blob/main/LICENSE) | rubygems.org |
| kitchen-terraform | Gemfile (~> 7.0) | [Apache-2.0](https://github.com/newcontext-oss/kitchen-terraform/blob/master/LICENSE) | rubygems.org |
| InSpec / cinc-auditor | Gemfile (>= 5.22.55) | [Apache-2.0](https://github.com/inspec/inspec/blob/main/LICENSE) | rubygems.cinc.sh |

## Ruby Gems (via Bundler)

The following gems are installed via `Gemfile` / `Gemfile.lock` into `/opt/bundle`:

| Gem | License | Source |
|-----|---------|--------|
| activesupport | MIT | rubygems.org |
| aws-sdk (~> 3) | Apache-2.0 | rubygems.org |
| rspec-retry | MIT | rubygems.org |
| chef-config | Apache-2.0 | rubygems.cinc.sh |
| chef-utils | Apache-2.0 | rubygems.cinc.sh |
| mixlib-install | Apache-2.0 | rubygems.cinc.sh |
| mixlib-versioning | Apache-2.0 | rubygems.cinc.sh |

> For the complete list of transitive Ruby dependencies and their licenses,
> inspect `docker/Gemfile.lock` or run `bundle licenses` inside the container.

## Python Packages (via uv)

The following packages are installed via `pyproject.toml` / `uv.lock`:

| Package | License | Source |
|---------|---------|--------|
| boto3 / botocore (~> 1.39) | Apache-2.0 | pypi.org |
| pre-commit (~> 4.2) | MIT | pypi.org |
| requests (~> 2.32) | Apache-2.0 | pypi.org |
| python-hcl2 (~> 2.0) | MIT | pypi.org |
| pipenv (~> 2024.0) | MIT | pypi.org |
| pycodestyle (~> 2.14) | MIT | pypi.org |
| simplejson (~> 3.19) | MIT / Academic Free License | pypi.org |
| virtualenv (~> 20.32) | MIT | pypi.org |

> For the complete list of transitive Python dependencies and their licenses,
> inspect `docker/uv.lock` or run `uv pip list --format columns` inside the container.

## Base Image & OS Packages

| Component | Details |
|-----------|---------|
| Base image | `registry.access.redhat.com/ubi9/ubi:9.5` (Red Hat Universal Base Image 9) |
| Build stage | `rockylinux:9.3` (Rocky Linux 9 — RHEL-compatible, BSD-licensed) |
| OS packages | Installed via `dnf` — RPM packages follow their individual upstream licenses (primarily GPL-2.0, LGPL, MIT, BSD) |
| EPEL | Fedora Extra Packages for Enterprise Linux 9 |

---

## Verification Status

All binary-downloaded tools are cryptographically verified unless noted:

| Tool | Verification | Notes |
|------|-------------|-------|
| Terraform, Packer | GPG-signed SHA256SUMS | HashiCorp PGP key pinned |
| AWS CLI v2 | GPG detached signature | AWS release key pinned |
| Node.js | GPG-signed SHASUMS256.txt | nodejs/release-keys keyring |
| Go | SHA256 checksum | go.dev checksums / JSON index |
| kubectl | SHA256 checksum file | dl.k8s.io |
| Helm | SHA256 checksum file | get.helm.sh |
| Starship | Per-file .sha256 | GitHub releases |
| tflint | SHA256 checksums.txt | GitHub releases |
| Trivy | SHA256 checksums.txt | GitHub releases |
| age | SHA256 checksums (multi-strategy) | GitHub releases |
| Azure CLI | RPM GPG key | Microsoft repo signing key |
| GCP CLI | RPM GPG key | Google Cloud repo signing key |
| sops | RPM package | GitHub releases |
| tenv | RPM package | GitHub releases |
| zoxide | **Not verified** | Upstream publishes no checksums |
| yq | **Not verified** | Direct binary download |
| terraform-docs | **Not verified** | Direct binary download |
| terraform-config-inspect | **Not verified** | Direct binary download |
| Task (go-task) | **Not verified** | Install script |

---

## License Summary

| License | Count | Tools |
|---------|-------|-------|
| Apache-2.0 | 15+ | AWS CLI, AWS CDK, AWS SAM, Azure CLI (repo), GCP CLI, kubectl, Helm, oc, Trivy, tenv, uv, OpenStack, Test Kitchen, kitchen-terraform, InSpec |
| MIT | 12+ | Node.js, pyenv, rbenv, ruby-build, terraform-docs, yq, zoxide, Task, bats-core, jq, Starship (ISC ≈ MIT), activesupport |
| MPL-2.0 | 4 | OpenTofu, tflint, sops, terraform-config-inspect |
| BUSL-1.1 | 2 | Terraform, Packer |
| BSD-3-Clause | 2 | Go, age |
| BSD-2-Clause | 1 | Ruby |
| PSF-2.0 | 1 | Python |
| GPL-2.0+ / GPL-3.0+ | 2 | xorriso, GNU Parallel |
| ISC | 1 | Starship |

> **Note on BUSL-1.1 (Business Source License):** Terraform and Packer use the
> HashiCorp Business Source License. This license permits most non-production and
> production use but restricts offering a competing hosted service. Review the
> [BUSL-1.1 FAQ](https://www.hashicorp.com/license-faq) for your use case.
> OpenTofu (MPL-2.0) is available as a permissively-licensed alternative.

---

## Maintenance

This file should be updated whenever tools are added, removed, or upgraded in
`docker/Dockerfile.terrarium`. Use the following prompt with an AI coding
assistant (e.g. Claude Code) to regenerate or verify the inventory:

<details>
<summary>Update prompt</summary>

```text
Read docker/Dockerfile.terrarium and TOOLS_AND_LICENSES.md. For every tool
installed in the Dockerfile (via ARG/ENV versions, dnf, binary download, pip,
npm, gem/Bundler, or git clone):

1. Check it appears in TOOLS_AND_LICENSES.md with the correct version.
2. Verify the SPDX license identifier is accurate (check the tool's repo).
3. Check the Verification Status table matches how the tool is actually
   verified in the Dockerfile (GPG, SHA256, RPM key, or not verified).
4. Update the License Summary counts.
5. If a tool was removed from the Dockerfile, remove it from this file.
6. If a tool was added to the Dockerfile, add it to the appropriate section.

Also cross-reference docker/Gemfile and docker/pyproject.toml for Ruby gem
and Python package changes respectively.

Output a diff of any changes needed, or confirm the file is up to date.
```

</details>

For a machine-readable cross-check, run `make sbom` (requires
[Syft](https://github.com/anchore/syft)) and compare the output against this
file. Syft reliably detects OS/language packages but misses most
binary-downloaded tools — this file is the authoritative source for those.
