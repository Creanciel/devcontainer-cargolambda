#!/bin/bash
set -e

this_directory="$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)"
project_directory="$this_directory/../.."

_devcontainer_check_command() {
  if ! command -v devcontainer >/dev/null 2>&1; then
    echo "Command devcontainer is not installed." >&2
    exit 1
  fi
}

_devcontainer_check_workspace() {
  if [ ! -f ".devcontainer/devcontainer.json" ]; then
    echo "'.devcontainer/devcontainer.json' is not found" >&2
    exit 1
  fi
}

_devcontainer_help() {
  cat << HELP
Commands
    up
    exec <command>
    shell | bash  (default)
HELP
}

_devcontainer_up() {
  devcontainer up --workspace-folder .
}

_devcontainer_exec() {
  if [ $# -eq 0 ]; then
    echo "No command specified." >&2
    _devcontainer_help
    exit 1
  fi

  devcontainer exec --workspace-folder . "$@"
}

_devcontainer_shell() {
  _devcontainer_up
  devcontainer exec --workspace-folder . /bin/bash
}

_devcontainer() {
  cd "$project_directory"
  _devcontainer_check_workspace
  _devcontainer_check_command

  command="$1"
  [ $# -gt 0 ] && shift
  case "$command" in
    up ) _devcontainer_up ;;
    exec ) _devcontainer_exec "$@" ;;
    shell | bash | '' ) _devcontainer_shell ;;
    help ) _devcontainer_help; exit 0 ;;
    *) _devcontainer_help; exit 1 ;;
  esac
}

_devcontainer "$@"
