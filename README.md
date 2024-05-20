# Tower iOS

iOS app for Tower.

## Building

In order to build this App, you will need to do the following:

1. Install [swiftgen](https://github.com/swiftgen/swiftgen) into your PATH
2. Download [amazon-chime-sdk-ios](https://github.com/aws/amazon-chime-sdk-ios/releases/releases/tag/v0.25.1) (v0.25.1)
3. Copy AmazonChimeSDK.xcframework and AmazonChimeSDKMedia.xcframework into PROJECT_DIR
4. Set up code signing in XCode

## Installing

In order for the app to function, it needs credentials. The credentials should be the same ones supplied to the session
of tower-assist, you want to connect with.

You can supply credentials by choosing one of these two methods:

* Before building and installing, you can put them into Tower_iOS/Settings.bundle/Root.plist
* After building and installing, you can enter them in the iOS settings app in the settings for Tower
