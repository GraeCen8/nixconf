{ self, inputs, ... }: {
  flake.nixosConfigurations.example = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.exmapleConfig
    ];
  };
}
