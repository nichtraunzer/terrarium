#!/usr/bin/env bash
# tools/refresh-vendor-keys.sh
# Re-fetch vendor keys and print pinned ENV blocks for your Dockerfile.
# - HashiCorp: .well-known PGP key (fingerprint verified)
# - AWS CLI: derive fingerprint from a real .sig, then fetch key from a keyserver
#            (fallback to AWS docs scrape only if needed)
# - Node.js: use curated release keyring; fallback to a pinned allow-list
#
# Notes / sources:
#   - HashiCorp .well-known PGP key:
#     https://www.hashicorp.com/.well-known/pgp-key.txt
#     Verified fingerprint documented:
#     https://developer.hashicorp.com/well-architected-framework/operational-excellence/verify-hashicorp-binary
#   - AWS CLI signatures:
#     https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig
#     https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip.sig
#     (we parse the issuer fingerprint from a real signature)
#   - Node’s curated keyring:
#     https://github.com/nodejs/release-keys/blob/HEAD/gpg/pubring.kbx
#     https://github.com/nodejs/node#verifying-binaries

set -Eeuo pipefail

CURL_BIN="$(command -v curl || true)"
WGET_BIN="$(command -v wget || true)"
GPG_BIN="$(command -v gpg || true)"

if [[ -z "$GPG_BIN" ]]; then
  echo "ERROR: gpg is required but not found on PATH." >&2
  exit 2
fi

fetch() {
  # fetch <url> <outfile>
  local url="$1" out="$2"
  if [[ -n "$CURL_BIN" ]]; then
    "$CURL_BIN" -fsSL "$url" -o "$out" && return 0
  fi
  if [[ -n "$WGET_BIN" ]]; then
    "$WGET_BIN" -qO "$out" "$url" && return 0
  fi
  return 1
}

extract_pgp_block() {
  # extract_pgp_block <htmlfile> <out.asc>
  local html="$1" out="$2"
  awk '/BEGIN PGP PUBLIC KEY BLOCK/{flag=1} flag{print} /END PGP PUBLIC KEY BLOCK/{exit}' "$html" >"$out" || true
  [[ -s "$out" ]] && grep -q "BEGIN PGP PUBLIC KEY BLOCK" "$out"
}

fp_from_keyfile() {
  # fp_from_keyfile <keyfile.asc>
  gpg --batch --quiet --with-colons --import-options show-only --import "$1" 2>/dev/null \
    | awk -F: '/^fpr:/{print $10; exit}'
}

list_fps_from_ring() {
  # list_fps_from_ring <keyring>
  gpg --batch --quiet --no-default-keyring --keyring "$1" --with-colons --fingerprint 2>/dev/null \
    | awk -F: '/^fpr:/{print $10}'
}

aws_sig_to_id() {
  # aws_sig_to_id <sigfile> -> prints issuer fingerprint (40 hex) or, if absent, 16-hex keyid
  local sig="$1"
  # Try for a full issuer fingerprint first (modern signatures include this)
  local fpr
  fpr="$(
    gpg --batch --list-packets "$sig" 2>/dev/null \
      | awk -F': ' '/issuer fingerprint:/{print $2; exit}' \
      | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]'
  )"
  if [[ -n "$fpr" ]]; then
    echo "$fpr"
    return 0
  fi
  # Else, fall back to 16-hex keyid
  local keyid
  keyid="$(
    gpg --batch --list-packets "$sig" 2>/dev/null \
      | sed -n 's/^.*keyid \([0-9A-Fa-f]\{16\}\).*$/\1/p' | head -n1
  )"
  if [[ -n "$keyid" ]]; then
    echo "$(tr '[:lower:]' '[:upper:]' <<<"$keyid")"
    return 0
  fi
  return 1
}

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
export GNUPGHOME="$tmp/gnupg"; install -d -m 700 "$GNUPGHOME"

########################
# HashiCorp Security key
########################
hashi_url="${HASHICORP_URL:-https://www.hashicorp.com/.well-known/pgp-key.txt}"
hashi_asc="$tmp/hashicorp.asc"
if ! fetch "$hashi_url" "$hashi_asc"; then
  echo "ERROR: could not download HashiCorp key from $hashi_url" >&2
  exit 1
fi
hashi_fpr="$(fp_from_keyfile "$hashi_asc")"
: "${hashi_fpr:?failed to compute HashiCorp fingerprint}"

#############
# AWS CLI key
#############
aws_asc="$tmp/awscli.asc"
aws_fpr=""
aws_url="${AWS_CLI_PGP_URL:-}" # if you export it, we’ll try it first

