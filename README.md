# TripGo — Native apps (Capacitor)

Native Android & iOS wrappers for the TripGo site. They load the live deployed
site (`https://trip-clone-mocha.vercel.app`) in a native WebView via Capacitor's
`server.url`, so the apps always show the latest production build. `www/` holds
a small offline/loading fallback screen.

- **App ID:** `com.tripgo.app`
- **App name:** TripGo

## Android

### Prebuilt APK
A debug build is ready to install:

```
tripgo-app/TripGo-debug.apk   (~3.9 MB)
```

Install on a device (USB debugging on) with:

```bash
adb install -r TripGo-debug.apk
```

…or copy the `.apk` to the phone and tap it (allow "install from unknown sources").

### Rebuilding the APK
Requires JDK 17+ and the Android SDK. On this machine:

```powershell
$env:JAVA_HOME="C:\Program Files\Android\Android Studio\jbr"   # bundled JDK 21
$env:ANDROID_HOME="C:\Users\joshu\AppData\Local\Android\Sdk"
cd android
.\gradlew.bat assembleDebug      # -> app/build/outputs/apk/debug/app-debug.apk
```

For a **release** (Play Store) build you must create a keystore and sign:

```bash
.\gradlew.bat assembleRelease    # then zipalign + apksign with your keystore
```

After changing config or web assets: `npx cap sync android`.

## iOS / Apple app

> An iOS app **cannot be built on Windows** — Apple's toolchain (Xcode) only
> runs on macOS. The Xcode project is fully scaffolded here in `ios/`; the build
> and signing must be done on a Mac.

On a Mac with Xcode installed:

```bash
cd tripgo-app
npm install
npx cap sync ios
npx cap open ios          # opens ios/App/App.xcworkspace in Xcode
```

Then in Xcode: select a Team under **Signing & Capabilities**, choose a device
or simulator, and **Product → Run** (or **Product → Archive** to produce an
`.ipa` for TestFlight / the App Store).

No Mac? Use a macOS CI runner (e.g. GitHub Actions `macos-latest`, Codemagic,
Bitrise, or Ionic Appflow) to build and sign the iOS app in the cloud.

## Structure

```
tripgo-app/
├── capacitor.config.json   # appId, appName, server.url, splash/status bar
├── www/index.html          # offline/loading fallback screen
├── android/                # native Android (Gradle) project
├── ios/                    # native Xcode project (build on macOS)
└── TripGo-debug.apk        # prebuilt Android debug APK
```
