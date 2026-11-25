{ self, ... }:
{
  imports = [
    ./base
    # modules shared between nixos and darwin
    "${self}/modules/lix"
  ];
}
