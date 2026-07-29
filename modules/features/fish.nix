# this contains the whole shell and any config to go with it
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.fish = {
    pkgs,
    config,
    ...
  }: {
    users.users.${config.user.name}.shell = pkgs.fish;

    programs.starship.enable = true;
    programs.zoxide.enable = true;

    programs.fish = {
      enable = true;

      shellAliases = {
        # File system
        ls = "eza -lh --group-directories-first --icons=auto";
        la = "eza -a --group-directories-first --icons=auto";
        lsa = "ls -a";
        lt = "eza --tree --level=2 --long --icons --git";
        lta = "lt -a";
        tree = "eza --tree --level=2 --long --icons --git";
        cat = "bat --paging=never";
        grep = "rg";
        find = "fd";

        # Directories
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";

        # Tools
        c = "opencode";
        cx = ''printf "\033[2J\033[3J\033[H" && claude --permission-mode bypassPermissions'';
        d = "docker";
        r = "rails";
        t = "tmux attach || tmux new -s Work";
        ic = "tdl c";
        ix = "tdl cx";
        icx = "tdl c cx";
        vim = "nvim";

        # Git
        g = "git";
        gst = "git status -sb";
        gl = "git log --oneline --graph --decorate --all";
        gco = "git switch";
        gsw = "git switch";
        gp = "git pull --rebase";
        gpush = "git push";
        gcm = "git commit -m";
        gcam = "git commit -a -m";
        gcad = "git commit -a --amend";
        lg = "lazygit";
      };

      interactiveShellInit = ''
        set -g fish_history_max 32768

        # Functions from dotfiles

        function nrs
          set hostname (string replace -r "^:" "#" -- $argv[1])
          bash -c "sudo nixos-rebuild switch --flake /home/grae/nixos$hostname |& nom"
        end

        function v
          set -l editor nvim
          if set -q EDITOR
            set editor $EDITOR
          end
          $editor $argv
        end

        function n
          if test (count $argv) -eq 0
            command nvim .
          else
            command nvim $argv
          end
        end

        function ff
          if test "$TERM" = alacritty && command -v alacritty >/dev/null
            fzf --preview 'file=$(file --mime-type -b {}); switch $file; case "image/*"; alacritty msg --help >/dev/null 2>&1 && echo "image preview not supported"; case "*"; bat --style=numbers --color=always {}; end'
          else
            fzf --preview 'bat --style=numbers --color=always {}'
          end
        end

        function eff
          set -l editor nvim
          if set -q EDITOR
            set editor $EDITOR
          end
          $editor (ff)
        end

        function sff
          if test (count $argv) -eq 0
            echo "Usage: sff <destination> (e.g. sff host:/tmp/)"
            return 1
          end
          set file (command find . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2- | ff)
          if test -n "$file"
            scp "$file" $argv[1]
          end
        end

        function zd
          if test (count $argv) -eq 0
            builtin cd ~; or return
          else if test -d $argv[1]
            builtin cd $argv[1]
          else
            if not z $argv[1]
              echo "Error: Directory not found"
              return 1
            end
            echo "󰅩"
            pwd
          end
        end

        function open
          xdg-open $argv >/dev/null 2>&1 &
        end

        function compress
          tar -czf "$argv[1]".tar.gz "$argv[1]"
        end

        function decompress
          tar -xzf $argv
        end

        function fip
          if test (count $argv) -lt 2
            echo "Usage: fip <host> <port1> [port2] ..."
            return 1
          end
          set host $argv[1]
          set ports $argv[2..-1]
          for port in $ports
            ssh -f -N -L "$port:localhost:$port" $host
            and echo "Forwarding localhost:$port -> $host:$port"
          end
        end

        function dip
          if test (count $argv) -eq 0
            echo "Usage: dip <port1> [port2] ..."
            return 1
          end
          for port in $argv
            pkill -f "ssh.*-L $port:localhost:$port"
            and echo "Stopped forwarding port $port"
            or echo "No forwarding on port $port"
          end
        end

        function lip
          set forwards (pgrep -af "ssh.*-L [0-9]+:localhost:[0-9]+")
          if test -n "$forwards"
            echo $forwards
          else
            echo "No active forwards"
          end
        end

        function iso2sd
          if test (count $argv) -lt 1
            echo "Usage: iso2sd <input_file> [output_device]"
            echo "Example: iso2sd ~/Downloads/ubuntu.iso /dev/sda"
            echo ""
            echo "Available drives:"
            lsblk -dpno NAME | grep -E '/dev/sd'; or true
            return 1
          end
          set iso $argv[1]
          set drive $argv[2]
          if test -z "$drive"
            set available (lsblk -dpno NAME | grep -E '/dev/sd')
            if test -z "$available"
              echo "No SD drives found and no drive specified"
              return 1
            end
            echo "Available drives: $available"
            read -p "echo 'Enter drive: '" drive
          end
          sudo dd bs=4M status=progress oflag=sync if=$iso of=$drive
          and sudo eject $drive
        end

        function format-drive
          if test (count $argv) -ne 2
            echo "Usage: format-drive <device> <name>"
            echo "Example: format-drive /dev/sda 'My Stuff'"
            echo ""
            echo "Available drives:"
            lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
            return 1
          end
          echo "WARNING: This will completely erase all data on $argv[1] and label it '$argv[2]'."
          read -p "echo 'Are you sure? (y/N) '" -l confirm
          if test "$confirm" = y -o "$confirm" = Y
            sudo wipefs -a $argv[1]
            sudo dd if=/dev/zero of=$argv[1] bs=1M count=100 status=progress
            sudo parted -s $argv[1] mklabel gpt
            sudo parted -s $argv[1] mkpart primary 1MiB 100%
            sudo parted -s $argv[1] set 1 msftdata on
            set partition "$argv[1]"
            if string match -q '*nvme*' $argv[1]
              set partition "$argv[1]p1"
            else
              set partition "$argv[1]1"
            end
            sudo partprobe $argv[1]; or true
            sudo udevadm settle; or true
            sudo mkfs.exfat -n $argv[2] $partition
            echo "Drive $argv[1] formatted as exFAT and labeled '$argv[2]'."
          end
        end

        function tdl
          if test (count $argv) -lt 1
            echo "Usage: tdl <c|cx|codex|other_ai> [<second_ai>]"
            return 1
          end
          if not set -q TMUX
            echo "You must start tmux to use tdl."
            return 1
          end
          set current_dir "$PWD"
          set ai $argv[1]
          set editor_pane $TMUX_PANE
          tmux rename-window -t $editor_pane (basename $current_dir)
          tmux split-window -v -p 15 -t $editor_pane -c $current_dir
          set ai_pane (tmux split-window -h -p 30 -t $editor_pane -c $current_dir -P -F '#{pane_id}')
          if test (count $argv) -ge 2
            set ai2 $argv[2]
            set ai2_pane (tmux split-window -v -t $ai_pane -c $current_dir -P -F '#{pane_id}')
            tmux send-keys -t $ai2_pane $ai2 C-m
          end
          tmux send-keys -t $ai_pane $ai C-m
          tmux send-keys -t $editor_pane "$EDITOR ." C-m
          tmux select-pane -t $editor_pane
        end

        function tdlm
          if test (count $argv) -lt 1
            echo "Usage: tdlm <c|cx|codex|other_ai> [<second_ai>]"
            return 1
          end
          if not set -q TMUX
            echo "You must start tmux to use tdlm."
            return 1
          end
          set ai $argv[1]
          set ai2 $argv[2..-1]
          set base_dir $PWD
          set first true
          tmux rename-session (basename $base_dir | tr '.:' '--')
          for dir in $base_dir/*/
            if not test -d $dir
              continue
            end
            set dirpath (string trim -r -c / $dir)
            if $first
              tmux send-keys -t $TMUX_PANE "cd '$dirpath' && tdl $ai $ai2" C-m
              set first false
            else
              set pane_id (tmux new-window -c $dirpath -P -F '#{pane_id}')
              tmux send-keys -t $pane_id "tdl $ai $ai2" C-m
            end
          end
        end

        function tsl
          if test (count $argv) -lt 2
            echo "Usage: tsl <pane_count> <command>"
            return 1
          end
          if not set -q TMUX
            echo "You must start tmux to use tsl."
            return 1
          end
          set count $argv[1]
          set cmd $argv[2]
          set current_dir $PWD
          set -a panes $TMUX_PANE
          tmux rename-window -t $TMUX_PANE (basename $current_dir)
          while test (count $panes) -lt $count
            set split_target $panes[-1]
            set new_pane (tmux split-window -h -t $split_target -c $current_dir -P -F '#{pane_id}')
            set -a panes $new_pane
            tmux select-layout -t $panes[1] tiled
          end
          for pane in $panes
            tmux send-keys -t $pane $cmd C-m
          end
          tmux select-pane -t $panes[1]
        end
      '';
    };

    environment.systemPackages = with pkgs; [
      bat
      eza
      fzf
      unzip
      btop
    ];
  };
}
