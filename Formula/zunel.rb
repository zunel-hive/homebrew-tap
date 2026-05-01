class Zunel < Formula
  desc "Rust CLI and gateway for the Zunel personal AI assistant."
  homepage "https://github.com/zunel-hive/zunel-binaries"
  version "0.2.2"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.2/zunel-cli-aarch64-apple-darwin.tar.xz"
      sha256 "5d8897cc977237dfb4d72881f7b42e38fe55c6ce5c6f65e473116530a3f5c946"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.2/zunel-cli-x86_64-apple-darwin.tar.xz"
      sha256 "1cee7af408140e74c4df237587f14c8b7fa5b9997ad12a69b3c7ff8d3443c9cd"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.2/zunel-cli-aarch64-unknown-linux-musl.tar.xz"
      sha256 "29897b3f62e4a9e6d944f3f6bec96f96759e47a915865262f9c2a6f8be03827b"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.2/zunel-cli-x86_64-unknown-linux-musl.tar.xz"
      sha256 "a1f9260af91022140baafe706be82eccd329a43e6a8f43af6126b44c386a1569"
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
    environment_variables RUST_LOG: "info,zunel=info"
  end
end
