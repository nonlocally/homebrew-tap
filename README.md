# nonlocally Homebrew tap

Homebrew formula for [HOMI](https://github.com/nonlocally/HOMI): persistent agent
identities, messaging, and execution.

```sh
brew install nonlocally/tap/homi
homi setup
homi doctor
```

Guided setup offers missing software for the clients and optional features you
select, shows the plan, and asks before applying it. Provider login is separate.
The terminal shortcuts work from zsh or Bash without changing your interactive
shell. After setup, ask your coding agent to create peers and coordinate work;
its HOMI skills and tools perform the operations.

Client authentication, service setup and optional profiles are separate from
formula installation. Upgrading the formula requires
explicit activation with its `homi update`; remove owned integrations before
uninstalling the formula. See the [installation guide](https://github.com/nonlocally/HOMI/blob/v0.5.0/docs/INSTALL.md#homebrew) for the exact order.

MIT licensed.
