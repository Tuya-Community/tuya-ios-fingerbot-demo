# Tuya iOS Fingerbot Sample for Objective-C

This sample demonstrates the use of Tuya IoT App SDK for iOS to build an IoT app from scratch. Tuya IoT App SDK for iOS is divided into several functional groups to give you a clear insight into the implementation for different features, including the user registration process, home management for different users, device network pairing, and controls. For device network pairing, the EZ mode and AP mode are available. You can pair devices over Wi-Fi and control them over LAN and MQTT. For device control, a common panel is used to send and receive any type of data points.

![Fingerbot Sample](https://github.com/Tuya-Community/tuya-ios-fingerbot-demo/raw/main/screenshot.png)

## Prerequisites

- Xcode 12.0 and later
- iOS 12 and later

## Get started

1. The Tuya IoT App SDK for iOS is distributed through [CocoaPods](http://cocoapods.org/) and other dependencies in this sample. Make sure that you have installed CocoaPods. If not, run the following command to install CocoaPods first:

   ```bash
   sudo gem install cocoapods
   pod setup
   ```

2. Clone or download this sample, change the directory to the one that includes **Podfile**, and then run the following command:

   ```bash
   pod install
   ```

3. Get a pair of keys and a security image from the [Tuya IoT Platform](https://iot.tuya.com/?_source=github), and register a developer account if you don't have one. Then, perform the following steps:

   1. Log in to the [Tuya IoT Platform](https://iot.tuya.com/?_source=github). In the left-side navigation pane, choose **App** > **SDK Development**.
   2. Click **Create** to create an app.
   3. Fill in the required information. Make sure that you enter the valid package name. It cannot be changed afterward.
   4. Click the created app, and you will find the AppKey, AppSecret, and security image under the **Get Key** tag.

4. Open the `tuya-fingerbot-ios-objc.xcworkspace` pod generated for you.
5. Fill in the AppKey and AppSecret in the **AppKey.h** file.

   ```objective-c
   #define APP_KEY @"<#AppKey#>"
   #define APP_SECRET_KEY @"<#SecretKey#>"
   ```

6. Download the security image, rename it to `t_s.bmp`, and then drag it to the workspace to be at the same level as `Info.plist`.

   **Note**: The package name, AppKey, AppSecret, and security image must be the same as your app on the [Tuya IoT Platform](https://iot.tuya.com?_source=github). Otherwise, the sample cannot request the API.

## References
For more information, see [App SDK](https://developer.tuya.com/en/docs/app-development?_source=github).
