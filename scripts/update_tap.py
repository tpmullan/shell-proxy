#!/usr/bin/env python3
"""Point the tap's formulas and casks at a new release and refresh checksums.

Usage: python3 -I scripts/update_tap.py <version> <SHA256SUMS> [file ...]

With no files, every Formula/*.rb and Casks/*.rb is rewritten. Each
`url ".../releases/download/v<old>/<asset>"` followed by a `sha256` line gets
the new tag, the new asset name (the old version in it replaced by <version>)
and the checksum of that asset from SHA256SUMS (`<hex>  <file name>`); the
`version "<old>"` line follows. It fails, and writes nothing, if the release
lacks an asset a file uses, so a tap is never left with a stale checksum.
"""

import pathlib
import re
import sys

VERSION_RE = re.compile(r'^(\s*version\s+")([^"]+)(")', re.M)
BLOCK_RE = re.compile(
    r'(url\s+"https://github\.com/tpmullan/shell-proxy/releases/download/)v[^"/]+'
    r'/([^"/]+)("[^\n]*\n\s*sha256\s+")[0-9a-f]{64}(")'
)


# The same pair the other way round (`sha256` first, then `url`), as `brew style`
# orders a cask: version, sha256, url.
SHA_FIRST_RE = re.compile(
    r'(sha256\s+")[0-9a-f]{64}("[ \t]*\n(?:[ \t]*\n)*[ \t]*'
    r'url\s+"https://github\.com/tpmullan/shell-proxy/releases/download/)v[^"/]+'
    r'/([^"/]+)(")'
)


class UpdateError(Exception):
    pass


def parse_sums(text):
    sums = {}
    for line in text.splitlines():
        parts = line.split()
        if len(parts) == 2 and re.fullmatch(r"[0-9a-f]{64}", parts[0]):
            sums[parts[1].lstrip("*")] = parts[0]
    return sums


def update(text, new_version, sums):
    match = VERSION_RE.search(text)
    if not match:
        raise UpdateError('no `version "..."` line')
    old_version = match.group(2)

    def block(m):
        asset = m.group(2).replace(old_version, new_version)
        sha = sums.get(asset)
        if sha is None:
            raise UpdateError(f"{asset} is not listed in SHA256SUMS")
        return f"{m.group(1)}v{new_version}/{asset}{m.group(3)}{sha}{m.group(4)}"

    def block_sha_first(m):
        asset = m.group(3).replace(old_version, new_version)
        sha = sums.get(asset)
        if sha is None:
            raise UpdateError(f"{asset} is not listed in SHA256SUMS")
        return f"{m.group(1)}{sha}{m.group(2)}v{new_version}/{asset}{m.group(4)}"

    updated, count = BLOCK_RE.subn(block, text)
    if count == 0:
        # Only a file that has no url-then-sha256 pair is read the other way:
        # with several blocks the first way would pair one block's checksum
        # with the next block's url.
        updated, count = SHA_FIRST_RE.subn(block_sha_first, text)
    if count == 0:
        raise UpdateError("no release url/sha256 pairs")
    return VERSION_RE.sub(lambda m: f"{m.group(1)}{new_version}{m.group(3)}", updated, count=1)


def main(argv):
    if len(argv) < 3:
        sys.exit(__doc__)
    version, sums_path, *files = argv[1:]
    root = pathlib.Path(__file__).resolve().parent.parent
    paths = [pathlib.Path(f) for f in files] or sorted(
        [*root.glob("Formula/*.rb"), *root.glob("Casks/*.rb")]
    )
    sums = parse_sums(pathlib.Path(sums_path).read_text(encoding="utf-8"))
    results = {}
    try:
        for p in paths:
            results[p] = update(p.read_text(encoding="utf-8"), version, sums)
    except UpdateError as e:
        sys.exit(f"update_tap: {p}: {e}")
    for p, text in results.items():
        p.write_text(text, encoding="utf-8")
        print(f"{p}: now {version}")


if __name__ == "__main__":
    main(sys.argv)
