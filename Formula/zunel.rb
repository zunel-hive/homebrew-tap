class Zunel < Formula
  desc "Rust CLI and gateway for the Zunel personal AI assistant."
  homepage "https://github.com/zunel-hive/zunel-binaries"
  version "0.2.4"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.4/zunel-cli-aarch64-apple-darwin.tar.xz"
      sha256 "c08bbec1ec5bb3af66b1bc168786ea075caf88d8e23d48548fc0229bb6fbd49f"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.4/zunel-cli-x86_64-apple-darwin.tar.xz"
      sha256 "06df938c96975c1b23a21fed5c67d0cc801a11e3e1ee3621e69297f95632a30b"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.4/zunel-cli-aarch64-unknown-linux-musl.tar.xz"
      sha256 "009c136629b01b6dd46e875dfe0fd1016fe59568d592b330174ec8a97cf8eb45"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.4/zunel-cli-x86_64-unknown-linux-musl.tar.xz"
      sha256 "c51028ff25dcf4342c4285aa622ad2df736de65be517523477567f9016ab94e3"
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
