{ pkgs ? import <nixpkgs> { } }:
let
  packages = with pkgs; [
    pkg-config
    gcc13
    llvmPackages_19.clang-tools
    bear
    gdb
    mkl
    linuxPackages.perf
    valgrind
    cudaPackages.cuda_nvprof
    cudaPackages.cuda_gdb
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart
  ];
in with pkgs; pkgs.mkShell{
  packages = packages;
  CPATH = lib.makeSearchPathOutput "dev" "include" packages;
}
