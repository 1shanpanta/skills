---
name: app-install
description: Find the physical phones attached to this computer, install an Expo or React Native build on one, and optionally keep it current on a timer. Use when the user says "/app-install", "is my phone connected", "install the app on my phone", "put the latest build on my phone", "keep rebuilding it", "app install done", "stop the watch", or asks which devices this computer can see. Real hardware only, not simulators.
---

# app-install

One script does all of it: `scripts/app-target.sh [list|pair|doctor|install|watch|stop|watch-status] [<target>]`,
in this skill folder.

It works in any Expo or React Native repository. It finds the app directory by looking for
`app.config.ts`, `app.config.js` or `app.json`, in `apps/mobile`, `apps/app`, `mobile`, `app`,
`packages/mobile`, then the repository root.

macOS and Linux for Android. iPhone detection and iPhone builds need macOS with Xcode.

## Answering "is my phone connected"

Run `app-target.sh list`. One line per device: the target, the model, and for Android the
transport it came in on:

    android:<serial>	<model>	wired
    android:<ip>:<port>	<model>	wireless
    ios:<udid>	<name>

**Check every transport before answering.** An answer that checks only the Apple paths says
"not connected" about an Android phone sitting on adb. The script checks both:

- `adb devices -l` for Android.
- `xcrun devicectl list devices` for a real iPhone.

**Real hardware only.** A simulator proves nothing about the thing in a tester's hand: no real
GPS, no cellular, no camera, no store build. Boot one with `xcrun simctl boot` and build it with
`expo run:ios` by hand when that is what you want.

Three things make a connected phone look absent, and the script handles each:

- `adb` is often off `PATH`. It looks in `ANDROID_HOME`, `ANDROID_SDK_ROOT`,
  `~/Library/Android/sdk/platform-tools`, and both Homebrew prefixes.
- Only an adb state of `device` counts. `unauthorized` means the trust prompt is still on the
  phone's screen, and `offline` means the cable dropped.
- A phone that locks its screen drops off `devicectl` until it is unlocked again.

## A cable needs nothing. Wi-Fi needs a pairing code.

**Check the cable first, and only ask when there is nothing on it.**

- `list` shows an Android device on `wired`, or an already connected `wireless` one: that is the
  target. Install on it and say nothing about pairing.
- `list` shows no Android device: ask the user for the pairing code, in one line, and wait. They
  open Developer options > Wireless debugging > **Pair device with pairing code** on the phone
  and read back the six digits. Both the code and the address die when that dialog closes, so
  ask for the code at the moment it is needed, never in advance.

Then pair:

    scripts/app-target.sh pair <code>
    scripts/app-target.sh pair <code> <ip>:<port>

The script finds the pairing address over mDNS, so the code is normally the only thing the user
has to type. Pass the address too when mDNS answers nothing, which happens when the computer and
the phone sit on different networks, or on a network that blocks multicast.

**Pairing is not connecting.** `adb pair` only trades the code for a key. The script runs
`adb connect` against the debugging port afterwards, which is a different port from the pairing
one, and then prints `list` again so the new target is visible. A phone that paired and never
connected shows nothing in `adb devices`, and reads as a pairing that failed.

A phone paired once stays paired: later sessions need `adb connect <ip>:<port>` alone, no code.
The port changes every time Wireless debugging is turned off and on again.

## Before building

Run `app-target.sh doctor`. It prints the app directory, the `adb` path, `scrcpy`, the Android
SDK, the JDK and the Xcode version, and names anything missing.

**Never conclude "no Java" from `java -version` or `/usr/libexec/java_home`.** A Homebrew
`openjdk` is keg-only: it is not linked into `/usr/bin/java` and `java_home` cannot see it, so
both report nothing on a machine that builds Android fine. `doctor` checks the Homebrew kegs
first, then Android Studio's bundled runtime, then `java_home`, and `install` exports
`JAVA_HOME` for Gradle.

Gradle also needs the SDK. `ANDROID_HOME` is not set by installing the command line tools, so a
machine with a working `adb` still fails the build with "SDK location not found", which reads as
a project fault. `install` exports that too.

## Installing

    cd <the repository you mean>
    scripts/app-target.sh install                  # one target attached
    scripts/app-target.sh install android:<serial>

It builds from **the checkout it runs in**, at whatever commit is checked out. It never fetches
and never changes branch, so "the latest version" means whatever you put in that tree first.
Say which commit went on the device when you report back.

It picks the package runner from the lockfile: `pnpm exec expo`, `yarn expo`, else `npx expo`.

`expo run:android` and `expo run:ios` prebuild, build and install. The result is a development
build, so Metro serves the JavaScript afterwards: a JavaScript-only change needs a Metro reload,
not another install.

