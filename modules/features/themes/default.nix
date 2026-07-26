{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.themes = {
    config,
    pkgs,
    lib,
    ...
  }: let
    themes = import ./themes-data.nix;
    currentTheme = themes.${config.system.theme.name};
  in {
    options.system.theme = {
      name = lib.mkOption {
        type = lib.types.enum (builtins.attrNames themes);
        default = "nord";
        description = "System-wide color theme";
      };
    };

    config = {
      environment.variables.SYSTEM_THEME = config.system.theme.name;

      environment.systemPackages = let
        theme-switch = pkgs.writeShellScriptBin "theme-switch" ''
          #!/usr/bin/env bash
          THEMES=(${lib.concatStringsSep " " (builtins.attrNames themes)})
          STATE_FILE="/tmp/current-theme"
          CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "${config.system.theme.name}")

          get_index() {
            for i in "''${!THEMES[@]}"; do
              if [ "''${THEMES[$i]}" = "$1" ]; then
                echo "$i"
                return
              fi
            done
            echo "-1"
          }

          case "''${1:-}" in
            next)
              IDX=$(get_index "$CURRENT")
              NEW_IDX=$(( (IDX + 1) % ''${#THEMES[@]} ))
              NEW_THEME="''${THEMES[$NEW_IDX]}"
              ;;
            prev)
              IDX=$(get_index "$CURRENT")
              NEW_IDX=$(( (IDX - 1 + ''${#THEMES[@]}) % ''${#THEMES[@]} ))
              NEW_THEME="''${THEMES[$NEW_IDX]}"
              ;;
            "")
              echo "Usage: theme-switch [next|prev|${lib.concatStringsSep "|" (builtins.attrNames themes)}]"
              exit 1
              ;;
            *)
              if ! get_index "$1" > /dev/null; then
                echo "Unknown theme: $1"
                echo "Available themes: ''${THEMES[*]}"
                exit 1
              fi
              NEW_THEME="$1"
              ;;
          esac

          echo "$NEW_THEME" > "$STATE_FILE"
          echo "Switched to theme: $NEW_THEME"
          notify-send "Theme" "Switched to $NEW_THEME" 2>/dev/null || true
        '';
      in [
        theme-switch
      ];
    };
  };
}
