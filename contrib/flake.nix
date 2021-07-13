{
  description = "Neovim flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlay = final: prev:
        let
          pkgs = nixpkgs.legacyPackages.${prev.system};

          # defaults to false in nixpkgs
          doCheck = false;
        in
        rec {
          neovim = pkgs.neovim-unwrapped.overrideAttrs (oa: {
            version = "master";
            src = ../.;

            inherit doCheck;
          });

          # a development binary to help debug issues
          neovim-debug = let
            stdenv = pkgs.stdenvAdapters.keepDebugInfo (if pkgs.stdenv.isLinux then pkgs.llvmPackages_latest.stdenv else pkgs.stdenv);
          in
            pkgs.enableDebugging ((neovim.override {
            lua = pkgs.enableDebugging pkgs.luajit;
            inherit stdenv;
          }).overrideAttrs (oa: {
            cmakeBuildType = "Debug";
            cmakeFlags = oa.cmakeFlags ++ [
              "-DMIN_LOG_LEVEL=0"
            ];

            disallowedReferences = [];
          }));

          # for neovim developers, beware of the slow binary
          neovim-developer =
            let
              lib = nixpkgs.lib;
              luacheck = pkgs.luaPackages.luacheck;
            in
            (neovim-debug.override ({ doCheck = pkgs.stdenv.isLinux; })).overrideAttrs (oa: {
              cmakeFlags = oa.cmakeFlags ++ [
                "-DLUACHECK_PRG=${luacheck}/bin/luacheck"
                "-DMIN_LOG_LEVEL=0"
                "-DENABLE_LTO=OFF"
              ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
                # https://github.com/google/sanitizers/wiki/AddressSanitizerFlags
                # https://clang.llvm.org/docs/AddressSanitizer.html#symbolizing-the-reports
                "-DCLANG_ASAN_UBSAN=ON"
              ];
            });
        };
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          overlays = [ self.overlay ];
          inherit system;
        };

        # TODO retreive the one from the package instead
        neovimLuaEnv = pkgs.lua.withPackages(ps:
          (with ps; [ lpeg luabitop mpack # nvim-client luv coxpcall
            nvim-client luv coxpcall busted luafilesystem penlight inspect
            ]
          ));

        pythonEnv = pkgs.python3.withPackages(ps: [
          ps.msgpack
          ps.flake8  # for 'make pylint'
        ]);
      in
      rec {

        packages = with pkgs; {
          inherit neovim neovim-debug neovim-developer;
        };

        checks = {
          pylint = pkgs.runCommandNoCC "pylint" {
            nativeBuildInputs = [ pythonEnv ];
            preferLocalBuild = true;
            } "make -C ${./..} pylint > $out";

          shlint = pkgs.runCommandNoCC "shlint" {
            nativeBuildInputs = [ pkgs.shellcheck ];
            preferLocalBuild = true;
            } "make -C ${./..} shlint > $out";

          # not very efficient since it would rebuild all of neovim everytime
          oldtests = pkgs.runCommandNoCC "oldtests" {
            nativeBuildInputs = [ pkgs.neovim-debug ];
            preferLocalBuild = true;
          } ''
            export TMPDIR=$out
            mkdir $out
            cd $out
            # it tries to write a .gdbinit for some reason
            make -C ${./..}/src/nvim/testdir NVIM_PRG="${pkgs.neovim-debug}/bin/nvim"
          '';

          # this is available only in build Makefile since it checks for 
          # look into cmake/RunTests.cmake
          # I think we can remove --lpath=build/?.lua
          # we can have unit tests as well
          functionaltests = pkgs.runCommandNoCC "functionaltests" {
            nativeBuildInputs = [ pkgs.neovim-debug ];
            preferLocalBuild = true;
                        # export LUA_PATH="${./..}/?.lua;$LUA_PATH"

          } ''
            BUSTED_OUTPUT_TYPE="nvim"
            cd ${./..}
            echo "PWD: $PWD"
            echo "vs \$out: $out"
            echo "luaEnv: ${neovimLuaEnv}"
            set -x
            export LUA_PATH="${./..}/?.lua;$LUA_PATH"
            export NVIM_PRG=${pkgs.neovim}/bin/nvim
          ${neovimLuaEnv}/bin/busted -v -o test.busted.outputHandlers.$BUSTED_OUTPUT_TYPE \
            --lazy --helper=test/functional/preload.lua \
            --lpath=build/?.lua \
            --lpath=runtime/lua/?.lua \
            --lpath=?.lua
            touch $out
          '';
    # ${BUSTED_ARGS}
    # ${TEST_PATH}
          #     COMMAND ${CMAKE_COMMAND}
          #       -DBUSTED_PRG=${BUSTED_PRG}
          #       -DLUA_PRG=${LUA_PRG}
          #       -DNVIM_PRG=$<TARGET_FILE:nvim>
          #       -DWORKING_DIR=${CMAKE_CURRENT_SOURCE_DIR}
          #       -DBUSTED_OUTPUT_TYPE=${BUSTED_OUTPUT_TYPE}
          #       -DTEST_DIR=${CMAKE_CURRENT_SOURCE_DIR}/test
          #       -DBUILD_DIR=${CMAKE_BINARY_DIR}
          #       -DTEST_TYPE=functional
          #       -P ${PROJECT_SOURCE_DIR}/cmake/RunTests.cmake
          # '';
        };

        defaultPackage = pkgs.neovim;

        apps = {
          nvim = flake-utils.lib.mkApp { drv = pkgs.neovim; name = "nvim"; };
          nvim-debug = flake-utils.lib.mkApp { drv = pkgs.neovim-debug; name = "nvim"; };
        };

        defaultApp = apps.nvim;

        devShell = let
          in
            pkgs.neovim-developer.overrideAttrs(oa: {

              buildInputs = with pkgs; oa.buildInputs ++ [
                cmake
                pythonEnv
                include-what-you-use # for scripts/check-includes.py
                jq # jq for scripts/vim-patch.sh -r
                shellcheck # for `make shlint`
                doxygen    # for script/gen_vimdoc.py
                clang-tools # for clangd to find the correct headers
              ];

              shellHook = oa.shellHook + ''
                export NVIM_PYTHON_LOG_LEVEL=DEBUG
                export NVIM_LOG_FILE=/tmp/nvim.log

                # ASAN_OPTIONS=detect_leaks=1
                export ASAN_OPTIONS="log_path=./test.log:abort_on_error=1"
                export UBSAN_OPTIONS=print_stacktrace=1
                mkdir -p build/runtime/parser
                # nvim looks into CMAKE_INSTALL_DIR. Hack to avoid errors
                # when running the functionaltests
                mkdir -p outputs/out/share/nvim/syntax
                touch outputs/out/share/nvim/syntax/syntax.vim
              '';
            });
    });
}
