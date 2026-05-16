class Zunel < Formula
  desc "CLI and Slack gateway for the Zunel personal AI assistant."
  homepage "https://github.com/zunel-bot/homebrew-tap"
  version "2.2.1"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v2.2.1/zunel-cli-aarch64-apple-darwin.tar.xz"
      sha256 "6ae87200b0e39cdb97f5e02654029df8205509e9b20a3f11225ab304e05466b7"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v2.2.1/zunel-cli-x86_64-apple-darwin.tar.xz"
      sha256 "6751e292995771ee79815bab98b0747a1d874cdf64f7705c18ddc9fdd3673500"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v2.2.1/zunel-cli-aarch64-unknown-linux-musl.tar.xz"
      sha256 "26ad6566c44ed443fce61c602eff0360e064dbdf966f829c618568b9cb269bbc"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v2.2.1/zunel-cli-x86_64-unknown-linux-musl.tar.xz"
      sha256 "6398461cc09780e52d550593c744d340e26b1ebbd767fad157107f30ef3d384a"
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
