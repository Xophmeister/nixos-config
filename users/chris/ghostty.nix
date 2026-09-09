# The terminal. Its configuration used to be a hand-edited file in
# ~/.config/ghostty, which is how it came to be the thing the editor's
# appearance depends on without the configuration knowing about it.
{ unstable, ... }:

{
  programs.ghostty = {
    enable = true;
    package = unstable.ghostty;

    # Only the configuration file is wanted here. The module would also
    # install a systemd user unit for Ghostty, which this machine has never
    # had and does not need to launch it from GNOME.
    systemd.enable = false;

    # The Vim syntax for this file format is available as
    # programs.ghostty.installVimSyntax, but that option feeds
    # programs.vim.plugins and chris edits in Neovim. Adding
    # `unstable.ghostty.vim` to the plugin list in neovim.nix would be the
    # equivalent, if it is ever wanted.

    settings = {
      theme = "iTerm2 Solarized Dark";
      fullscreen = true;
      window-decoration = false;
      resize-overlay = "never";

      # Powerline glyphs in the statusline need the patched variant; the
      # font itself comes from fonts.packages in configuration.nix.
      font-family = "Source Code Pro for Powerline";
      font-size = 14;

      # Neovim drives the cursor itself while it runs, and is configured to
      # keep this blink rather than override it -- see nvim/init.lua.
      cursor-style = "block";
      cursor-style-blink = true;

      # Ghostty's shell integration would otherwise take over the cursor too.
      shell-integration-features = "no-cursor";

      mouse-hide-while-typing = true;
      link-url = true;
      copy-on-select = true;

      # Rendered as one `keybind = ...` line each.
      keybind = [
        "global:f11=toggle_fullscreen"
        "global:f12=toggle_tab_overview"

        # Splits. Ctrl+Arrow moves between them, Ctrl+Shift+Arrow makes one.
        "ctrl+space=equalize_splits"
        "ctrl+up=goto_split:up"
        "ctrl+down=goto_split:down"
        "ctrl+left=goto_split:left"
        "ctrl+right=goto_split:right"
        "ctrl+shift+up=new_split:up"
        "ctrl+shift+down=new_split:down"
        "ctrl+shift+left=new_split:left"
        "ctrl+shift+right=new_split:right"

        # Tabs. Alt+Left/Right moves, Alt+Shift+Right makes one.
        "alt+left=previous_tab"
        "alt+right=next_tab"
        "alt+shift+right=new_tab"

        # Prompts, via shell integration. Alt+Up/Down walks them.
        "alt+up=jump_to_prompt:-1"
        "alt+down=jump_to_prompt:1"

        # A literal backslash-n reaches Ghostty, which expands it to a
        # newline: this sends one without submitting the line.
        "shift+enter=text:\\n"
      ];
    };
  };
}
