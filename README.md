# EvolvSwiftSDK
This SDK is designed to be integrated into projects to allow for optimizing with Evolv.

## Installation
### CocoaPods
[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate EvolvSwiftSDK into your Xcode project using CocoaPods, specify it in your Podfile:
```ruby
pod 'EvolvSwiftSDK'
```

### Swift Package Manager
The [Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.
```swift
dependencies: [
    .package(url: "https://github.com/evolv-ai/ios-sdk.git", .upToNextMajor(from: "1.0.0"))
]
```

## Run example app
Clone the repository.
```
$ git clone https://github.com/evolv-ai/ios-sdk.git
```
Open `EvolvSwiftSDK.xcworkspace`, choose `EvolvAppExample` target and hit Run.
