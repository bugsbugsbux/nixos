{
    description = "my nixos config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    };

    outputs = inputs@{ self, nixpkgs, ... }: let

        # Note: A variable `system` should only be used in the argument
        # to `forMySystemsAsAttr` but otherwise be specified explicitly
        # (for example in `sepcialArgs` to a `nixosConfigurations`).

        # Like nixpkgs.lib.forEach but returns result as attr-set with `each` as key.
        # Note, that identical elements in `each` overwrite each other.
        forEachAsAttr = each: fn: builtins.foldl' (pre: e: pre // e) {} (map (e: { ${e} = (fn e); }) each);
        # wrapper of forEachAsAttr with mySystems as elements to map over
        forMySystemsAsAttr = forEachAsAttr mySystems;

        mySystems = [
            "aarch64-darwin"
            "aarch64-linux"
            "x86_64-darwin"
            "x86_64-linux"
        ];

    in {

        packages = forMySystemsAsAttr (system: {
            monego-font = nixpkgs.legacyPackages.${system}.callPackage ./monego-font {};
        });

        nixosConfigurations = {
            tpe14gen3 = nixpkgs.lib.nixosSystem {
                specialArgs = {
                    monego-font = self.packages.x86_64-linux.monego-font;
                };
                modules = [ ./configs/tpe14gen3/configuration.nix ];
            };
        };

    };
}
