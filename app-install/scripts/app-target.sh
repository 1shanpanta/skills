#!/bin/bash
# Finds the physical phones attached to this Mac, and installs a mobile app on one.
#
#   app-target.sh list                  every device, one per line
#   app-target.sh pair <code> [host:port]  pair a phone over Wi-Fi with its pairing code
#   app-target.sh doctor                whether this Mac can build for each platform
#   app-target.sh install [<device>]    build the app in this checkout and install it
#   app-target.sh watch [<device>]      reinstall whenever the native side goes stale
#   app-target.sh stop                  stop the watch
#   app-target.sh watch-status          whether a watch is running, and what it last saw
#
# A device is `android:<serial>` or `ios:<udid>`. With one attached, `install` needs no
# argument. With more than one it refuses rather than guessing.
#
# Real hardware only. A simulator proves nothing about the thing in a tester's hand: it has no
# real GPS, no cellular, no camera and no App Store build, and this repository's own sweeps
# already run there. Boot one with `xcrun simctl boot` and build with `expo run:ios` by hand.
#
# Project agnostic: it finds the app directory by looking for an Expo or React Native config,
# and it builds from the checkout it runs in. It never fetches and never changes branch.

set -u

ADB=""
for candidate in \
  "${ANDROID_HOME:-}/platform-tools/adb" \
  "${ANDROID_SDK_ROOT:-}/platform-tools/adb" \
  "$HOME/Library/Android/sdk/platform-tools/adb" \
  /opt/homebrew/bin/adb \
  /usr/local/bin/adb
do
  [ -n "$candidate" ] && [ -x "$candidate" ] && ADB="$candidate" && break
done

# The app directory: wherever the Expo or React Native config lives. Checked in the order a
# monorepo usually nests them, then the repository root for a single-app project.
app_dir() {
  for dir in apps/mobile apps/app mobile app packages/mobile .; do
    for config in app.config.ts app.config.js app.json; do
      [ -f "$dir/$config" ] && echo "$dir" && return 0
    done
  done
  return 1
}

list_android() {
  [ -z "$ADB" ] && return 0
  # `device` only. `unauthorized` means the trust prompt is still on the phone's screen, and
  # `offline` means the cable dropped, so neither can take an install.
  # A wireless serial is `<ip>:<port>`, a cable serial never holds a colon. The transport
  # column matters: a cable is already trusted, and a phone on Wi-Fi had to be paired first.
  "$ADB" devices -l 2>/dev/null | awk '$2 == "device" {
    serial = $1; model = "";
    for (i = 3; i <= NF; i++) if ($i ~ /^model:/) { model = substr($i, 7) }
    transport = (serial ~ /:[0-9]+$/) ? "wireless" : "wired"
    printf "android:%s\t%s\t%s\n", serial, (model == "" ? "Android device" : model), transport
  }'
}

# Is anything on a cable right now? The answer decides whether a pairing code is needed at all.
wired_android() {
  list_android | awk -F'\t' '$3 == "wired"'
}

# Wireless debugging: the phone shows a pairing address and a six digit code, both of which
# change every time the dialog opens. mDNS carries the address, so only the code has to be
# read off the screen. `adb pair` trades the code for a key, then `adb connect` opens the
# session; pairing alone attaches nothing, which reads as a pairing that did not work.
mdns_endpoint() {
  service="$1"
  [ -z "$ADB" ] && return 1
  "$ADB" mdns services 2>/dev/null | awk -v want="$service" '
    $2 == want { print $3; exit }'
}

pair_wireless() {
  code="$1"
  endpoint="${2:-}"
  [ -z "$ADB" ] && { echo "No adb on this Mac, so nothing can pair. Run 'app-target.sh doctor'."; return 1; }

  if [ -z "$endpoint" ]; then
    "$ADB" start-server >/dev/null 2>&1
    endpoint=$(mdns_endpoint "_adb-tls-pairing._tcp")
  fi
  if [ -z "$endpoint" ]; then
    echo "No pairing address. Open Developer options > Wireless debugging > Pair device with"
    echo "pairing code on the phone, keep that dialog open, and pass the address it shows:"
    echo "  app-target.sh pair <code> <ip>:<port>"
    return 1
  fi

  echo "Pairing with $endpoint"
  "$ADB" pair "$endpoint" "$code" || {
    echo "Pairing failed. The code and the address both expire when the dialog closes, so open"
    echo "it again and read the new pair."
    return 1
  }

  # The pairing port is not the debugging port, so the address to connect to is a second one.
  connect=$(mdns_endpoint "_adb-tls-connect._tcp")
  if [ -z "$connect" ]; then
    # Same phone, the port the Wireless debugging screen itself shows.
    echo "Paired. mDNS did not answer with the debugging port, so connect by hand:"
    echo "  adb connect <ip>:<port>   (the address on the Wireless debugging screen)"
    return 0
  fi
  echo "Connecting to $connect"
  "$ADB" connect "$connect"
}

