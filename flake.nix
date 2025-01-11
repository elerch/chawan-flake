{
  description = "Chawan AppImage";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = 
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      shorthash = "80e4a90"; # This is the shorthash of the appimage builder repo
      upstreamShorthash = "d9ddc31"; # This is the shorthash of the Chawan repo itself
      appimagename = "Chawan-x86_64-${upstreamShorthash}.AppImage";
      exename = "cha";
    in
    pkgs.stdenv.mkDerivation {
      pname = "cha";
      version = "0.1+${upstreamShorthash}";

      src = pkgs.fetchurl {
        url = "https://git.lerch.org/api/packages/lobo/generic/chawan-appimage/${shorthash}/${appimagename}";
        hash = "sha256-Egh7SX3nMBXprHNiXwP4sU2sHyp4xOZOizj2DJZQP9I=";
      };

      nativeBuildInputs = [ pkgs.makeWrapper ];

      buildInputs = [
        pkgs.appimage-run
      ];

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin $out/share/applications

        cp $src $out/share/${appimagename}
        chmod +x $out/share/${appimagename}

        # Create desktop entry
        cat > $out/share/applications/Chawan.desktop <<EOF
        [Desktop Entry]
        Name=Chawan
        Exec=$out/bin/${exename}
        Type=Application
        Categories=Utility;
        Terminal=true;
        EOF

        ln -s "$out/share/${appimagename}" "$out/bin/${exename}"
        # makeWrapper ${pkgs.appimage-run}/bin/appimage-run "$out/bin/${exename}" \
        #   --add-flags "$out/share/${appimagename}"
      '';
    };
  };
}
