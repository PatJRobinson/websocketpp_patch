{
  description = "A flake to derive a patched-for-cpp20 version of websocketpp";

  outputs = { self, nixpkgs } : let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    wspp_patch = self;

    websocketpp = pkgs.fetchFromGitHub {
      owner = "zaphoyd";
      repo = "websocketpp";
      rev = "0.8.2";             # pick the websocketpp tag you used in Docker
      sha256 = "sha256-9fIwouthv2GcmBe/UPvV7Xn9P2o0Kmn2hCI4jCh0hPM="; # run `nix build` once to get correct hash or prefetch
    };

  in {

    packages.${system}.default = pkgs.stdenv.mkDerivation {
      pname = "websocketpp-patched";
      version = "0.8.2-patched";

      src = pkgs.runCommand "combined-sources" {} ''
          mkdir -p $out
          chmod -R u+w $out
          cp -r ${websocketpp} $out/
          cp -r ${wspp_patch} $out/
      '';

      # apply the websocketpp patch script from the fetched wspp_patch
      postPatch = ''
        outdir="$PWD/patched"
        mkdir -p $outdir

        # create writable copy of headers in tmp
        tmpdir="/tmp/patched"
        mkdir -p $tmpdir
        cp -r ${websocketpp}/* "$tmpdir/"
        chmod -R u+w $tmpdir

        # copy patch script to writable tmp
        tmp_patch="$TMPDIR/patch_wspp"
        mkdir -p "$tmp_patch"
        cp -r ${wspp_patch}/* "$tmp_patch"

        echo "Applying websocketpp_patch from ${wspp_patch}" 
        bash "$tmp_patch/patch_wspp.sh" "$tmp_patch" "$tmpdir/websocketpp"

        cp -r $tmpdir/* "$outdir"

        echo "Patched files:"
        ls -R "$outdir/websocketpp"
      '';

      # Install headers (websocketpp is header-only)
      installPhase = ''
        mkdir -p $out/
        cp -r $PWD/patched/* $out
        cat "$out/websocketpp/transport/asio/connection.hpp"
      '';

      meta = with pkgs.lib; {
        description = "websocketpp with C++20 patches applied";
        license = licenses.mit; # choose correct license
        maintainers = [ ];
      };
    };
  };

}