list_ios_device() {
  command -v xcrun >/dev/null 2>&1 || return 0
  xcrun devicectl list devices 2>/dev/null | awk '
    NR > 2 && NF > 2 && $0 !~ /^-+$/ && $0 !~ /No devices found/ {
      for (i = 1; i <= NF; i++) if ($i ~ /^[0-9A-F]{8}-[0-9A-F]{16}$/ || $i ~ /^[0-9a-f]{40}$/) {
        printf "ios:%s\t%s\n", $i, $1
      }
    }'
}

targets() {
  list_android
  list_ios_device
}

# A Homebrew `openjdk` is keg-only, so it is not linked into `/usr/bin/java` and
# `/usr/libexec/java_home` cannot see it. Both then report no Java on a machine that has one,
# and an Android build that has worked for months reads as newly broken. Check the kegs first.
# Gradle reads `ANDROID_HOME`, or `sdk.dir` in `android/local.properties`. Neither is set by
# installing the command line tools, so a machine with a working `adb` still fails the build
# with "SDK location not found", which reads as a project fault.
android_home() {
  for candidate in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$HOME/Library/Android/sdk" "$HOME/Android/Sdk"; do
    [ -n "$candidate" ] && [ -d "$candidate/platform-tools" ] && echo "$candidate" && return 0
  done
  # Last resort: the SDK that owns the adb we found.
  if [ -n "$ADB" ]; then
    sdk=$(dirname "$(dirname "$ADB")")
    [ -d "$sdk/platform-tools" ] && echo "$sdk" && return 0
  fi
  return 1
}

java_home() {
  [ -n "${JAVA_HOME:-}" ] && [ -x "${JAVA_HOME}/bin/java" ] && echo "$JAVA_HOME" && return 0

  for keg in /opt/homebrew/opt/openjdk@* /usr/local/opt/openjdk@* /opt/homebrew/opt/openjdk /usr/local/opt/openjdk; do
    home="$keg/libexec/openjdk.jdk/Contents/Home"
    [ -x "$home/bin/java" ] && echo "$home" && return 0
  done

  for candidate in \
    "/Applications/Android Studio.app/Contents/jbr/Contents/Home" \
    "$HOME/Applications/Android Studio.app/Contents/jbr/Contents/Home"
  do
    [ -x "$candidate/bin/java" ] && echo "$candidate" && return 0
  done

  /usr/libexec/java_home 2>/dev/null
}

# Mirror the phone on this Mac with the device's own screen off, so a build can be watched and
# driven from the keyboard without the handset burning battery beside it. Never fatal: a mirror
# that cannot start must not read as a failed install, because the install already succeeded.
mirror() {
  serial="$1"
  command -v scrcpy >/dev/null 2>&1 || {
    echo "No scrcpy, so the phone is installed but not mirrored. 'brew install scrcpy' adds it."
    return 0
  }
  if pgrep -f "scrcpy.*$serial" >/dev/null 2>&1 || pgrep -x scrcpy >/dev/null 2>&1; then
    echo "scrcpy is already mirroring. Leaving it alone."
    return 0
  fi
  echo "Mirroring with scrcpy -S, the phone's own screen stays off."
  mkdir -p "$RUN_DIR"
  nohup scrcpy -S -s "$serial" >"$RUN_DIR/scrcpy.log" 2>&1 &
}

