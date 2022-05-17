{
  description = "LaTex Demo";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = {self, nixpkgs, flake-utils}:
    with flake-utils.lib; eachSystem allSystems (system:
      let 
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-basic latexmk pgf 
          nicematrix fontspec;
        };
        vars = ["sender" "receiver"];
        texvars = toString
          (pkgs.lib.imap1 (i: n: ''\def\${n}{${"$" + (toString i)}}'') vars);
      in rec {
        packages = {
          document = pkgs.stdenvNoCC.mkDerivation rec{
            name = "latex-demo-document";
            src = self;
            propagatedBuildInputs = [pkgs.coreutils pkgs.fira-code tex];
            phases = ["unpackPhase" "buildPhase" "installPhase"];
            SCRIPT = ''
              #!/usr/bin/env bash
              prefix=${builtins.placeholder "out"}
              export PATH="${pkgs.lib.makeBinPath propagatedBuildInputs}";
              DIR=$(mktemp -d)
              RES=$(pwd)/document.pdf
              cd $prefix/share
              mkdir -p "$DIR/.texcache/texmf-var"
              env TEXMFHOME="$DIR/.cache" \
                  TEXMFVAR="$DIR/.cache/texmf-var" \
                  OSFONTDIR=${pkgs.fira-code}/share/fonts \
                latexmk -interaction=nonstopmode -pdf -lualatex \
                -output-directory="$DIR" \
                -pretex="\pdfvariable suppressoptionalinfo 512\relax${texvars}" \
                -usepretex document.tex
              mv "$DIR/document.pdf" $RES
              rm -rf "$DIR"
            '';
            buildPhase = ''
              printenv SCRIPT >latex-demo-document
            ''; 
            installPhase = ''
              mkdir -p $out/{bin,share}
              cp document.tex $out/share/document.tex
              cp latex-demo-document $out/bin/latex-demo-document
              chmod u+x $out/bin/latex-demo-document
            '';
          };
        };
        defaultPackage = packages.document;
      }
    );
}