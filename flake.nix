{
  description = "A configuration as code language with rich validation and tooling";

  outputs = {
    self,
    nixpkgs,
    ...
  }: {
    defaultPackage.x86_64-linux = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
      lib = pkgs.lib;
    in
      pkgs.stdenv.mkDerivation rec {
        pname = "pkl-cli";
        version = "0.25.1";

        src = pkgs.fetchurl {
          url = "https://github.com/apple/pkl/releases/download/${version}/pkl-linux-amd64";
          sha256 = "sha256-j7QzBDQr0dY9HmDT3Pu/ds/cHdFf2M/VMf7FWe7L0z0=";
        };

        dontUnpack = true;

        nativeBuildInputs = [
          pkgs.autoPatchelfHook
        ];

        buildInputs = [
          pkgs.stdenv.cc.cc.lib
          pkgs.zlib
        ];

        sourceRoot = ".";

        installPhase = ''
          runHook preInstall
          install -m755 -D ${src} $out/bin/pkl-cli
          runHook postInstall
        '';

        meta = with lib; {
          description = "A configuration as code language with rich validation and tooling";
          longDescription = ''
            Pkl is a configuration-as-code language with rich validation and
            tooling. It can be used as a command line tool, software library, or
            build plugin. Pkl scales from small to large, simple to complex,
            ad-hoc to recurring configuration tasks.
          '';
          homepage = "https://pkl-lang.org/";
          platforms = platforms.linux;
          maintainers = [];
          license = with licenses; [asl20];
          priority = 10;
        };
      };
  };
}