doctor() {
  echo "app directory: $(app_dir || echo 'NOT FOUND, no Expo or React Native config here')"
  echo "adb:           ${ADB:-NOT FOUND}"
  echo "scrcpy:        $(command -v scrcpy 2>/dev/null || echo 'NOT FOUND, install will not mirror')"
  echo "android sdk:   $(android_home || echo 'NOT FOUND. Gradle answers SDK location not found.')"

  local jdk
  jdk=$(java_home)
  if [ -n "$jdk" ]; then
    echo "jdk:           $jdk"
  else
    echo "jdk:           NOT FOUND. Gradle cannot run, so an Android build fails."
    echo "               Android Studio ships one, or install a JDK 17 and set JAVA_HOME."
  fi

  if command -v xcodebuild >/dev/null 2>&1; then
    echo "xcode:         $(xcodebuild -version 2>/dev/null | head -1)"
  else
    echo "xcode:         NOT FOUND. No simulator build and no iPhone build."
  fi
}

RUN_DIR="$HOME/.claude/run"
WATCH_PID="$RUN_DIR/app-target-watch.pid"
WATCH_LOG="$RUN_DIR/app-target-watch.log"
WATCH_EVERY="${APP_TARGET_EVERY:-900}"

# What makes a build stale. Only the native side: JavaScript reaches the device through Metro,
# so a screen edit needs a reload, never a reinstall. A rebuild on every file save would burn
# minutes to change nothing.
native_fingerprint() {
  local dir="$1"
  {
    cat "$dir"/app.config.ts "$dir"/app.config.js "$dir"/app.json 2>/dev/null
    # Dependencies and their versions, not the lockfile: a hoist churns the lockfile alone.
    sed -n '/"dependencies"/,/}/p' "$dir/package.json" 2>/dev/null
    ls "$dir/android/app/src/main" "$dir/ios" 2>/dev/null
  } | shasum | cut -d' ' -f1
}

