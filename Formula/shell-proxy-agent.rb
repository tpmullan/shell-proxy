# frozen_string_literal: true

class ShellProxyAgent < Formula
  desc "Shell Proxy agent: reverse SSH tunnels and the jump ProxyCommand"
  homepage "https://github.com/tpmullan/shell-proxy"
  version "0.14.1"

  on_macos do
    on_arm do
      url "https://github.com/tpmullan/shell-proxy/releases/download/v0.14.1/shell-proxy-agent-macos-arm64"
      sha256 "5d1c2d72dc6e6c2a5e92d488bd3a34089b05d918c67eb1db13038a374355decb"
    end
    on_intel do
      url "https://github.com/tpmullan/shell-proxy/releases/download/v0.14.1/shell-proxy-agent-macos-amd64"
      sha256 "6970df00bc03b6f66a4e0327b0360e454bebaa52656b924a5335e22f7a040938"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tpmullan/shell-proxy/releases/download/v0.14.1/shell-proxy-agent-linux-arm64"
      sha256 "dc7e7b1e8d60aa9e80a73f235b001e55c8d02f81b03372e7a5643cc8b3c643a2"
    end
    on_intel do
      url "https://github.com/tpmullan/shell-proxy/releases/download/v0.14.1/shell-proxy-agent-linux-amd64"
      sha256 "7bbdc201de144ab9b7758ba8c8ba4ba87e1e3e9389aefd230546f5fd61e36b3e"
    end
  end

  def install
    bin.install Dir["shell-proxy-agent-*"].first => "shell-proxy-agent"
  end

  test do
    assert_match "shell-proxy-agent", shell_output("#{bin}/shell-proxy-agent --version")
  end
end
