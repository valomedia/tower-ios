# AGENTS.md – Tower iOS

## Project

- `valomedia/tower-ios` is a SwiftUI iOS app for Tower.
- The project uses CocoaPods.
  Open, build, and test the app through `Tower_iOS.xcworkspace`,
  not the bare `.xcodeproj` after dependencies are installed.

## Commands

- `pod install` - install or refresh CocoaPods dependencies.
- `xcodebuild test -workspace Tower_iOS.xcworkspace -scheme Tower_iOS -destination "platform=iOS Simulator,name=<iPhone simulator>,OS=latest" -only-testing:Tower_iOSTests CODE_SIGNING_ALLOWED=NO` - run unit tests on macOS with Xcode.
- `.github/workflows/ios-tests.yml` contains the CI version of the test command,
  including simulator discovery.

## Structure

- `Tower_iOS/` - app source, resources, settings bundle, SwiftGen config, and SwiftUI views.
- `Tower_iOS/Controllers/` - API, camera, calling, and environment controllers.
- `Tower_iOS/Models/` - Codable models, errors, generated SwiftGen outputs, and app state types.
- `Tower_iOS/Views/` - SwiftUI views and view helpers.
- `Tower_iOSTests/` - unit tests for models, extensions, and coding helpers.
- `Tower_iOSUITests/` - UI test target.
- `Tower_iOS/Settings.bundle/` - iOS Settings definitions and public defaults.

## Dependency rules

- Keep dependency changes in `Podfile` and `Podfile.lock` together.
- Do not edit or commit `Pods/`;
  it is ignored and recreated by `pod install`.
- `SwiftGen` is provided by CocoaPods for Xcode builds.
  If the build cannot find it, run `pod install --repo-update`.

## Generated files

- SwiftGen is configured by `Tower_iOS/swiftgen.yml`
  and executed by `Tower_iOS/swiftgen.sh` during Xcode builds.
- Generated files match `*+Generated.swift`
  and are ignored by Git.
  Do not hand-edit or commit them.
- Update the SwiftGen templates and inputs instead:
  `Tower_iOS/Templates/`, `Tower_iOS/Assets.xcassets/`,
  and `Tower_iOS/Settings.bundle/`.

## Swift and Xcode conventions

- Preserve the existing Swift file style:
  file headers, `// MARK:` sections, explicit access where already used,
  and SwiftUI view code under `Tower_iOS/Views/`.
- Keep user-facing app copy in German unless the surrounding feature is already English.
- Prefer small model and extension tests in `Tower_iOSTests/`
  for logic that can run without launching the app.
- When adding image or color assets,
  update the asset files and their `Contents.json` together.

## Settings and secrets

- `Tower_iOS/Settings.bundle/Root.plist` may contain preference keys
  and public non-secret defaults such as `https://api.tower-assist.de`.
- Do not commit runtime credentials,
  personal test values,
  private endpoints,
  or environment-specific secrets.
- If local testing requires temporary settings or credentials,
  keep them in the installed app's preferences or iOS Settings after installation,
  not in source-controlled files.

## Verification

- For code changes, run the Xcode unit-test command above on macOS when Xcode is available.
- If Xcode is not available,
  at least verify affected files directly and mention that the iOS test suite could not be run.
