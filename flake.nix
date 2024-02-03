{
  description = "A configuration as code language with rich validation and tooling";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    archStrings = {
      x86_64-linux = "linux-amd64";
      aarch64-linux = "linux-aarch64";
      x86_64-darwin = "macos-amd64";
      aarch64-darwin = "macos-aarch64";
    };
    package = {
      pkgs,
      system,
      version ? "0.25.1",
      sha256,
    }:
      pkgs.stdenv.mkDerivation rec {
        pname = "pkl-cli";
        inherit version;

        src = pkgs.fetchurl {
          url = "https://github.com/apple/pkl/releases/download/${version}/pkl-${archStrings.${system}}";
          inherit sha256;
        };

        dontUnpack = true;

        nativeBuildInputs =
          pkgs.lib.optionals (!pkgs.stdenv.isDarwin) [pkgs.autoPatchelfHook];

        buildInputs = pkgs.lib.optionals (!pkgs.stdenv.isDarwin) [
          pkgs.stdenv.cc.cc.lib
          pkgs.zlib
        ];

        sourceRoot = ".";

        installPhase = ''
          runHook preInstall
          install -m755 -D ${src} $out/bin/pkl-cli
          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "A configuration as code language with rich validation and tooling";
          longDescription = ''
            Pkl is a configuration-as-code language with rich validation and
            tooling. It can be used as a command line tool, software library, or
            build plugin. Pkl scales from small to large, simple to complex,
            ad-hoc to recurring configuration tasks.
          '';
          homepage = "https://pkl-lang.org/";
          platforms = [system];
          maintainers = [];
          license = with licenses; [asl20];
          priority = 10;
        };
      };
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    hashes = {
      x86_64-linux = "sha256-j7QzBDQr0dY9HmDT3Pu/ds/cHdFf2M/VMf7FWe7L0z0=";
      aarch64-linux = "sha256-40okn7pTy9zOgRNrCkfoUVmifirgr55L68R1n3LsPwE=";
      x86_64-darwin = "sha256-HajWx+rKin785hgrudcDiwkqjkqIJCA6S6BXmjgE1So=";
      aarch64-darwin = "sha256-7k4c9B0W/JgQQTnwzLJU+p+LeAy2Gg8Scx2jWmxl+d0=";
    };
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
      });
  in {
    packages = forAllSystems (
      system: rec {
        pkl = package {
          inherit system;
          pkgs = nixpkgsFor.${system};
          sha256 = hashes.${system};
        };
        default = pkl;
      }
    );
  };
}
