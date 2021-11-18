{ pkgs }:

{
  enable = true;

  keyMode = "vi";
  prefix = "C-a";  # screen muscle memory :P
  escapeTime = 1;
  terminal = "screen-256color";

  plugins = with pkgs.tmuxPlugins; [
    tmux-colors-solarized
  ];

  extraConfig = ''
    setw -g mouse on
    setw -g monitor-activity on

    set -g set-titles on
    set -g set-titles-string "#S:#I.#P@#H - #W"

    bind | split-window -h -c '#{pane_current_path}'  # Split horizontally
    bind - split-window -v -c '#{pane_current_path}'  # Split vertically
    bind h select-pane -L                             # Move to left pane
    bind j select-pane -D                             # Move to below pane
    bind k select-pane -U                             # Move to above pane
    bind l select-pane -R                             # Move to right pane
    bind -r C-h select-window -t :-                   # Move to previous window
    bind -r C-l select-window -t :+                   # Move to next window
    bind -r H resize-pane -L 5                        # Resize pane leftwards
    bind -r J resize-pane -D 5                        # Resize pane downwards
    bind -r K resize-pane -U 5                        # Resize pane upwards
    bind -r L resize-pane -R 5                        # Resize pane rightwards

    # TODO Copy and paste
    # TODO Wheel scroll

    # DIY Powerline :)
    set-option -g status on
    set-option -g status-interval 2
    set-option -g status-left-length 12
    set-option -g status-right-length 40
    set-option -g status-left "#[fg=colour234, bg=colour148] #S #[bg=colour235, fg=colour148]"
    set-option -g status-right "#[fg=colour234, bg=colour3] #(date +'%-l:%M%p') "
    set-window-option -g window-status-current-format "#[fg=colour235, bg=colour27]#[fg=colour255, bg=colour27] #I  #W #[fg=colour27, bg=colour235]"
  '';
}