{ self, inputs, ... }: {
  flake.nixosModules.fuzzel = { pkgs, lib, config, ... }:
  let
    themes = import ../../themes-data.nix;
    theme = themes.${config.system.theme.name};
    c = theme.colors;
    ui = config.system.theme.uiScale;

    toPx = v: toString (builtins.floor (v * ui + 0.5));

    # Base values (at uiScale 1.0, monitor scale 1.0).
    # fuzzel window height =
    #   2*border + 2*vertical-pad + inner-pad + (1 + lines) * line-height
    # fuzzel window width  =
    #   2*border + 2*horizontal-pad + width * advance
    base = {
      fontSize = 14;
      lineHeight = 21;
      padV = 12;
      padH = 14;
      innerPad = 4;
      borderWidth = 2;
      borderRadius = 10;
    };

    # 'W' advance for JetBrainsMono Nerd Font: 600/1000 em. At dpi-aware=no a
    # pt-size font renders at pt * 96/72 = pt * 4/3 px, so a char is
    # 0.6 * 4/3 = 0.8 px wide per point of configured font size.
    advancePerPt = 0.6 * 4.0 / 3.0;
    advancePerPtStr = builtins.toString advancePerPt;

    # Screen height (logical px) at uiScale 1.0, assumed 16:9 for the static
    # fallback config. The runtime wrapper uses the actual monitor height.
    referenceHeight = 1080;

    staticLines = let
      target = config.programs.fuzzel.heightFraction * referenceHeight * ui;
      overhead =
        2 * base.borderWidth * ui
        + 2 * base.padV * ui
        + base.innerPad * ui
        + base.lineHeight * ui;
      n = (target - overhead) / (base.lineHeight * ui);
    in toString (lib.max 1 (builtins.floor n));

    staticChars = let
      target = config.programs.fuzzel.widthFraction * referenceWidthInt * ui;
      overhead = 2 * base.borderWidth * ui + 2 * base.padH * ui;
      advance = advancePerPt * base.fontSize * ui;
    in toString (lib.max 1 (builtins.floor ((target - overhead) / advance)));

    fuzzelConfig = pkgs.writeText "fuzzel.ini" ''
      [main]
      font = ${themes.font.family}:size=${toPx base.fontSize}
      prompt = "run: "
      terminal = alacritty
      lines = ${staticLines}
      width = ${staticChars}
      horizontal-pad = ${toPx base.padH}
      vertical-pad = ${toPx base.padV}
      inner-pad = ${toPx base.innerPad}
      line-height = ${toPx base.lineHeight}px
      dpi-aware = no
      icons-enabled = yes
      icon-theme = Papirus-Dark

      [border]
      width = ${toPx base.borderWidth}
      radius = ${toPx base.borderRadius}

      [colors]
      background = ${lib.removePrefix "#" c.bg}dd
      text = ${lib.removePrefix "#" c.fg}ff
      prompt = ${lib.removePrefix "#" c.border-active}ff
      input = ${lib.removePrefix "#" c.fg}ff
      match = ${lib.removePrefix "#" c.accent}ff
      selection = ${lib.removePrefix "#" c.bg-alt}ff
      selection-text = ${lib.removePrefix "#" c.fg}ff
      border = ${lib.removePrefix "#" c.border-active}ff
    '';

    fontFamily = themes.font.family;
    referenceWidthInt = config.programs.fuzzel.referenceWidth;
    referenceWidth = builtins.toString referenceWidthInt;
    heightFraction = builtins.toJSON config.programs.fuzzel.heightFraction;
    widthFraction = builtins.toJSON config.programs.fuzzel.widthFraction;
    fs = toString base.fontSize;
    lh = toString base.lineHeight;
    pv = toString base.padV;
    ph = toString base.padH;
    ip = toString base.innerPad;
    bw = toString base.borderWidth;
    br = toString base.borderRadius;

    myFuzzel = pkgs.writeShellScriptBin "fuzzel" ''
      set -u

      REFERENCE=${referenceWidth}
      HEIGHT_FRACTION=${heightFraction}
      WIDTH_FRACTION=${widthFraction}
      ADVANCE_PER_PT=${advancePerPtStr}
      BASE_CONF=${fuzzelConfig}
      OUT_DIR="''${XDG_RUNTIME_DIR:-/tmp}"
      GEN_CONF="$OUT_DIR/fuzzel.ini"

      "${pkgs.coreutils}/bin/mkdir" -p "$OUT_DIR"

      outputs="$("${pkgs.niri}/bin/niri" msg --json outputs 2>/dev/null || true)"
      if [ -z "$outputs" ]; then
        exec "${pkgs.fuzzel}/bin/fuzzel" "$@"
      fi

      primary="$(printf '%s' "$outputs" | "${pkgs.jq}/bin/jq" -r 'keys[0]' 2>/dev/null || true)"
      primary_w="$(printf '%s' "$outputs" | "${pkgs.jq}/bin/jq" -r --arg o "$primary" '.[$o].logical.width' 2>/dev/null || true)"
      primary_h="$(printf '%s' "$outputs" | "${pkgs.jq}/bin/jq" -r --arg o "$primary" '.[$o].logical.height' 2>/dev/null || true)"

      if [ -z "$primary_w" ] || [ "$primary_w" = "null" ] || [ -z "$primary_h" ] || [ "$primary_h" = "null" ]; then
        exec "${pkgs.fuzzel}/bin/fuzzel" "$@"
      fi

      if [ "$(awk -v h="$primary_h" 'BEGIN { print ((h+0) > 0 ? 0 : 1) }')" = "1" ]; then
        exec "${pkgs.fuzzel}/bin/fuzzel" "$@"
      fi

      ui_scale="$(awk -v w="$primary_w" -v r="$REFERENCE" 'BEGIN { printf "%.3f", w / r }')"
      font_size="$(awk -v s="$ui_scale" 'BEGIN { printf "%.0f", ${fs} * s }')"
      line_height="$(awk -v s="$ui_scale" 'BEGIN { printf "%.0f", ${lh} * s }')"
      pad_v="$(awk -v s="$ui_scale" 'BEGIN { printf "%.0f", ${pv} * s }')"
      pad_h="$(awk -v s="$ui_scale" 'BEGIN { printf "%.0f", ${ph} * s }')"
      inner_pad="$(awk -v s="$ui_scale" 'BEGIN { printf "%.0f", ${ip} * s }')"
      border="$(awk -v s="$ui_scale" 'BEGIN { printf "%.0f", ${bw} * s }')"
      radius="$(awk -v s="$ui_scale" 'BEGIN { printf "%.0f", ${br} * s }')"
      target_h="$(awk -v h="$primary_h" -v f="$HEIGHT_FRACTION" 'BEGIN { printf "%.0f", h * f }')"
      lines="$(awk -v t="$target_h" -v b="$border" -v p="$pad_v" -v i="$inner_pad" -v lh="$line_height" '
        BEGIN {
          n = (t - 2*b - 2*p - i - lh) / lh;
          if (n < 1) n = 1;
          printf "%.0f", n
        }')"

      target_w="$(awk -v w="$primary_w" -v f="$WIDTH_FRACTION" 'BEGIN { printf "%.0f", w * f }')"
      chars="$(awk -v t="$target_w" -v b="$border" -v h="$pad_h" -v a="$ADVANCE_PER_PT" -v f="$font_size" '
        BEGIN {
          n = (t - 2*b - 2*h) / (a * f);
          if (n < 1) n = 1;
          printf "%.0f", n
        }')"

      cat > "$GEN_CONF" <<EOF
      [main]
      include=$BASE_CONF

      [main]
      font = ${fontFamily}:size=$font_size
      lines = $lines
      width = $chars
      horizontal-pad = $pad_h
      vertical-pad = $pad_v
      inner-pad = $inner_pad
      line-height = ''${line_height}px

      [border]
      width = $border
      radius = $radius
      EOF

      exec "${pkgs.fuzzel}/bin/fuzzel" --config "$GEN_CONF" "$@"
    '';
  in {
    options.programs.fuzzel = {
      referenceWidth = lib.mkOption {
        type = lib.types.int;
        default = 1920;
        description = "Logical width at which the UI scale is 1.0";
      };

      heightFraction = lib.mkOption {
        type = lib.types.number;
        default = 0.6;
        description = "Fraction of the primary monitor height the launcher occupies when open";
      };

      widthFraction = lib.mkOption {
        type = lib.types.number;
        default = 0.2;
        description = "Fraction of the primary monitor width the launcher occupies when open";
      };

      wrapper = lib.mkOption {
        type = lib.types.package;
        description = "Runtime-adaptive fuzzel wrapper that scales per monitor";
      };
    };

    config = {
      programs.fuzzel.wrapper = myFuzzel;

      environment.systemPackages = [ myFuzzel ];
      environment.etc."xdg/fuzzel/fuzzel.ini".source = fuzzelConfig;
    };
  };
}
