{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.web = {
    config,
    pkgs,
    lib,
    ...
  }: let
    sites = [
      "github.com"
      "youtube.com"
      "chatgpt.com"
      "z.ai"
      "craftinginterpreters.com"
    ];

    tlds = [".com" ".org" ".net" ".tv" ".io" ".dev" ".app"];

    stripTld = site: lib.foldl (s: tld: lib.removeSuffix tld s) site tlds;

    mkWebApp = site:
      pkgs.makeDesktopItem {
        name = "web-${stripTld site}";
        desktopName = stripTld site;
        exec = "${lib.getExe pkgs.librewolf} --new-window https://${site}";
        icon = "librewolf";
        categories = ["Network"];
      };
  in {
    environment.systemPackages = map mkWebApp sites ++ [
        pkgs.spotify
      ];

    

    
  };
}
