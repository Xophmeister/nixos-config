# Claude Code dumps its configuration, etc. into ~/.claude like it's
# 2005. Also, I have multiple accounts and I don't want to have to
# remember to /login every time I need to switch. So this wrapper does
# two things:
# - Uses the XDG Base Directory Specification
# - Auto-switches accounts based on the current working directory

# Configuration directory (split by account)
declare CONFIG_BASE="${XDG_CONFIG_HOME:-$HOME/.config}"
[[ "${CONFIG_BASE}" == /* ]] || CONFIG_BASE="$HOME/.config"
declare CONFIG_DIR="${CONFIG_BASE}/claude-wrapper"

# State directory (for all temporary state)
declare STATE_BASE="${XDG_STATE_HOME:-$HOME/.local/state}"
[[ "${STATE_BASE}" == /* ]] || STATE_BASE="$HOME/.local/state"
declare STATE_DIR="${STATE_BASE}/claude-wrapper"

# Project directory (used to determine which account to use)
declare PROJECT_DIR
PROJECT_DIR="$(realpath -m "${HOME}/Projects")"

declare DEFAULT_ACCOUNT="_claude"

create_account() {
  local account="$1"

  mkdir -p "${CONFIG_DIR}/${account}" "${CONFIG_DIR}/${account}/anthropic"
  ln -sf "${CONFIG_DIR}/CLAUDE.md" "${CONFIG_DIR}/${account}/CLAUDE.md"

  echo "${CONFIG_DIR}/${account}"
}

account_map() {
  local dir tail project
  dir="$(realpath -m "$1")"

  if [[ "${dir}" == "${PROJECT_DIR}/"* ]]; then
    tail="${dir#"${PROJECT_DIR}"/}"
    project="${tail%%/*}"

    case "${project}" in
      "personal" | "play") printf "%s" "${DEFAULT_ACCOUNT}";;
      *)                   printf "%s" "${project}";;
    esac
  else
    printf "%s" "${DEFAULT_ACCOUNT}"
  fi
}

main() {
  local account account_dir

  mkdir -p "${CONFIG_DIR}" "${STATE_DIR}"

  account="$(account_map "$(pwd)")"
  account_dir="$(create_account "${account}")"

  export CLAUDE_CONFIG_DIR="${account_dir}"
  export ANTHROPIC_CONFIG_DIR="${account_dir}/anthropic"
  export CLAUDE_CODE_TMPDIR="${STATE_DIR}"

  exec claude "$@"
}

main "$@"
