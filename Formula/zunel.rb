class Zunel < Formula
  desc "CLI and Slack gateway for the Zunel personal AI assistant."
  homepage "https://github.com/zunel-bot/homebrew-tap"
  version "1.1.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v1.1.0/zunel-cli-aarch64-apple-darwin.tar.xz"
      sha256 "685ce45b331f851987ba05d570bcd4754bd215c529aab8b6dc8f3a8169cb3a09"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v1.1.0/zunel-cli-x86_64-apple-darwin.tar.xz"
      sha256 "da920511609eda5f79f233e4640f51d7763db2ba3b55d2d26dcb2e716fcf8bce"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v1.1.0/zunel-cli-aarch64-unknown-linux-musl.tar.xz"
      sha256 "89bdebf8e2861664114ac0f03a733cc941d53c26629762b03c650053096e14a1"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v1.1.0/zunel-cli-x86_64-unknown-linux-musl.tar.xz"
      sha256 "ff749d33680dddfc31870be874ffdaee2578b81b6e0dcd6c9538050fb08e0701"
    end
  end
  license "MIT"

  BINARY_ALIASES = {
    "aarch64-apple-darwin":               {},
    "aarch64-unknown-linux-gnu":          {},
    "aarch64-unknown-linux-musl-dynamic": {},
    "aarch64-unknown-linux-musl-static":  {},
    "x86_64-apple-darwin":                {},
    "x86_64-unknown-linux-gnu":           {},
    "x86_64-unknown-linux-musl-dynamic":  {},
    "x86_64-unknown-linux-musl-static":   {},
  }.freeze

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    bin.install "zunel" if OS.mac? && Hardware::CPU.arm?
    bin.install "zunel" if OS.mac? && Hardware::CPU.intel?
    bin.install "zunel" if OS.linux? && Hardware::CPU.arm?
    bin.install "zunel" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end

  service do
    run [opt_bin/"zunel", "gateway"]
    keep_alive true
    log_path var/"log/zunel-gateway.out.log"
    error_log_path var/"log/zunel-gateway.err.log"
    environment_variables RUST_LOG: "info,zunel=info",
                          PATH:     "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
  end
end
