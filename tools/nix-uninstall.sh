#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

log() {
  printf '[nix-uninstall] %s\n' "$*"
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    log "Must be run as root (use sudo)."
    exit 1
  fi
}

stop_services() {
  log "Stopping and disabling nix-daemon (if present)"
  systemctl stop nix-daemon.service nix-daemon.socket 2>/dev/null || true
  systemctl disable nix-daemon.service nix-daemon.socket 2>/dev/null || true
  systemctl reset-failed nix-daemon.service nix-daemon.socket 2>/dev/null || true
}

remove_systemd_units() {
  log "Removing systemd unit files and links"
  rm -f \
    /etc/systemd/system/nix-daemon.service \
    /etc/systemd/system/nix-daemon.socket \
    /etc/systemd/system/sockets.target.wants/nix-daemon.socket
  systemctl daemon-reload || true
}

remove_tmpfiles() {
  log "Removing tmpfiles configuration"
  rm -f /etc/tmpfiles.d/nix-daemon.conf
}

restore_shell_files() {
  log "Restoring shell configuration files"

  local files=(
    /etc/bashrc
    /etc/bash.bashrc
    /etc/zshrc
  )

  for f in "${files[@]}"; do
    local backup="${f}.backup-before-nix"

    if [[ -f "$backup" ]]; then
      log "Restoring $f from $backup"
      cp -f "$backup" "$f"
      rm -fv "$backup"
    elif [[ -f "$f" ]]; then
      # Defensive cleanup if no backup exists
      sed -i '/# Nix/,/# End Nix/d' "$f" || true
    fi
  done

  rm -f /etc/profile.d/nix.sh
}

remove_root_bootstrap() {
  log "Removing root Nix bootstrap files"
  rm -rf /root/.nix-profile \
         /root/.nix-defexpr \
         /root/.nix-channels \
         /root/.cache/nix
}

# remove_user_traces() {
#   log "Removing per-user Nix traces (current users only)"
#   for home in /home/*; do
#     [[ -d "$home" ]] || continue
#     rm -rf \
#       "$home/.nix-profile" \
#       "$home/.nix-defexpr" \
#       "$home/.nix-channels" \
#       "$home/.cache/nix"
#   done
# }

remove_nix_dirs() {
  log "Removing /nix and /etc/nix"
  rm -rf /nix /etc/nix
}

remove_build_users() {
  log "Removing nix build users and group"

  for u in $(getent passwd | awk -F: '/^nixbld[0-9]+:/ {print $1}'); do
    userdel "$u" 2>/dev/null || true
  done

  getent group nixbld >/dev/null && groupdel nixbld || true
}

remove_installer_artifacts() {
  log "Removing installer detection artifacts"
  rm -rf \
    /tmp/nix-* \
    /var/tmp/nix-* \
    /var/lib/nix \
    /var/log/nix
}

final_check() {
  log "Final verification"

  if command -v nix >/dev/null; then
    log "WARNING: nix binary still found in PATH"
  else
    log "nix command not found (expected)"
  fi

  if [[ -d /nix ]]; then
    log "WARNING: /nix still exists"
  else
    log "/nix removed"
  fi

  if ls /etc/*backup-before-nix >/dev/null 2>&1; then
    log "WARNING: backup-before-nix files still present"
  else
    log "No installer backup artifacts found"
  fi
}

main() {
  require_root
  stop_services
  remove_systemd_units
  remove_tmpfiles
  restore_shell_files
  remove_root_bootstrap
  # remove_user_traces
  remove_nix_dirs
  remove_build_users
  remove_installer_artifacts
  final_check
  log "System is clean. Reboot or start a new shell before reinstalling Nix."
}

main "$@"