## The phone mirrors itself when the install finishes

An Android install ends by starting `scrcpy -S`, so the app appears in a window on the computer
and the handset's own display stays off. Nothing else changes: the build, the install and the
launch are the same.

- `-S` is `--turn-screen-off`. The phone keeps running and keeps answering adb; it only stops
  lighting its own panel, which is what drains a phone left on a desk all afternoon.
- The window takes the keyboard and the mouse, so a flow can be walked without reaching for the
  handset. That matters for anything `adb` cannot drive: a permission dialog, a Google account
  chooser, a text field. `xcrun simctl` and `adb shell input` cannot tap those reliably.
- **It is never fatal.** No `scrcpy` on the machine, or a mirror that will not start, prints a
  line and leaves the install successful, because the install already succeeded. Add it with
  `brew install scrcpy`, or the distribution's package manager on Linux.
- An already-running `scrcpy` is left alone rather than stacked on.
- Start one by hand at any time: `scrcpy -S -s <serial>`. Stop it by closing the window.
- The phone's screen comes back on its own when scrcpy exits. Wake it with
  `adb shell input keyevent KEYCODE_WAKEUP` if it does not.

## Keeping a phone current

    scripts/app-target.sh watch            # one device attached
    scripts/app-target.sh watch android:<serial>
    scripts/app-target.sh watch-status
    scripts/app-target.sh stop

It wakes every 15 minutes, and reinstalls only when the **native** side has changed: the Expo
config, the dependency list, or the `android` and `ios` folders. `APP_TARGET_EVERY=300` changes
the interval.

**It does not rebuild for a screen edit, and it should not.** A development build takes its
JavaScript from Metro, so a component change needs a reload, not a reinstall. Rebuilding on
every save would spend minutes to change nothing, and would fight whoever is using the phone.

Every wake writes a line to `~/.claude/run/app-target-watch.log`, including the wakes that found
nothing, so a silent log means the watch died rather than that the app is current.

**Stop it when the session is done.** The user says "app install done", "stop the watch" or
"close the cron": run `app-target.sh stop`. It kills the process group, so the sleep and any
build in flight go with it. A watch left running rebuilds against whatever branch the checkout
later holds, which is how a phone ends up carrying work nobody chose to put there.

## A real iPhone

An iPhone build needs a signing team on a paid Apple Developer account. Without one the build
gets most of the way and then fails on code signing, which reads as a fault in the project
rather than a missing membership. The script refuses an `ios:` target and prints the command to
run by hand when the project does have a team.

## The app sits on the splash for ever

A development build carries no JavaScript. Metro serves it from the computer, over the Wi-Fi
address the install baked into the launch link, for example `http://192.168.1.77:8081`. The
phone drops off Wi-Fi, that address dies, and the app draws the native splash and waits. Nothing
looks wrong: the build exits 0, the APK installs, the process runs and the screen redraws at
59 fps.

**Put the bundler on the cable, and the Wi-Fi stops mattering:**

    adb reverse tcp:8081 tcp:8081
    adb shell am force-stop <applicationId>
    adb shell am start -a android.intent.action.VIEW \
      -d "<scheme>://expo-development-client/?url=http%3A%2F%2Flocalhost%3A8081"

`<applicationId>` is `android.package` in the Expo config, and `<scheme>` is `scheme` in the same
file. Read both there rather than guessing, and confirm the package with
`adb shell pm list packages | grep <name>`.

Do this whenever the app hangs on the splash. It costs nothing when the network is fine.

A reinstall can clear the session, so the app opens on the signed-out screen. Every guarded read
then answers nothing, and screens look empty for a reason that is not a bug.

## Ports

`git worktree remove` does not stop the Metro that worktree started, so a dead checkout keeps
its port and answers every request with a `ConfigError` naming a path that no longer exists.
Find the owner with `lsof -ti tcp:<port>`, then `lsof -a -p <pid> -d cwd -Fn`. Never
`pkill -f expo`, which takes live sessions with it.

**`lsof -ti tcp:8081` does not prove Metro is up.** Once a reverse tunnel exists, the `adb`
server holds that port too, so the check answers a pid that is not the bundler. Read the command
with `ps -o command -p <pid>`, and look for `expo/bin/cli run:android`.

**Do not ask Metro for `/index.bundle` in an Expo Router app.** It enters at `expo-router/entry`,
so that URL answers `UnableToResolveError` on a healthy bundler and reads as a broken build.

## Installing the skill

Copy this folder into `~/.claude/skills/app-install`, and keep `scripts/app-target.sh`
executable. The script needs `adb` (Android platform tools), and `scrcpy` for mirroring. An
iPhone needs Xcode.
