#!/usr/bin/env bash
set -euo pipefail

APP="init-claude-gemini"
SRC="$HOME/.claude"
DST="$HOME/.config/claude-gemini/claude"

SHARE_PROJECTS=0
DRY_RUN=0
FORCE=0

usage() {
  cat >&2 <<'EOF'
Usage:
  init-claude-gemini.sh [--share-projects] [--force] [--dry-run]

What it does:
  - Creates isolated config dir: ~/.config/claude-gemini/claude
  - Symlinks shared "capability" dirs from ~/.claude:
      skills, plugins, commands, hooks, agents
    Optional:
      projects (enable with --share-projects)
  - Keeps "state" isolated in gemini dir:
      settings*, history, transcripts, cache, debug, telemetry, statsig, session-env, etc.

Options:
  --share-projects   Also share ~/.claude/projects into gemini profile
  --force            If destination items exist, back them up then replace
  --dry-run          Print actions only, do not modify filesystem
EOF
}

log() { echo "[$APP] $*" >&2; }
die() { echo "[$APP] ERROR: $*" >&2; exit 1; }

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "+ $*" >&2
  else
    eval "$@"
  fi
}

backup_if_needed() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    local ts
    ts="$(date +%Y%m%d%H%M%S)"
    run "mv \"$path\" \"${path}.bak.${ts}\""
  fi
}

ensure_dir() {
  local dir="$1"
  run "mkdir -p \"$dir\""
}

ensure_src_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    run "mkdir -p \"$dir\""
  fi
}

link_shared() {
  local name="$1"
  local src_path="${SRC}/${name}"
  local dst_path="${DST}/${name}"

  ensure_src_dir "$src_path"
  ensure_dir "$DST"

  # If dst exists:
  if [[ -e "$dst_path" || -L "$dst_path" ]]; then
    # If already correct symlink, do nothing
    if [[ -L "$dst_path" ]]; then
      local target
      target="$(readlink "$dst_path" || true)"
      if [[ "$target" == "$src_path" ]]; then
        log "OK: ${dst_path} already links to ${src_path}"
        return
      fi
    fi

    if [[ "$FORCE" -eq 1 ]]; then
      log "Replacing existing ${dst_path} (backup first)"
      backup_if_needed "$dst_path"
    else
      die "${dst_path} already exists. Re-run with --force to replace, or remove it manually."
    fi
  fi

  run "ln -s \"$src_path\" \"$dst_path\""
  log "Linked: ${dst_path} -> ${src_path}"
}

create_isolated_state_layout() {
  # Create common isolated dirs (safe if already exist)
  local dirs=(
    "cache"
    "debug"
    "telemetry"
    "statsig"
    "session-env"
    "transcripts"
    "shell-snapshots"
    "file-history"
    "plans"
    "todos"
  )
  for d in "${dirs[@]}"; do
    ensure_dir "${DST}/${d}"
  done

  # Touch isolated history file if not exists
  run "touch \"${DST}/history.jsonl\""
}

write_settings_if_missing() {
  local settings="${DST}/settings.json"

  if [[ -f "$settings" && "$FORCE" -eq 0 ]]; then
    log "Keep existing settings.json (use --force to replace)"
    return
  fi

  if [[ -f "$settings" && "$FORCE" -eq 1 ]]; then
    log "Backing up existing settings.json"
    backup_if_needed "$settings"
  fi

  # Minimal, safe defaults (no secrets). You can edit after.
  # NOTE: We do NOT set ANTHROPIC_API_KEY here.
  local json='{
  "env": {
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "gemini-3-flash",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "gemini-3-pro-high",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-4-5-thinking"
  },
  "enabledPlugins": {
    "superpowers@superpowers-marketplace": true
  }
}'
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Would write ${settings} with default env + enabledPlugins"
  else
    printf "%s\n" "$json" > "$settings"
  fi
  log "Wrote: ${settings}"
}

chmod_harden() {
  # Harden permissions (best-effort)
  run "chmod 700 \"$(dirname "$DST")\" \"${DST}\" || true"
  run "chmod 600 \"${DST}/settings.json\" \"${DST}/history.jsonl\" || true"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --share-projects) SHARE_PROJECTS=1; shift ;;
      --force) FORCE=1; shift ;;
      --dry-run) DRY_RUN=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "Unknown arg: $1 (use --help)" ;;
    esac
  done
}

main() {
  parse_args "$@"

  [[ -d "$SRC" ]] || die "Source dir not found: $SRC (run claude once to initialize it)"

  log "Source (default): $SRC"
  log "Destination (gemini): $DST"
  log "share-projects=$SHARE_PROJECTS force=$FORCE dry-run=$DRY_RUN"

  ensure_dir "$DST"

  # Shared capability dirs
  link_shared "skills"
  link_shared "plugins"
  link_shared "commands"
  link_shared "hooks"
  link_shared "agents"

  if [[ "$SHARE_PROJECTS" -eq 1 ]]; then
    link_shared "projects"
  else
    log "Skip sharing projects (enable with --share-projects)"
  fi

  # Isolated state
  create_isolated_state_layout
  write_settings_if_missing
  chmod_harden

  log "Done."
  log "Verify:"
  log "  ls -l \"$DST\" | egrep \"skills|plugins|commands|hooks|agents|projects\""
  log "Next:"
  log "  Use your wrapper with: export CLAUDE_CONFIG_DIR=\"$DST\""
}

main "$@"
