# Artifact Attestation & Image Signing — Feasibility Research

**Date:** 2026-04-01
**Status:** Research complete — implementation deferred to Phase 9D
**Context:** Phase 9C, Step 9.15

---

## Goal

Assess feasibility of cryptographically signing terrarium container images and
attaching SBOM attestations, enabling consumers to verify image provenance
across the repo chain:

```
nichtraunzer/terrarium → effektiv-ai/terrarium-security-hardening → ccg-terrarium
```

---

## Current State

- **BuildKit SBOM:** `--sbom=true` is already passed to `docker buildx build`
  in `main.yaml` (line 127) and `release.yaml` (line 134). This generates a
  BuildKit SBOM attestation attached to the pushed GHCR image.
- **No image signing:** No cosign or GitHub attestation steps exist.
- **No `id-token: write`:** Workflows use `contents: read` + `packages: write`.
  Keyless cosign and `actions/attest-build-provenance` require `id-token: write`.
- **Direct buildx:** Workflows use `docker buildx build` directly (not
  `docker/build-push-action`). Digest extraction requires `--metadata-file`
  or `docker buildx imagetools inspect` post-push.

---

## Approaches Evaluated

### 1. GitHub Native Attestation (`actions/attest-build-provenance`)

| Aspect | Detail |
|--------|--------|
| **How it works** | GitHub generates SLSA provenance attestation, attaches to GHCR image |
| **Permissions needed** | `id-token: write` (for OIDC token), `attestations: write` |
| **Consumer verification** | `gh attestation verify ghcr.io/OWNER/REPO@DIGEST` |
| **Pros** | Native GitHub integration; no external tools; attested by GitHub's Sigstore instance |
| **Cons** | Requires digest as input — need to extract from buildx; GitHub-specific |
| **Compatibility** | Works with direct `docker buildx build` if digest is captured via `--metadata-file` |

**Digest extraction approach:**
```bash
docker buildx build ... --metadata-file /tmp/build-metadata.json --push ...
DIGEST=$(jq -r '."containerimage.digest"' /tmp/build-metadata.json)
```

### 2. Sigstore/Cosign Keyless Signing

| Aspect | Detail |
|--------|--------|
| **How it works** | Cosign uses GitHub Actions OIDC identity for keyless signing via Sigstore |
| **Permissions needed** | `id-token: write` |
| **Consumer verification** | `cosign verify --certificate-identity-regexp=... --certificate-oidc-issuer=...` |
| **Pros** | Industry standard; works across registries; supports SBOM attestation attachment |
| **Cons** | Additional tool dependency (cosign-installer action); more complex verification |
| **Cross-repo** | Downstream can verify upstream signature using OIDC identity matching |

**SBOM attestation with cosign:**
```bash
syft ghcr.io/OWNER/REPO@$DIGEST -o spdx-json > sbom.json
cosign attest --predicate sbom.json --type spdxjson --yes ghcr.io/OWNER/REPO@$DIGEST
```

### 3. BuildKit SBOM (already active)

| Aspect | Detail |
|--------|--------|
| **What it provides** | Package inventory (not provenance) — lists detected packages in the image |
| **Limitations** | Misses binary-downloaded tools; no cryptographic signing; no provenance chain |
| **Verdict** | Useful as supplementary data, but NOT sufficient for provenance verification |

---

## Key Findings

### Digest Extraction (Critical Blocker — Resolved)

Both `main.yaml` and `release.yaml` use direct `docker buildx build --push`.
The digest is not currently captured. Solution: add `--metadata-file` flag:

```yaml
docker buildx build \
  --file docker/Dockerfile.terrarium \
  --target final \
  --push \
  --metadata-file /tmp/build-metadata.json \
  ...
```

This is a minor, low-risk change.

### Jenkins Cosign Support

The ccg-terrarium Jenkins pipeline runs on OpenShift. Options:

1. **cosign binary:** Install cosign in the Jenkins agent or as a pipeline step.
   Cosign is a single static binary (~50MB) — straightforward.
2. **Keyless vs key pair:** Jenkins does not have GitHub OIDC. For keyless
   signing, a Sigstore-compatible OIDC provider is needed (not available in
   most Jenkins setups). **Recommendation:** Use a stored cosign key pair
   for the internal leg, or skip signing the Nexus image entirely (internal
   trust boundary).
3. **Verification only:** Jenkins can verify upstream GHCR image signatures
   using cosign without needing its own OIDC identity. This is the minimum
   viable integration.

### Cross-Repo Verification Chain

```
nichtraunzer/terrarium
    → cosign sign (keyless, GitHub OIDC: nichtraunzer/terrarium workflow)
    → consumers verify with: --certificate-identity-regexp='github.com/nichtraunzer/terrarium/.*'

effektiv-ai/terrarium-security-hardening
    → cosign verify upstream image (fails build if invalid)
    → cosign sign derivative (keyless, GitHub OIDC: effektiv-ai/... workflow)

ccg-terrarium (Jenkins)
    → cosign verify GHCR image (binary install, no signing needed)
    → build internal derivative, push to Nexus
```

---

## Recommendation

**Use cosign keyless signing (Option 2) as the primary approach**, with GitHub
native attestation as a supplementary layer:

1. **Cosign** for image signing — industry standard, cross-registry, cross-repo
   verification works naturally with OIDC identity matching.
2. **GitHub native attestation** as additional provenance (if low effort) — gives
   `gh attestation verify` as a convenience for GitHub-native consumers.
3. **Syft SBOM** attached as cosign attestation — machine-readable license/package
   data alongside the human-readable `TOOLS_AND_LICENSES.md`.

### Implementation effort

| Step | Effort | Risk |
|------|--------|------|
| Add `--metadata-file` to buildx commands | Small | Low |
| Add `id-token: write` permission | Small | Low |
| Add cosign-installer + sign step | Small | Low |
| Add Syft SBOM attestation step | Small-Medium | Low |
| Add upstream verification in fork workflows | Medium | Medium (fails build if upstream not signed yet) |
| Add cosign verification in Jenkins | Medium | Medium (need cosign binary in agent) |

**Total: ~1 day of implementation + testing, spread across 3 repos.**

---

## Blockers for Phase 9D

1. **Upstream repo consent:** Adding cosign to `nichtraunzer/terrarium` requires
   buy-in from `@nichtraunzer`. Discuss before implementing 9D.1.
2. **Jenkins environment:** Verify cosign binary can be installed/used in the
   OpenShift Jenkins agent. Test with `cosign verify` on a signed GHCR image.
3. **Digest availability:** The `--metadata-file` change must land before
   signing can be implemented.

---

## References

- [Sigstore cosign](https://docs.sigstore.dev/cosign/signing/signing_with_containers/)
- [GitHub artifact attestations](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations)
- [actions/attest-build-provenance](https://github.com/actions/attest-build-provenance)
- [Syft SBOM generator](https://github.com/anchore/syft)
- [SLSA provenance](https://slsa.dev/provenance/v1)
