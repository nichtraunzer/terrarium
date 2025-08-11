# Security Policy

This project builds a **developer container** (Dev Container / Docker image) with a curated toolchain (e.g., Terraform, cloud CLIs, Packer, sops/age, Ruby, kubectl/helm). It is **not a production service**. Please report vulnerabilities privately and follow coordinated disclosure so users have time to update.

## Reporting a Vulnerability

**Preferred:** Use GitHub’s “Report a vulnerability” (Security → Report a vulnerability) so we can triage and discuss privately.

When you report, please include:

- Affected version(s): commit SHA, tag, and if applicable the **container image tag & digest**.
- Environment: host OS, Docker/Podman version, Dev Container/VS Code version.
- Repro steps or PoC and expected vs. actual behavior.
- Impact assessment (what can an attacker do?) and suggested severity (CVSS if you have one).
- Any logs or `docker inspect` details that help us reproduce safely.

We’ll acknowledge your report within **3 business days**, provide a triage decision within **7 days**, and share fix/mitigation timelines (see below). If your report is out of scope (see “Scope”), we’ll try to point you to the right place.

## Coordinated Disclosure

We follow responsible/coordinated disclosure:

- We’ll collaborate with you privately to validate, fix, and test.
- We’ll publish a **GitHub Security Advisory** and CHANGELOG notes when a fix or mitigation is available.
- **Disclosure window:** up to **90 days** from triage, or earlier if a fix/workaround is released. For actively exploited issues, we may publish mitigations earlier.

If you need a public credit, let us know your preferred attribution.

## Scope

**In scope**

- This repository’s source (Dockerfiles, scripts, CI).
- Any container images published by this repository (if/when published).
- Configuration in `.devcontainer` examples.

**Out of scope**

- Vulnerabilities that only affect **upstream** projects or base images (please report to those projects).
- Purely informational scanner output without a concrete exploit or impact.
- Denial‑of‑service that requires unrealistic resources, social engineering, or physical access.
- Issues that require already‑compromised developer credentials or host root access.
- Typos, UX nits, or non‑security bugs.

## Supported Versions

- We support the **default branch** and the **most recent tagged release** (if tags are used).
- Security fixes are generally only backported to the most recent minor release.
- Users should prefer the **latest image/tag** and verify by **digest**.

## How We Build & Verify

- Images are built via CI and include fast, deterministic smoke tests (Bats) to confirm key tools are present and runnable.
- We pin or constrain critical tool versions where practical and track changes in `CHANGELOG.md`.
- When applicable, we will publish a GitHub Security Advisory and, if warranted, request a CVE.

> Roadmap (not a promise): container image signing (cosign), SBOM publication, and automated image scanning.

## Guidance for Users

This is a **developer workstation** image. To use it safely:

- **Don’t run as privileged** or with `--cap-add=SYS_ADMIN`. Avoid mounting the Docker socket into the container.
- **Use non‑root** where possible (default user if provided), and prefer **read‑only** mounts for source code.
- **Keep secrets out of images**. Mount credentials at runtime (`~/.aws`, `~/.gitconfig`, etc.) and prefer short‑lived tokens.
- **Network hygiene:** treat the container as untrusted on the network; don’t expose ports unnecessarily.
- **Update regularly:** pull the latest tag/digest, and watch releases/advisories for fixes.
- If you find a vulnerability in a **preinstalled tool** (e.g., Terraform, kubectl, sops), please also report it upstream.

## Triage & SLAs (Guidance)

- **Critical** (e.g., RCE within default workflow, credential exfiltration): hotfix ASAP; aim ≤ 7–14 days.
- **High** (priv‑esc, auth bypass with realistic preconditions): fix in ≤ 30 days.
- **Medium** (info leak, unsafe defaults with mitigations): fix in ≤ 90 days.
- **Low** (hard‑to‑exploit, minor misconfig): next routine update.

We may adjust based on exploitability and user impact.

## Hall of Fame

We’re happy to credit reporters in advisories (opt‑in). If you prefer anonymity, say so.

---

**Thank you** for helping keep developers safe. If anything here is unclear, please open a discussion or contact us privately.
