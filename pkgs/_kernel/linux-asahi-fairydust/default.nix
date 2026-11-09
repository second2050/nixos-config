{
  lib,
  callPackage,
  linuxPackagesFor,
  _kernelPatches ? [ ],
}:

let
  linux-asahi-pkg =
    {
      stdenv,
      lib,
      fetchFromGitHub,
      buildLinux,
      ...
    }:
    buildLinux rec {
      inherit stdenv lib;

      pname = "linux-asahi-fairydust";
      version = "7.2.15";
      modDirVersion = version;
      extraMeta.branch = lib.versions.majorMinor version;

      src = fetchFromGitHub {
        owner = "AsahiLinux";
        repo = "linux";
        rev = "432e09dca5d88e145eba6ff6080cd77aa5b8ccf8"; # branch = "fairydust"
        hash = "sha256-oB40IG6UgwgklAO8J09KY8/FPzF5nklvKvZe8A2/2Pg=";
      };

      kernelPatches = [
        {
          name = "Asahi config";
          patch = null;
          structuredExtraConfig = with lib.kernel; {
            # Needed for GPU
            ARM64_16K_PAGES = yes;

            ARM64_MEMORY_MODEL_CONTROL = yes;
            ARM64_ACTLR_STATE = yes;

            # Might lead to the machine rebooting if not loaded soon enough
            APPLE_WATCHDOG = yes;

            # Can not be built as a module, defaults to no
            APPLE_M1_CPU_PMU = yes;

            # Defaults to 'y', but we want to allow the user to set options in modprobe.d
            HID_APPLE = module;

            APPLE_PMGR_MISC = yes;
            APPLE_PMGR_PWRSTATE = yes;

            APPLE_MAILBOX = yes;
            APPLE_RTKIT = yes;
            APPLE_RTKIT_HELPER = yes;
            RUST_APPLE_RTKIT = yes;
            RUST_FW_LOADER_ABSTRACTIONS = yes;

            # Defaults to 'n', but needed to prevent bluetooth stuttering
            BT_BRCMEXT = yes;
          };
          features.rust = true;
        }
      ]
      ++ _kernelPatches;
    };

  linux-asahi = callPackage linux-asahi-pkg { };
in
lib.recurseIntoAttrs (linuxPackagesFor linux-asahi)
