{
    description = "my nixos config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    };

    outputs = inputs@{ self, nixpkgs, ... }: let

        # Note: A variable `system` should only be used in the argument
        # to `perSystem` but otherwise be specified explicitly
        # (for example in `sepcialArgs` to a `nixosConfigurations`).

        mySystems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
        # nixpkgs.lib.genAttrs systems (system: ...) => {systemA = ...; systemB = ...; ...}
        perSystem = nixpkgs.lib.genAttrs mySystems;

        # instantiate nixpkgs only once per system
        # usage: pkgsForSystem.${system}
        pkgsForSystem = perSystem (system:
            nixpkgs.legacyPackages.${system} # OR if needed: import nixpkgs { inherit system; config = { allowUnfree = true; ... }; }
        );

    in {

        packages = perSystem (system: {
            monego-font = pkgsForSystem.${system}.callPackage ./monego-font {};
        });

        nixosConfigurations = { # instantiates own instance from `nixpkgs` used to call lib.nixosSystem
            tpe14gen3 = nixpkgs.lib.nixosSystem {
                # system = already defined in hardware-configuration.nix
                specialArgs = {
                    monego-font = self.packages.x86_64-linux.monego-font;
                };
                modules = [ ./configs/tpe14gen3/configuration.nix ];
            };
        };

    };
}
