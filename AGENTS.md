# AGENTS.md

## Scope

These instructions apply to the entire repository.

## Project overview

This repository contains the SwiftUI iOS app for Tower.
The app uses CocoaPods for dependencies
and should be opened, built, and tested through `Tower_iOS.xcworkspace`.

## Dependencies

Run `pod install` after changing `Podfile` or `Podfile.lock`,
and before building from a clean checkout.
Do not commit `Pods/`, build products, DerivedData, or other generated local state.

## Build and test

Use the shared workspace and scheme for local verification:

```sh
xcodebuild test \
  -workspace Tower_iOS.xcworkspace \
  -scheme Tower_iOS \
  -destination 'platform=iOS Simulator,name=<available iPhone simulator>,OS=latest' \
  -only-testing:Tower_iOSTests \
  CODE_SIGNING_ALLOWED=NO
```

If no simulator is known,
choose an available iPhone simulator from `xcrun simctl list devices available`.
For documentation-only changes,
`git diff --check` is an acceptable minimal verification step.

## Swift and Xcode conventions

Keep Swift code explicit and readable.
Follow the existing file organization:
controllers in `Tower_iOS/Controllers`,
models in `Tower_iOS/Models`,
SwiftUI views in `Tower_iOS/Views`,
and small reusable helpers in `Tower_iOS/Extensions`.

Preserve the existing `// MARK:` structure in Swift files.
Prefer small focused types and methods over broad utility objects.
Use async/await for asynchronous work when adding new app code.

When editing the Xcode project file,
make the smallest possible change
and avoid rewriting unrelated sections.

## Generated files and assets

SwiftGen is configured by `Tower_iOS/swiftgen.yml`
and run through `Tower_iOS/swiftgen.sh` during the Xcode build.
Do not commit `*+Generated.swift` files.
Update the SwiftGen templates or source assets/settings instead.

Keep asset catalog metadata valid JSON.
Do not replace SVG or image assets unless the issue explicitly asks for the visual change.

## Secrets and credentials

Do not commit credentials, private endpoints, tokens, provisioning profiles, signing certificates, or local user settings.
Public non-secret default endpoints may stay in tracked configuration
when they are required for normal app operation.
The tracked `Tower_iOS/Settings.bundle/Root.plist`
should define preference keys and public non-secret defaults only.
Enter runtime credentials or environment-specific values
through the installed app's preferences or the iOS Settings app after installation,
not in source-controlled files.
