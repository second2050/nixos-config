{
  pkgs,
  ...
}:
let
  inherit (pkgs)
    fetchurl
    ;
in
rec {
  currentWallpaper = wallpaper.karui-winter-2025-2026;
  currentAvatar = avatar.karui-winter-2025-2026;
  wallpaper = {
    exusiai-1 = fetchurl {
      url = "https://w.wallhaven.cc/full/je/wallhaven-je5x6q.jpg";
      hash = "sha256-vtTveKbU7afh/Sv9oEw/VY8GWyYCZN3erxk6Z6sNgHs=";
    };
    karui-winter-2025-2026 = fetchurl {
      url = "https://i.karui.moe/wallpaper/Winter_2025-2026.webp";
      hash = "sha256-X4f64vyJNPZr8fjJNHtWNk5kf5IVpDb953lsbk3hUSw=";
    };
  };
  avatar = {
    karui-winter-2025-2026 = fetchurl {
      url = "https://i.karui.moe/avatar/Winter_2025-2026.webp";
      hash = "sha256-wQmMuNbtcZTpn+4hEN1zF4SrtjC7yyi3mjuQZRGb6ts=";
    };
  };
}
