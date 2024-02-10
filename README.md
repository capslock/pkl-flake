# Pkl-flake

[![CI](https://github.com/capslock/pkl-flake/actions/workflows/ci.yml/badge.svg)](https://github.com/capslock/pkl-flake/actions?query=workflow%3ACI+event%3Apush)
        
This repository provides a [Nix](https://nixos.org/) Flake for
[Pkl](https://github.com/apple/pkl), "[a] configuration as code language with rich
validation and tooling."

Note that this repository simply takes the binary provided by the Pkl project
and adapts it to work on Nix. This flake does not build the project from
source.

## Quick Start

Run Pkl with `nix run`:

```
nix run github:capslock/pkl-flake -- --help
```

## Auto Updates

This repository has a
[github action](https://github.com/capslock/pkl-flake/blob/main/.github/workflows/update.yml)
that automatically runs once a day and checks for new releases of Pkl. 

* This action uses the
  [`update.sh`](https://github.com/capslock/pkl-flake/blob/main/update.sh) script
  to check the latest release against
  [`current.json`](https://github.com/capslock/pkl-flake/blob/main/current.json).
* If a new release exists, the action will open a PR, updating `current.json`
  with the latest version timestamp and nix hashes.
* Manual triggers of this action are supported.

### Performing manual updates

Prerequisites: `curl`, `jq`, and `nix`.

Update the flake by running:

```
bash update.sh
```

`current.json` is updated on success.

## Contributing

Contributions are welcome! Submit issues and pull requests for improvements or
bug fixes.
