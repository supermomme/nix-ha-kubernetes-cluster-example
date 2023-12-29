{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "utm-nixos1"; # Define your hostname.

  kubeCluster = {
    enable = true;
    cluster = (import ../../kube-resources.nix).clusterNodes;
  };

  environment.systemPackages = with pkgs; [
    wget
    nano
  ];

  system.stateVersion = "23.11"; # Never ever change this!
}

