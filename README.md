# Pkl-flake

This repository provides a Nix Flake for [Pkl](https://github.com/apple/pkl), "A
configuration as code language with rich validation and tooling."

Note that this repository simply takes the binary provided by the Pkl project
and adapts it to work on Nix. This flake does not build the project from
source.

## Usage

```
nix run github:capslock/pkl-flake -- --help
```
