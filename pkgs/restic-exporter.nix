{ lib, restic, fetchFromGitHub, writeShellApplication, python3 }:

let 
  myPython = python3.withPackages (ps: with ps; [ prometheus-client ]);
  src = fetchFromGitHub {
    owner = "ngosang";
    repo = "restic-exporter";
    rev = "refs/tags/1.2.2";
    sha256 = "sha256-anSlNC5Ckj7NHBvXkYmGgFx+EKvSXZnBjFddpmnOb8E=";
  };
in
# this is theoretically a python applicaiton but there's no setup.py, 
# you're just supposed to run restic-exporter.py from a venv
writeShellApplication {
  name = "restic-exporter";

  runtimeInputs = [ restic myPython ];

  text = ''
    python ${src}/restic-exporter.py
  '';
}
