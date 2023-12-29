{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kubeCluster = {
      url = "git+file:///Users/momme/src/nix-ha-kubernetes-cluster";
      # url = "github:supermomme/nix-ha-kubernetes-cluster";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # devShell currently dirty :/
      # host is aarch64-darwin, utm is aarch64-linux
      # maybe flake-utils eachDefaultSystem could be used here
      devShells.aarch64-darwin.default = let
        pkgs = nixpkgs.legacyPackages."aarch64-darwin";
        build = flake: ssh: buildSystem: pkgs.writeShellScriptBin "build-${flake}" ''
          ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --fast --use-remote-sudo --flake .#${flake} --target-host ${ssh} --build-host ${ssh}
        '';
      in pkgs.mkShell {
        buildInputs = [
          (pkgs.writeShellScriptBin "make-certs" ''
            $(nix-build --no-out-link scripts/certs)/bin/generate-certs
          '')
          (build "utm-nixos1" "momme@10.211.55.9" "aarch64-linux")
          (build "utm-nixos2" "momme@10.211.55.10" "aarch64-linux")
          (build "utm-nixos3" "momme@10.211.55.11" "aarch64-linux")
          # this could maybe combined with kube-resources.nix?
        ];
        packages = [
          pkgs.nixos-rebuild
        ];
      };

      nixosConfigurations = {
        # nix develop --command build-utm-nixos1
        utm-nixos1 = nixpkgs.lib.nixosSystem {
          system = "${system}";
          specialArgs = {inherit inputs;};
          modules = [ 
            ./hosts/utm-nixos1/configuration.nix
            ./common/common.nix
            ./common/sops.nix
            ./common/users.nix
            ./common/openssh.nix
            ./common/tailscale.nix
            ./common/firewall.nix
            inputs.kubeCluster.nixosModules.${system}.default
          ];
        };

        # nix develop --command build-utm-nixos2
        utm-nixos2 = nixpkgs.lib.nixosSystem {
          system = "${system}";
          specialArgs = {inherit inputs;};
          modules = [ 
            ./hosts/utm-nixos2/configuration.nix
            ./common/common.nix
            ./common/sops.nix
            ./common/users.nix
            ./common/openssh.nix
            ./common/tailscale.nix
            ./common/firewall.nix
            inputs.kubeCluster.nixosModules.${system}.default
          ];
        };

        # nix develop --command build-utm-nixos3
        utm-nixos3 = nixpkgs.lib.nixosSystem {
          system = "${system}";
          specialArgs = {inherit inputs;};
          modules = [ 
            ./hosts/utm-nixos3/configuration.nix
            ./common/common.nix
            ./common/sops.nix
            ./common/users.nix
            ./common/openssh.nix
            ./common/tailscale.nix
            ./common/firewall.nix
            inputs.kubeCluster.nixosModules.${system}.default
          ];
        };
      };
    };
}
