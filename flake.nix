{
  description = "A flake for pythonification";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/master";

  outputs = { self, nixpkgs, ... }@inputs:
let
  system = "x86_64-linux";

  pkgs = import nixpkgs {
    inherit system;
  };

  pythonPackages = pkgs.python38Packages;

  venvDir = "./env";

  runPackages = with nixpkgs; [
      pythonPackages.python

      pythonPackages.venvShellHook
    ];

  devPackages = with nixpkgs; runPackages ++ [
      pythonPackages.pylint
      pythonPackages.flake8
      pythonPackages.black
  ];

  # This is to expose the venv in PYTHONPATH so that pylint can see venv packages
  postShellHook = ''
    PYTHONPATH=\$PWD/\${venvDir}/\${pythonPackages.python.sitePackages}/:\$PYTHONPATH
    # pip install -r requirements.txt
  '';

in {
  runShell = pkgs.mkShell {
    inherit venvDir;
    name = "pythonify-run";
    packages = runPackages;
    postShellHook = postShellHook;
  };
  developmentShell = pkgs.mkShell {
    inherit venvDir;
    name = "pythonify-dev";
    packages = devPackages;
    postShellHook = postShellHook;
  };
};
}
