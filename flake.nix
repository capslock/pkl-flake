{
  description = "A configuration as code language with rich validation and tooling";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    systemToPlatform = {
      x86_64-linux = "linux-amd64";
      aarch64-linux = "linux-aarch64";
      x86_64-darwin = "macos-amd64";
      aarch64-darwin = "macos-aarch64";
    };
    current = builtins.fromJSON (builtins.readFile ./current.json);
    package = {
      pkgs,
      system,
      version,
      sha256,
    }:
      pkgs.stdenv.mkDerivation rec {
        pname = "pkl-cli";
        inherit version;

        src = pkgs.fetchurl {
          url = "https://github.com/apple/pkl/releases/download/${version}/pkl-${systemToPlatform.${system}}";
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
          ln -s $out/bin/pkl-cli $out/bin/pkl
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
          version = current.tag_name;
          sha256 = current.platforms.${systemToPlatform.${system}};
        };
        default = pkl;
      }
    );
  };
}
