#!/bin/sh
# Installs shell-proxy-agent for this OS and architecture from the latest
# GitHub release into ~/bin (override with INSTALL_DIR; pin a version with
# SHELL_PROXY_AGENT_VERSION=0.11.7).
set -eu

REPO=tpmullan/shell-proxy
VERSION="${SHELL_PROXY_AGENT_VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-${HOME}/bin}"

case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux) OS=linux ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  arm64 | aarch64) ARCH=arm64 ;;
  x86_64 | amd64) ARCH=amd64 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

ASSET="shell-proxy-agent-${OS}-${ARCH}"
if [ "${VERSION}" = latest ]; then
  URL="https://github.com/${REPO}/releases/latest/download/${ASSET}"
else
  URL="https://github.com/${REPO}/releases/download/v${VERSION#v}/${ASSET}"
fi

mkdir -p "${INSTALL_DIR}"
DEST="${INSTALL_DIR}/shell-proxy-agent"
# Download beside the destination, then rename: a failed download never
# leaves a truncated binary, and a running agent keeps its old inode.
TMP="$(mktemp "${DEST}.XXXXXX")"
trap 'rm -f "${TMP}"' EXIT

echo "Downloading ${ASSET} (${VERSION})..." >&2
curl -fsSL -o "${TMP}" "${URL}"
chmod +x "${TMP}"
mv -f "${TMP}" "${DEST}"
trap - EXIT

if [ "${OS}" = macos ]; then
  # Apple Silicon refuses to run a fully unsigned binary; an ad-hoc
  # signature satisfies it. Also clear any quarantine flag.
  xattr -d com.apple.quarantine "${DEST}" 2>/dev/null || true
  codesign -s - --force "${DEST}"
fi

echo "Installed to ${DEST}" >&2
case ":${PATH}:" in
  *":${INSTALL_DIR}:"*) ;;
  *) echo "Note: add ${INSTALL_DIR} to your PATH." >&2 ;;
esac