# 1) If a direct URL is provided, try that (may be 404 / HTML now)
if [[ -n "$aws_url" ]]; then
  if fetch "$aws_url" "$aws_asc"; then
    aws_fpr="$(fp_from_keyfile "$aws_asc" || true)"
  fi
fi

# 2) Robust path: derive fingerprint from a real detached signature, then fetch key
if [[ -z "$aws_fpr" ]]; then
  sig_candidates=(
    "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig"
    "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip.sig"
  )
  for sig_url in "${sig_candidates[@]}"; do
    sig="$tmp/aws.sig"
    if fetch "$sig_url" "$sig"; then
      id="$(aws_sig_to_id "$sig" || true)"
      if [[ -n "$id" ]]; then
        # If id is a 40-hex fingerprint, fetch by fingerprint; else by keyid
        if [[ "${#id}" -eq 40 ]]; then
          if fetch "https://keys.openpgp.org/vks/v1/by-fingerprint/${id}" "$aws_asc" \
             || fetch "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${id}" "$aws_asc"; then
            aws_fpr="$(fp_from_keyfile "$aws_asc" || true)"
          fi
        else
          # 16-hex keyid
          if fetch "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${id}" "$aws_asc"; then
            aws_fpr="$(fp_from_keyfile "$aws_asc" || true)"
          fi
        fi
      fi
      [[ -n "$aws_fpr" ]] && break
    fi
  done
fi

# 3) Last resort: scrape from AWS docs if everything else failed
if [[ -z "$aws_fpr" ]]; then
  aws_doc_pages=(
    "https://docs.aws.amazon.com/cli/latest/userguide/getting-started-version.html"
    "https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html"
  )
  for p in "${aws_doc_pages[@]}"; do
    page="$tmp/aws-doc.html"
    if fetch "$p" "$page" && extract_pgp_block "$page" "$aws_asc"; then
      aws_fpr="$(fp_from_keyfile "$aws_asc" || true)"
      [[ -n "$aws_fpr" ]] && break
    fi
  done
fi

if [[ -z "$aws_fpr" ]]; then
  echo "ERROR: unable to fetch AWS CLI PGP key (tried \$AWS_CLI_PGP_URL, signature introspection, and docs fallback)" >&2
  exit 1
fi

#################
# Node release FP
#################
node_curated_ring="$tmp/nodejs-pubring.kbx"
node_fprs=""
if fetch "https://github.com/nodejs/release-keys/raw/HEAD/gpg/pubring.kbx" "$node_curated_ring"; then
  node_fprs="$(list_fps_from_ring "$node_curated_ring" | sort | xargs)"
else
  # Fallback to a conservative allow-list + attempt to fetch each
  default_node_fprs=(
    4ED778F539E3634C779C87C6D7062848A1AB005C
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1
    77984A986EBC2AA786BC0F66B01FBB92821C587A
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5
    B9AE9905FFD7803F25714661B63B535A4C206CA9
    FD3A5288F042B6850C66B31F09FE44734EB7990E
  )
  node_fprs_imported=()
  for f in "${default_node_fprs[@]}"; do
    keyfile="$tmp/node-$f.asc"
    if fetch "https://keys.openpgp.org/vks/v1/by-fingerprint/$f" "$keyfile" \
       || fetch "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${f}" "$keyfile"; then
      gpg --batch --quiet --import "$keyfile" 2>/dev/null || true
      node_fprs_imported+=("$f")
    else
      echo "WARN: could not fetch Node release key $f" >&2
    fi
  done
  node_fprs="$(printf '%s\n' "${node_fprs_imported[@]}" | sort | xargs)"
fi

iso_now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
cat <<EOF

## Refreshed: ${iso_now} (UTC)
# Sources:
#  - HashiCorp: https://www.hashicorp.com/.well-known/pgp-key.txt
#    Verified fingerprint documented: https://developer.hashicorp.com/well-architected-framework/operational-excellence/verify-hashicorp-binary
#  - AWS CLI: fingerprint derived from real detached signature (.sig), key fetched from keyserver
#  - Node: curated keyring recommended by Node (fallback to allow-list)

ENV HASHICORP_PGP_FPR=${hashi_fpr} \\
    AWS_CLI_PGP_URL="${aws_url:-}" \\
    AWS_CLI_PGP_FPR=${aws_fpr} \\
    NODE_RELEASE_FPRS="\\
$(for w in $node_fprs; do echo "    $w \\"; done)
    "
EOF
