#!/usr/bin/env bash
set -euo pipefail

# Lightweight Linux PC tweak utility:
# - Finds high CPU or RAM processes
# - Kills only known non-essential apps (configurable)
# - Applies optional low-latency tweaks for input delay

CPU_THRESHOLD="${CPU_THRESHOLD:-25}"
MEM_THRESHOLD="${MEM_THRESHOLD:-15}"
DRY_RUN=1
APPLY_INPUT_TWEAKS=0

# Limit process kills to this explicit non-essential allowlist.
# Users can override from env: SAFE_KILL_APPS="discord steam chrome"
SAFE_KILL_APPS_DEFAULT="discord steam teams slack chrome brave opera spotify"
SAFE_KILL_APPS="${SAFE_KILL_APPS:-$SAFE_KILL_APPS_DEFAULT}"

usage() {
  cat <<USAGE
Usage: $0 [--apply] [--input-tweaks] [--cpu N] [--mem N]

Options:
  --apply          Actually terminate matching high-usage apps (default: dry-run)
  --input-tweaks   Apply low-latency/input-delay tweaks (Linux; sudo may be required)
  --cpu N          CPU usage threshold percent (default: ${CPU_THRESHOLD})
  --mem N          Memory usage threshold percent (default: ${MEM_THRESHOLD})

Environment:
  SAFE_KILL_APPS   Space-separated process names allowed to be terminated.
                   Default: "${SAFE_KILL_APPS_DEFAULT}"
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply)
      DRY_RUN=0
      shift
      ;;
    --input-tweaks)
      APPLY_INPUT_TWEAKS=1
      shift
      ;;
    --cpu)
      CPU_THRESHOLD="$2"
      shift 2
      ;;
    --mem)
      MEM_THRESHOLD="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

is_in_allowlist() {
  local name="$1"
  for app in $SAFE_KILL_APPS; do
    if [[ "$name" == "$app" ]]; then
      return 0
    fi
  done
  return 1
}

kill_or_print() {
  local pid="$1"
  local name="$2"
  local cpu="$3"
  local mem="$4"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY-RUN] would terminate: pid=${pid} name=${name} cpu=${cpu}% mem=${mem}%"
    return
  fi

  if kill -15 "$pid" 2>/dev/null; then
    echo "terminated: pid=${pid} name=${name} cpu=${cpu}% mem=${mem}%"
  else
    echo "failed to terminate: pid=${pid} name=${name}" >&2
  fi
}

find_and_tweak_high_usage_apps() {
  echo "Scanning for high-usage apps (cpu>=${CPU_THRESHOLD}% or mem>=${MEM_THRESHOLD}%)..."
  # pid, comm, %cpu, %mem (skip header)
  ps -eo pid=,comm=,%cpu=,%mem= | while read -r pid comm cpu mem; do
    cpu_int="${cpu%.*}"
    mem_int="${mem%.*}"

    if (( cpu_int >= CPU_THRESHOLD || mem_int >= MEM_THRESHOLD )); then
      # Normalize process name
      app_name="$(basename "$comm" | tr '[:upper:]' '[:lower:]')"

      if is_in_allowlist "$app_name"; then
        kill_or_print "$pid" "$app_name" "$cpu" "$mem"
      else
        echo "skip (not allowlisted): pid=${pid} name=${app_name} cpu=${cpu}% mem=${mem}%"
      fi
    fi
  done
}

apply_input_delay_tweaks() {
  echo "Applying input-delay tweaks (Linux best-effort)..."

  # Prefer performance governor when available.
  if command -v cpupower >/dev/null 2>&1; then
    sudo cpupower frequency-set -g performance || true
  fi

  # Disable USB autosuspend (can reduce wake latency for peripherals).
  if [[ -w /sys/module/usbcore/parameters/autosuspend ]]; then
    echo -1 | sudo tee /sys/module/usbcore/parameters/autosuspend >/dev/null || true
  fi

  # Disable mouse acceleration for all pointer devices in X11 sessions.
  if command -v xinput >/dev/null 2>&1 && [[ -n "${DISPLAY:-}" ]]; then
    while read -r id; do
      xinput --set-prop "$id" "libinput Accel Profile Enabled" 0, 1 >/dev/null 2>&1 || true
      xinput --set-prop "$id" "libinput Accel Speed" 0 >/dev/null 2>&1 || true
    done < <(xinput list --id-only "pointer" 2>/dev/null || true)
  fi

  echo "Input-delay tweaks attempted. Some settings may require root or specific desktop/session support."
}

find_and_tweak_high_usage_apps

if [[ "$APPLY_INPUT_TWEAKS" -eq 1 ]]; then
  apply_input_delay_tweaks
fi
