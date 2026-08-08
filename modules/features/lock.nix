{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.lock = {
    pkgs,
    config,
    ...
  }: let
    themes = import ../../themes-data.nix;
    theme = themes.${config.system.theme.name};
    c = theme.colors;

    swaylockConf = pkgs.writeText "swaylock-config" ''
      daemonize
      show-failed-attempts
      indicator-caps-lock

      effect-blur 7x5
      effect-vignette 0.5

      color=${c.bg}

      inside-color=${c.bg}
      inside-ver-color=${c.bg-alt}
      inside-wrong-color=${c.error}
      inside-clear-color=${c.bg-alt}

      ring-color=${c.border}
      ring-ver-color=${c.accent}
      ring-wrong-color=${c.error}
      ring-clear-color=${c.border-active}

      line-color=${c.bg}
      line-ver-color=${c.accent}
      line-wrong-color=${c.error}
      line-clear-color=${c.border-active}

      text-color=${c.fg}
      text-ver-color=${c.accent}
      text-wrong-color=${c.error}
      text-clear-color=${c.fg}

      key-hl-color=${c.accent}
      bs-hl-color=${c.error}

      font=${themes.font.family}
      font-size=14

      indicator-radius=80
      indicator-thickness=8

      separator-color=${c.border}
    '';

    lockScript = pkgs.writeShellScriptBin "lock-screen" ''
      tmp=$(mktemp -d)
      images=()

      outputs=$(${pkgs.gnused}/bin/sed -n 's/^\([^ ]\+\) ".*"/\1/p' < <(${pkgs.wlr-randr}/bin/wlr-randr 2>/dev/null) || true)
      if [ -n "$outputs" ]; then
        while IFS= read -r o; do
          [ -z "$o" ] && continue
          if ${pkgs.grim}/bin/grim -o "$o" "$tmp/$o.png" 2>/dev/null; then
            images+=(--image "$o:$tmp/$o.png")
          fi
        done <<< "$outputs"
      fi

      if [ "''${#images[@]}" -eq 0 ] && ${pkgs.grim}/bin/grim "$tmp/screen.png" 2>/dev/null; then
        images+=(--image "$tmp/screen.png")
      fi

      if [ "''${#images[@]}" -gt 0 ]; then
        ${pkgs.swaylock-effects}/bin/swaylock --config ${swaylockConf} "''${images[@]}"
        ( while ${pkgs.procps}/bin/pgrep -x swaylock >/dev/null 2>&1; do sleep 1; done; rm -rf "$tmp" ) &
      else
        rm -rf "$tmp"
        exec ${pkgs.swaylock-effects}/bin/swaylock --config ${swaylockConf}
      fi
    '';
  in {
    security.pam.services.swaylock = {};

    environment.systemPackages = [
      pkgs.swaylock-effects
      pkgs.wlr-randr
      lockScript
    ];

    systemd.services.lock-on-suspend = {
      enable = true;
      description = "Lock screen on suspend";
      before = ["sleep.target"];
      wantedBy = ["sleep.target"];
      environment = {
        WAYLAND_DISPLAY = "wayland-1";
        DISPLAY = ":0";
        XDG_RUNTIME_DIR = "/run/user/1000";
      };
      serviceConfig = {
        Type = "oneshot";
        User = config.user.name;
      };
      script = "${lockScript}/bin/lock-screen";
    };
  };
}
