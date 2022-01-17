{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "andrejus";
  home.homeDirectory = "/home/andrejus";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  news.display = "silent";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    bat # cat rewrite in Rust
    direnv
    exa # ls rewrite in Rust
    fd # find rewrite in Rust
    fzf # Fuzzy finder
    fish
    httpie
    lorri # Easy Nix shell
    niv # Nix dependency management
    ripgrep # grep rewrite in Rust
    sd # Fancy sed
    skim # High-powered fuzzy finder written in Rust
    tokei # Handy tool to see lines of code by language
  ];
}
