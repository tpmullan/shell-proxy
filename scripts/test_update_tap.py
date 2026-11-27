import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import update_tap as u  # noqa: E402

BASE = "https://github.com/tpmullan/shell-proxy/releases/download"
OLD = "a" * 64
FORMULA = f'''version "1.0.0"
  url "{BASE}/v1.0.0/agent-linux"
  sha256 "{OLD}"
'''
CASK = f'''version "1.0.0"
  url "{BASE}/v1.0.0/App-1.0.0-arm64.tar.gz"
  sha256 "{OLD}"
'''
# As `brew style` orders a cask: version, sha256, a blank line, url.
CASK_SHA_FIRST = f'''cask "app" do
  version "1.0.0"
  sha256 "{OLD}"

  url "{BASE}/v1.0.0/App-1.0.0-arm64.tar.gz"
  name "App"
end
'''
# Two blocks, each url then sha256: they must not be paired across.
TWO_BLOCKS = f'''version "1.0.0"
  on_arm do
    url "{BASE}/v1.0.0/agent-linux"
    sha256 "{OLD}"
  end
  on_intel do
    url "{BASE}/v1.0.0/App-1.0.0-arm64.tar.gz"
    sha256 "{OLD}"
  end
'''
SUMS = u.parse_sums(f"{'b' * 64}  agent-linux\n{'c' * 64}  App-1.1.0-arm64.tar.gz\n")


class UpdateTapTest(unittest.TestCase):
    def test_versionless_asset_gets_new_tag_and_checksum(self):
        out = u.update(FORMULA, "1.1.0", SUMS)
        self.assertIn('version "1.1.0"', out)
        self.assertIn(f"{BASE}/v1.1.0/agent-linux", out)
        self.assertIn("b" * 64, out)

    def test_versioned_asset_is_renamed(self):
        out = u.update(CASK, "1.1.0", SUMS)
        self.assertIn(f"{BASE}/v1.1.0/App-1.1.0-arm64.tar.gz", out)
        self.assertIn("c" * 64, out)

    def test_a_cask_in_style_order_sha256_then_url_is_updated(self):
        out = u.update(CASK_SHA_FIRST, "1.1.0", SUMS)
        self.assertIn('version "1.1.0"', out)
        self.assertIn(f"{BASE}/v1.1.0/App-1.1.0-arm64.tar.gz", out)
        self.assertIn(f'sha256 "{"c" * 64}"', out)
        self.assertNotIn(OLD, out)
        self.assertIn('name "App"', out)

    def test_url_then_sha256_blocks_are_not_paired_across_each_other(self):
        out = u.update(TWO_BLOCKS, "1.1.0", SUMS)
        self.assertIn(f'url "{BASE}/v1.1.0/agent-linux"\n    sha256 "{"b" * 64}"', out)
        self.assertIn(
            f'url "{BASE}/v1.1.0/App-1.1.0-arm64.tar.gz"\n    sha256 "{"c" * 64}"', out
        )
        self.assertNotIn(OLD, out)

    def test_missing_asset_fails_without_a_partial_rewrite(self):
        with self.assertRaises(u.UpdateError):
            u.update(CASK, "2.0.0", SUMS)

    def test_file_without_release_urls_fails(self):
        with self.assertRaises(u.UpdateError):
            u.update('version "1.0.0"\n', "1.1.0", SUMS)


if __name__ == "__main__":
    unittest.main()
