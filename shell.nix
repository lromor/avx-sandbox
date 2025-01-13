{ pkgs ? import <nixpkgs> {} }:
let
in with pkgs; pkgs.mkShell{
  packages = [
    gcc
    gdb
    mkl
    linuxPackages.perf
    valgrind   
  ];
}
