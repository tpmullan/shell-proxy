# frozen_string_literal: true

class ShellProxyAgent < Formula
  desc "Shell Proxy agent: reverse SSH tunnels and the jump ProxyCommand"
  homepage "https://github.com/tpmullan/shell-proxy"
  version "0.14.0"

  on_macos do
    on_arm do
      url "https://github.com/tpmullan/shell-proxy/releases/download/v0.14.0/shell-proxy-agent-macos-arm64"
      sha256 "25c614a5826538d07ff169e5cc1b35880d219883bd338ae4fd13afd01229ddc1"
    end
    on_intel do
      url "https://github.com/tpmullan/shell-proxy/releases/download/v0.14.0/shell-proxy-agent-macos-amd64"
      sha256 "dfd7bfbabcf61cb97123b4fca88540dcaee8a53fd831e6ecbe8a14fce2029d9b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tpmullan/shell-proxy/releases/download/v0.14.0/shell-proxy-agent-linux-arm64"
      sha256 "2877f4fec35651c2470f26c1f95ea8e33c91f8e2b04571e219fbe6c8f6ed16aa"
    end
    on_intel do
      url "https://github.com/tpmullan/shell-proxy/releases/download/v0.14.0/shell-proxy-agent-linux-amd64"
      sha256 "f3c08950decbbec76a5404c33e08c85cb18557ef3cf8a6a63151e373002c65e8"
    end
  end

  def install
    bin.install Dir["shell-proxy-agent-*"].first => "shell-proxy-agent"
  end

  test do
    assert_match "shell-proxy-agent", shell_output("#{bin}/shell-proxy-agent --version")
  end
end
