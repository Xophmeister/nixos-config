setopt extendedglob

# I don't like the right prompt
unset RPS1

# Toggle commented command line on double Escape
comment-command-line() {
  [[ -z "${BUFFER}" ]] && zle up-history
  if [[ "${BUFFER}" =~ ^#+ ]]; then
    LBUFFER="$(sed -E 's/^#+ *//' <<< "${LBUFFER}")"
  else
    LBUFFER="# ${BUFFER}"
  fi
}

zle -N comment-command-line
bindkey "\e\e" comment-command-line

# Automatic tmux session management
if [[ -z "${TMUX}" ]]; then
  sessions=$(tmux list-sessions -F "#{session_created},#S" 2>/dev/null)
  sessionCount="${#${(f)sessions}}"

  if (( sessionCount > 0 )); then
    now=$(date +%s)
    default=""

    echo -e "Attach to an existing session, or start a new one:\n"

    # List sessions in reverse chronological order
    echo "${sessions}" | sort -r | while IFS="," read created session; do
      age=$(bc <<< "obase=60;${now} - ${created}" | sed "s/^ //;s/ /:/g")
      echo -e "\t\x1b[1;31m$session\x1b[0m\tcreated ${age} ago"

      # Set default to latest
      if [[ -z "${default}" ]]; then
        default="${session}"
      fi
    done

    echo
    read "choice?Session [${default}] » "

    # Set to default if empty
    if [[ -z "${choice}" ]]; then
      choice="${default}"
    fi
  else
    # Default session
    choice=$(whoami)
  fi

  exec tmux -2 new-session -A -s "${choice}"
fi
