class Homi < Formula
  desc "Persistent agent identities, messaging, and execution"
  homepage "https://github.com/nonlocally/HOMI"
  url "https://github.com/nonlocally/HOMI/releases/download/v0.5.1/homi-0.5.1.tar.gz"
  sha256 "adb8b898a5e9bf62d505c5b8d4ea674839e2d08619caac7c5805b5ba97b26135"
  license "MIT"

  depends_on "bash"
  depends_on "node"
  depends_on "python@3.14"

  # Every runtime file is checksummed; wrappers provide the dependency PATH.
  # Homebrew's shebang rewrite would invalidate the installed archive.
  skip_clean "libexec"

  def skip_clean?(path)
    # Reinstall can expose prefix through opt while Cleaner walks its real
    # Cellar path. Protect either spelling of the immutable runtime directory.
    return true if path == libexec || (libexec.directory? && path == libexec.realpath)

    super
  end

  def install
    libexec.install Dir["*"]
    # Homebrew moves metafiles out of libexec when the prefix has none.
    # Expose the license at the prefix while retaining the immutable runtime.
    prefix.install_symlink libexec/"LICENSE"
    (bin/"homi").write_env_script libexec/"bin/homi",
      PATH: "#{Formula["node"].opt_bin}:#{Formula["python@3.14"].opt_bin}:#{Formula["bash"].opt_bin}:$PATH"
    (bin/"communicate").write_env_script libexec/"bin/communicate",
      PATH: "#{Formula["node"].opt_bin}:#{Formula["python@3.14"].opt_bin}:#{Formula["bash"].opt_bin}:$PATH"
  end

  def caveats
    <<~EOS
      Choose your clients and optional workstation tools:
        homi setup
        homi doctor

      Preview an explicit selection, including missing dependencies:
        homi setup --install-missing --claude --codex --terminal --mesh --dry-run
      Replace --dry-run with --yes to apply it. Add --ghostty on macOS if wanted.

      To enable the persistent local daemon:
        homi setup --service

      Terminal and mesh profiles are optional. Preview before applying:
        homi profile preview --terminal --mesh

      Guided setup offers missing selected tools and clients. Login is a separate choice.
      Selected clients include tmux for agent seats; terminal configuration remains optional.
      Terminal shortcuts work from zsh or Bash; your interactive and login shells stay unchanged.
      Existing clients are not implicitly upgraded; HOMI uninstall keeps third-party packages.
      Installing or upgrading this formula does not replace your terminal configuration.
    EOS
  end

  test do
    require "json"
    require "digest"
    JSON.parse((libexec/"release.json").read).fetch("files").each do |name, sha|
      assert_equal sha, Digest::SHA256.file(libexec/name).hexdigest
    end
    assert_match "0.5.1", shell_output("#{bin}/homi version")
    assert_match "bus", shell_output("#{bin}/homi --help")
    ENV["HOME"] = testpath
    ENV["COMMUNICATE_DATA"] = testpath/"data"
    ENV["COMM_STATE"] = testpath/"state"
    system bin/"homi", "setup", "--no-clients", "--dry-run"
    refute_path_exists testpath/"data"
  end
end
