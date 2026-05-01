class Zunel < Formula
  desc "Rust CLI and gateway for the Zunel personal AI assistant."
  homepage "https://github.com/zunel-hive/zunel-binaries"
  version "0.2.5"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.5/zunel-cli-aarch64-apple-darwin.tar.xz"
      sha256 "c47b58873eed91ba1180704c868b591f5f70b60fe3bb25c229ad364b092a3311"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.5/zunel-cli-x86_64-apple-darwin.tar.xz"
      sha256 "25e24ccfdfc2739bd3b7be6e46a051cb767f10d3b7eed747ae2243c3f0d9f107"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.5/zunel-cli-aarch64-unknown-linux-musl.tar.xz"
      sha256 "9be7f3d5eb06c2c68ef6c165332a955c278f6ade830d8b7c315c7e006e79231b"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.5/zunel-cli-x86_64-unknown-linux-musl.tar.xz"
      sha256 "020b63b205a1768a7eecb7d02d50577697f69964d6768656576acc4b4a61675d"
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
