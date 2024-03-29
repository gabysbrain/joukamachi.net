{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  postgresql,
}:
# orig from: https://github.com/KenMacD/etc-nixos/blob/main/pkgs/pgvecto-rs.nix
let
  versionHashes = {
    "14" = "sha256-8YRC1Cd9i0BGUJwLmUoPVshdD4nN66VV3p48ziy3ZbA=";
    "15" = "sha256-uPE76ofzAevJMHSjFHYJQWUh5NZotaD9dhaX84uDFiQ=";
    "16" = "sha256-L+57VRFv4rIEjvqExFvU5C9XI7l0zWj9pkKvNE5DP+k=";
  };
  major = lib.versions.major postgresql.version;
in
  stdenv.mkDerivation rec {
    pname = "pgvecto-rs";
    version = "0.2.0";

    nativeBuildInputs = [dpkg];

    src = fetchurl {
      url = "https://github.com/tensorchord/pgvecto.rs/releases/download/v${version}/vectors-pg${major}_${version}_amd64.deb";
      hash = versionHashes."${major}";
    };

    unpackCmd = "dpkg -x $src source";

    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      install -D -t $out/lib usr/lib/postgresql/${major}/lib/*.so
      install -D -t $out/share/postgresql/extension usr/share/postgresql/${major}/extension/*.sql
      install -D -t $out/share/postgresql/extension usr/share/postgresql/${major}/extension/*.control
    '';

    meta = with lib; {
      description = "Scalable Vector database plugin for Postgres, written in Rust, specifically designed for LLM";
      homepage = "https://github.com/tensorchord/pgvecto.rs";
      license = licenses.asl20;
      maintainers = with maintainers; [];
    };
  }
