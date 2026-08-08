{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.wlogout = {
    pkgs,
    lib,
    config,
    ...
  }: let
    themes = import ../../themes-data.nix;
    theme = themes.${config.system.theme.name};
    c = theme.colors;

    layout = pkgs.writeText "wlogout-layout" ''
      {
          "label" : "lock",
          "action" : "lock-screen",
          "text" : "Lock",
          "keybind" : "l"
      }
      {
          "label" : "suspend",
          "action" : "systemctl suspend",
          "text" : "Suspend",
          "keybind" : "u"
      }
      {
          "label" : "logout",
          "action" : "mmsg dispatch quit",
          "text" : "Logout",
          "keybind" : "e"
      }
      {
          "label" : "reboot",
          "action" : "systemctl reboot",
          "text" : "Reboot",
          "keybind" : "r"
      }
      {
          "label" : "shutdown",
          "action" : "systemctl poweroff",
          "text" : "Shutdown",
          "keybind" : "s"
      }
    '';

    style = pkgs.writeText "wlogout-style.css" ''
      * {
        background-image: none;
        box-shadow: none;
      }

      window {
        font-family: "${themes.font.family}";
        background-color: rgba(0, 0, 0, 0.4);
      }

      button {
        border-radius: 12px;
        border-color: ${c.border};
        color: ${c.fg};
        background-color: ${c.bg-alt};
        border-style: solid;
        border-width: 1px;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 30%;
        margin: 8px;
        font-size: 14px;
      }

      button:focus, button:active, button:hover {
        background-color: ${c.accent};
        color: ${c.bg};
        border-color: ${c.accent};
        outline-style: none;
      }

      #lock { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/lock.png")); }
      #suspend { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/suspend.png")); }
      #logout { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/logout.png")); }
      #reboot { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/reboot.png")); }
      #shutdown { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png")); }
    '';
  in {
    environment.systemPackages = [
      pkgs.wlogout
    ];

    environment.etc."wlogout/layout".source = layout;
    environment.etc."wlogout/style.css".source = style;
  };
}
