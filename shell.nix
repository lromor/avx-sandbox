{ pkgs ? import <nixpkgs> { } }:
let
  llvm = pkgs.llvmPackages_19;
  packages = with pkgs; [
    pkg-config
    (llvm.clang-tools.override {
      # Annoying situation with nvcc defining in a broken way noinline
      # which then breaks libstdc++. Use libc++ so we don't get that error.
      enableLibcxx = true;
    })
    llvm.clang-tools
    llvm.clang
    cudaPackages.cudatoolkit
    bear
    gdb
    mkl
    linuxPackages.perf
    valgrind
  ];
in with pkgs; (mkShell.override { stdenv = stdenv; }) {
  packages = packages;
  stdenv = stdenv;
  CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
  #CPATH = lib.makeSearchPathOutput "dev" "include" packages;
}
