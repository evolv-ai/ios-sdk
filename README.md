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
    .package(url: "https://github.com/evolv-ai/ios-sdk.git", .upToNextMajor(from: "1.1.0"))
]
```

## Run example app

Clone the repository.

```
$ git clone https://github.com/evolv-ai/ios-sdk.git
```

Open `EvolvSwiftSDK.xcworkspace`, choose `EvolvAppExample` target and hit Run.

---

## What the Example App Demonstrates

This sample app demonstrates how the Evolv AI SDK manages context, allocation, variant switching, and goal tracking in a live test environment. The app connects to an actual experiment and displays live variant behavior and telemetry.

### Variant Behavior Demonstration

- **Example Text Variant**
  - Once the user is confirmed into the test (see "Logged in" below), a text element in the UI will show either:
    - `"Some text"` – the default variant, or
    - `"Alternative Text"` – a test variant.
  - This is based on the user's allocation for the **Example Text** variable.

- **Button Choice Variant**
  - The button at the bottom of the screen will either be:
    - `"button1"` (e.g., left-aligned), or
    - `"button2"` (e.g., right-aligned or differently styled).
  - Controlled by the **Button Choice** variable, served when the user is confirmed.

### 🧠 Context Handling

- **"Logged in" Toggle**
  - When switched on:
    - Adds `logged_in = yes` to context.
    - Confirms the user into the experiment.
    - Evolv keys are only loaded after this step because the test requires `logged_in = yes`.

- **"Age is 25" Toggle**
  - When on: Adds `"age": 25` to the context.
  - When off: Removes the `"age"` key from the context.

- **"Name is Alex" Toggle**
  - When on: Adds `"name": "Alex"` to the context.
  - When off: Removes the `"name"` key from the context.

### Goal Tracking

- Pressing either button fires a `goal_achieved` event to the Evolv backend.
- These events are used to compare variant performance in the **Evolv Manager** dashboard.

### Observing Behavior in Evolv Manager

To see real-time allocation and performance:

- Request access to the **Evolv Manager dashboard**.
- Under **Variants**, you can observe:
  - **Example Text**: `"Some text"` vs `"Alternative Text"`
  - **Button Choice**: `"button1"` vs `"button2"`
- You’ll also be able to monitor conversion events (goals) and how each variant performs.

### Usage Notes for Developers

- The same user ID receives the same treatment (variant combination).
- To test different variants:
  - Restart the app.
  - Provide a **new unique user ID** to the SDK on launch.

This ensures a fresh allocation and a potentially different treatment.
