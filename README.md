# nonlocally Homebrew tap

This private tap stages the HOMI formula for public distribution. Until the
release repository and tap are public, install from the authenticated release
archive described in the [HOMI installation guide](https://github.com/nonlocally/HOMI/blob/v0.3.0/docs/INSTALL.md).

After public launch:

```sh
brew install nonlocally/tap/homi
homi setup --claude --codex
homi doctor
```

Enable only the clients you use. Client authentication, service setup and optional
profiles are separate from formula installation. Upgrading the formula requires
explicit activation with its `homi update`; remove owned integrations before
uninstalling the formula. See the installation guide for the exact order.

MIT licensed.
