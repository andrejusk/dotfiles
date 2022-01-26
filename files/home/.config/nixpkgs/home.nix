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
        cmatrix
        cowsay
        direnv
        exa # ls rewrite in Rust
        fd # find rewrite in Rust
        fish
        fortune
        fzf # Fuzzy finder
        httpie
        lorri # Easy Nix shell
        niv # Nix dependency management
        ripgrep # grep rewrite in Rust
        sd # Fancy sed
        tokei # Handy tool to see lines of code by language
    ];

    programs.fish = {
        enable = true;

        plugins = [{
            name="hydro";
            src = pkgs.fetchFromGitHub {
                owner = "jorgebucaran";
                repo = "hydro";
                rev = "74cf14b8d9c29e21c68cd293fa761abe1ad6afe2";
                sha256 = "1kwbaj2kd0si73l076jgb48xqafchihzhqmlalvariqy5y4784wx";
            };
        }{
            name="replay";
            src = pkgs.fetchFromGitHub {
                owner = "jorgebucaran";
                repo = "replay.fish";
                rev = "07f2bcea94391946cab747199dd5597366532dda";
                sha256 = "1aa3a7jdb8a9z9jd9ckf449zmf7cl7yl47yp94srqj4iv1amizs3";
            };
        }{
            name="fzf";
            src = pkgs.fetchFromGitHub {
                owner = "PatrickF1";
                repo = "fzf.fish";
                rev = "0dc2795255d6ac0759e6f1d572f64ea0768acefb";
                sha256 = "0k8g9fliwxxvzcbh90v2k230p23g48kwsicd4z1cg69y4l60bqdg";
            };
        }];

        shellAliases = {
            la = "exa -la";
            cat = "batcat";
            which = "command -v $argv";
        };

        shellInit =
        ''
            set --global hydro_symbol_prompt "λ"
            set --global hydro_symbol_git_dirty "~"
            set --global hydro_fetch false
        '';

        interactiveShellInit =
        ''
            set fish_greeting
            pyenv init - | source
        '';
    };
    programs.autojump = {
        enable = true;
        enableFishIntegration = true;
    };

}
