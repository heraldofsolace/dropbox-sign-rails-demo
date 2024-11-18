{
  description = "Ruby on Rails development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        pg_version = "14";

        rubyEnv = pkgs.bundlerEnv {
          # The full app environment with dependencies
          name = "ds-env";
          ruby = pkgs.ruby_3_3;
          gemdir = ./.; # Points to Gemfile.lock and gemset.nix
          gemConfig = pkgs.defaultGemConfig // {
            tailwindcss-rails = attrs:
                  if pkgs.stdenv.isLinux then rec {
                    # Append the OS-specific version suffix
                    version = attrs.version + "-x86_64-linux";
                    # Update the SHA256 accordingly
                    source = attrs.source // { sha256 = "sha256-asBSNQbLEi4+JrsHwvbhUFQlMNDRPYpOhGbtemn7/OI="; };
  #                  nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
                  } else attrs;
            nokogiri = attrs:
                if pkgs.stdenv.isLinux then rec {
                  # Append the OS-specific version suffix
                  version = attrs.version + "-x86_64-linux";
                  # Update the SHA256 accordingly
                  source = attrs.source // { sha256 = "sha256-nh5ChkHVlCr4d8YLQYxxFjVg6f60pcQBXzIwqLhqQPY="; };
                } else attrs;
            sqlite3 = attrs:
                if pkgs.stdenv.isLinux then rec {
                  # Append the OS-specific version suffix
                  version = attrs.version + "-x86_64-linux-gnu";
                  # Update the SHA256 accordingly
                  source = attrs.source // { sha256 = "sha256-PQUDKnhvxWKZrNdD7iJnFcykmkrNIVmrjh665T8k+y0="; };
                } else attrs;
            ffi = attrs:
                if pkgs.stdenv.isLinux then rec {
                  # Append the OS-specific version suffix
                  version = attrs.version + "-x86_64-linux-gnu";
                  # Update the SHA256 accordingly
                  source = attrs.source // { sha256 = "sha256-EBXlnVkZ3Wu8sHBDJbC9Y5vmZKebHiGJlDzrGPqjQZg="; };
                } else attrs;
            };
          extraConfigPaths = [ "${./.}/.ruby-version" ];

        };
        updateDeps = pkgs.writeScriptBin "update-deps" (builtins.readFile
          (pkgs.substituteAll {
            src = ./scripts/update.sh;
            bundix = "${pkgs.bundix}/bin/bundix";
            bundler = "${rubyEnv.bundler}/bin/bundler";
          }));
      in
      {
        apps.default = {
          type = "app";
          program = "${rubyEnv}/bin/rails";
        };

        devShells = rec {
          default = run;

          run = pkgs.mkShell {
            buildInputs = [ rubyEnv rubyEnv.wrappedRuby updateDeps pkgs.tailwindcss pkgs.redis pkgs.graphviz pkgs.google-chrome ];

            shellHook = ''
              ${rubyEnv}/bin/rails --version
              export TAILWINDCSS_INSTALL_DIR=${pkgs.tailwindcss}/bin
            '';
          };
        };

        packages = {
          default = rubyEnv;

          docker = pkgs.dockerTools.buildImage {
            name = "rails-app";
            tag = "latest";
            fromImage = pkgs.dockerTools.pullImage {
              imageName = "ubuntu";
              finalImageTag = "20.04";
              imageDigest = "sha256:a06ae92523384c2cd182dcfe7f8b2bf09075062e937d5653d7d0db0375ad2221";
              sha256 = "sha256-d249m1ZqcV72jfEcHDUn+KuOCs8WPaBJRcZotJjVW0o=";
            };
            config.Cmd = [ "${rubyEnv}/bin/bundler" ];
          };
        };
      });
}
