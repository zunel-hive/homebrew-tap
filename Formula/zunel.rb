class Zunel < Formula
  desc "Rust CLI and gateway for the Zunel personal AI assistant."
  homepage "https://github.com/zunel-hive/zunel-binaries"
  version "0.2.7"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.7/zunel-cli-aarch64-apple-darwin.tar.xz"
      sha256 "cb2340f5c4ae0827e4868e17735296b07a18c2bf8aa5520c546dd42808be95ab"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.7/zunel-cli-x86_64-apple-darwin.tar.xz"
      sha256 "b536608d5f286d0f95e355b1c5f3b01be2b83ee19f939def8a47883e042cfba3"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.7/zunel-cli-aarch64-unknown-linux-musl.tar.xz"
      sha256 "81e615cebebfa93434c44f9e61d7b18c32da7904f3c5ab840c734b0c779ae322"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.7/zunel-cli-x86_64-unknown-linux-musl.tar.xz"
      sha256 "dc0966595f3677bcb957968559c2f5e41a915c65942224021d7b46e51aae128f"
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
