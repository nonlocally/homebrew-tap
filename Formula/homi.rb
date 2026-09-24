class Homi < Formula
  desc "Persistent agent identities, messaging, and execution"
  homepage "https://github.com/nonlocally/HOMI"
  url "https://github.com/nonlocally/HOMI/releases/download/v0.3.0/homi-0.3.0.tar.gz"
  sha256 "1bdc0c8603f285fc7cf6afcc93ef491e6324be8e2958209b3c28214aea0d4ebe"
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
      Enable your agent integrations explicitly:
        homi setup --claude --codex
        homi doctor

      To enable the persistent local daemon:
        homi setup --service

      Terminal and mesh profiles are optional. Preview before applying:
        homi profile preview --terminal --mesh

      Install tmux for agent panes; fzf and jq for the optional terminal/mesh profile.
      Model clients and their authentication are managed separately.
      Installing or upgrading this formula does not replace your terminal configuration.
    EOS
  end

  test do
    require "json"
    require "digest"
    JSON.parse((libexec/"release.json").read).fetch("files").each do |name, sha|
      assert_equal sha, Digest::SHA256.file(libexec/name).hexdigest
    end
    assert_match "0.3.0", shell_output("#{bin}/homi version")
    assert_match "bus", shell_output("#{bin}/homi --help")
    ENV["HOME"] = testpath
    ENV["COMMUNICATE_DATA"] = testpath/"data"
    ENV["COMM_STATE"] = testpath/"state"
    system bin/"homi", "setup", "--no-clients", "--dry-run"
    refute_path_exists testpath/"data"
  end
end
