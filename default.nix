{ pkgs ? import <nixpkgs> {} }:

pkgs.callPackage ./delta-chat.nix {}