case "${1:-list}" in
  list)
    found=$(targets)
    if [ -z "$found" ]; then
      echo "No phone attached. Plug one in, unlock it, and accept the trust prompt."
      echo "Over Wi-Fi instead: Developer options > Wireless debugging > Pair device with"
      echo "pairing code, then 'app-target.sh pair <code>'."
      exit 1
    fi
    echo "$found"
    ;;

  pair)
    code="${2:-}"
    if [ -z "$code" ]; then
      echo "Usage: app-target.sh pair <code> [<ip>:<port>]"
      echo "The code is the six digits on the phone's 'Pair device with pairing code' dialog."
      exit 1
    fi
    pair_wireless "$code" "${3:-}" || exit 1
    targets
    ;;

  doctor)
    doctor
    ;;

  install)
    chosen="${2:-}"
    if [ -z "$chosen" ]; then
      found=$(targets)
      count=$(printf '%s\n' "$found" | grep -c .)
      if [ "$count" -eq 0 ]; then
        echo "No phone attached. Plug one in, or pair over Wi-Fi with 'app-target.sh pair <code>'."
        exit 1
      fi
      if [ "$count" -gt 1 ]; then
        echo "More than one target. Name the one you mean:"
        printf '%s\n' "$found"
        exit 1
      fi
      chosen=$(printf '%s\n' "$found" | cut -f1)
    fi

    dir=$(app_dir) || { echo "No Expo or React Native config found. Run this from the repository root."; exit 1; }

    kind=${chosen%%:*}
    id=${chosen#*:}
    echo "Building $(git rev-parse --short HEAD 2>/dev/null || echo 'this checkout') in $dir for $chosen"

    runner="npx expo"
    [ -f pnpm-lock.yaml ] && runner="pnpm exec expo"
    [ -f yarn.lock ] && runner="yarn expo"

    case "$kind" in
      android)
        jdk=$(java_home)
        if [ -z "$jdk" ]; then
          echo "No JDK, so Gradle cannot run and this build would fail part way through."
          echo "Run 'app-target.sh doctor' for what is missing."
          exit 1
        fi
        # `--device` wants the name Expo shows, not an adb serial, and answers
        # "Could not find device with name: <serial>". `ANDROID_SERIAL` is what adb itself reads,
        # so every command underneath, the install and the launch, lands on this phone.
        sdk=$(android_home)
        if [ -z "$sdk" ]; then
          echo "No Android SDK. Gradle answers 'SDK location not found' without one."
          echo "Run 'app-target.sh doctor' for what is missing."
          exit 1
        fi
        JAVA_HOME="$jdk" ANDROID_HOME="$sdk" ANDROID_SDK_ROOT="$sdk" ANDROID_SERIAL="$id" \
          sh -c "cd '$dir' && $runner run:android"
        mirror "$id"
        ;;
      ios)
        # A real iPhone needs a signing team on the Apple Developer Program. Without one the
        # build gets most of the way and then fails on code signing, which reads as a project
        # fault rather than a missing membership.
        command -v xcodebuild >/dev/null 2>&1 || { echo "No Xcode, so there is nothing to build with."; exit 1; }
        echo "An iPhone build needs a signing team on a paid Apple Developer account."
        echo "If this project has one, run it yourself and watch the signing step:"
        echo "  cd $dir && $runner run:ios --device $id"
        exit 1
        ;;
      *)
        echo "Unknown target '$chosen'. Ask for 'list' to see what is attached."
        exit 1
        ;;
    esac
    ;;

  watch)
    mkdir -p "$RUN_DIR"
    if [ -f "$WATCH_PID" ] && kill -0 "$(cat "$WATCH_PID")" 2>/dev/null; then
      echo "A watch is already running, pid $(cat "$WATCH_PID"). Stop it first."
      exit 1
    fi

    chosen="${2:-}"
    if [ -z "$chosen" ]; then
      found=$(targets); count=$(printf '%s\n' "$found" | grep -c .)
      [ "$count" -eq 1 ] || { echo "Name the device. Attached:"; printf '%s\n' "$found"; exit 1; }
      chosen=$(printf '%s\n' "$found" | cut -f1)
    fi
    dir=$(app_dir) || { echo "No Expo or React Native config found."; exit 1; }
    here=$(pwd)
    self=$(cd "$(dirname "$0")" && pwd)/$(basename "$0")

    # Detached, so it outlives the shell that started it. Every wake writes a line, so a quiet
    # log means the watch died rather than that nothing changed.
    (
      echo "watch started on $chosen, every ${WATCH_EVERY}s, in $here"
      last=$(native_fingerprint "$dir")
      echo "fingerprint $last"
      while true; do
        sleep "$WATCH_EVERY"
        now=$(native_fingerprint "$dir")
        if [ "$now" = "$last" ]; then
          echo "$(date '+%H:%M:%S') native side unchanged, nothing to install"
          continue
        fi
        echo "$(date '+%H:%M:%S') native side changed, installing"
        if (cd "$here" && "$self" install "$chosen"); then
          last="$now"
          echo "$(date '+%H:%M:%S') installed, fingerprint $last"
        else
          echo "$(date '+%H:%M:%S') install failed, trying again next wake"
        fi
      done
    ) >>"$WATCH_LOG" 2>&1 &

    echo $! > "$WATCH_PID"
    echo "Watching $chosen every ${WATCH_EVERY}s, pid $(cat "$WATCH_PID")."
    echo "Log:  $WATCH_LOG"
    echo "Stop: app-target.sh stop"
    ;;

  stop)
    if [ ! -f "$WATCH_PID" ]; then echo "No watch is running."; exit 0; fi
    pid=$(cat "$WATCH_PID")
    if kill -0 "$pid" 2>/dev/null; then
      # The sleep, and any build it started, are its children, so the whole group goes.
      group=$(ps -o pgid= "$pid" 2>/dev/null | tr -d ' ')
      { [ -n "$group" ] && kill -- "-$group" 2>/dev/null; } || kill "$pid" 2>/dev/null
      echo "Stopped the watch, pid $pid."
    else
      echo "The watch was already gone, pid $pid."
    fi
    rm -f "$WATCH_PID"
    ;;

  watch-status)
    if [ -f "$WATCH_PID" ] && kill -0 "$(cat "$WATCH_PID")" 2>/dev/null; then
      echo "Running, pid $(cat "$WATCH_PID"), every ${WATCH_EVERY}s."
    else
      echo "Not running."
    fi
    [ -f "$WATCH_LOG" ] && { echo "Last lines:"; tail -5 "$WATCH_LOG"; }
    ;;

  *)
    echo "Usage: app-target.sh [list|pair|doctor|install|watch|stop|watch-status] [<target>]"
    exit 1
    ;;
esac
