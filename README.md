# BasicAnalytics

BasicAnalytics is a lightweight analytics SDK for iOS applications, designed to help you track user events and gather valuable insights. This SDK provides essential tools for managing sessions, tracking events, and storing analytics data in a flexible and customizable manner.

## Features

- Session management: Start, track, and end analytics sessions.
- Event tracking: Record various types of events and their properties.
- Data storage: Store analytics sessions and events for analysis.
- Customizable configuration: Configure analytics behavior based on your needs.
- Extendable architecture: Easily integrate with custom storage solutions.

## Installation

### Swift Package Manager (SPM)

To integrate BasicAnalytics using Swift Package Manager, follow these steps:

1. In Xcode, open your project and navigate to the "File" menu.
2. Select "Swift Packages" and then "Add Package Dependency..."
3. Enter the repository URL: `https://github.com/EgorGaydamak/BasicAnalytics.git`
4. Choose the version you want to use.
5. Click "Next" and then "Finish."

### CocoaPods

To integrate BasicAnalytics using CocoaPods, follow these steps:

1. Install CocoaPods if you haven't already:

   [CocoaPods Installation Guide](https://guides.cocoapods.org/using/getting-started.html#installation)

2. Create a `Podfile` in your project directory if you don't have one.

3. Add the following line to your `Podfile`:

```ruby
pod 'BasicAnalytics'
```
4. Run `pod install`

## Usage

1. Initialize the `Analytics` instance with your desired configuration during app launch.
```swift
let configuration = Configuration(writingKey: "your_writing_key_here")
let analytics = Analytics(configuration: configuration)
```
2. Start a session when the app launches.
```swift
analytics.startSession { result in
    // Handle session start result
}
```
3. Track events throughout the app.
```swift
let event = AnalyticsEvent(name: "ButtonTap", properties: ["ButtonName": "Start"])
analytics.track(event: event)
```
4. End the session when the app is about to terminate.
```swift
analytics.endSession { result in
    // Handle session end result
}
```
5. Retrieve information about the last session.
```swift
analytics.getLastSession { result in
    // Handle last session retrieval result
}
```
6. Erase stored analytics data when needed.
```swift
analytics.eraseStorage { result in
    // Handle storage erasure result
}
```
7. Customize the `Configuration` settings to fit your needs.
```swift
let configuration = Configuration(
    writingKey: "your_writing_key_here",
    storageBatchSize: 20,
    customStorage: CustomAnalyticsStorage()
)
let analytics = Analytics(configuration: configuration)
```
For more information and developer documentation feel free to open swift files. They are well documented.
