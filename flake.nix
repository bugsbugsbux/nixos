{
    description = "my nixos config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = inputs@{ self, nixpkgs, flake-utils, ... }:

        # eachDefaultSystem trasforms returned dict like so: {a.b=c;} => {a.${system}.b = c;}
        flake-utils.lib.eachDefaultSystem (system: {

            # only evaluates once compared to: (import nixpkgs {inherit system;}).callPackage ...
            packages.monego-font = nixpkgs.legacyPackages.${system}.callPackage ./monego-font {};

        # eachDefaultSystemPassThrough only makes ${system} available
        }) // flake-utils.lib.eachDefaultSystemPassThrough (system: {

            nixosConfigurations.tpe14gen3 = inputs.nixpkgs.lib.nixosSystem {
                specialArgs = {
                    monego-font = self.packages.${system}.monego-font;
                };
                modules = [ ./configs/tpe14gen3/configuration.nix ];
            };

        })

    ;
}
