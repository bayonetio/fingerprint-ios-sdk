# fingerprint-ios-sdk
The *fingerprint-ios-sdk* is a library for *iOS* that determines the device's fingerprint and store it in our backend.

This project was developed with *Swift 5.6*.

## Usage

### Installation
You have to add the dependency reference in your *iOS* project.

```swift
// Package.swift
let package = Package(
  // ...
  dependencies: [
    .package(url: "https://github.com/bayonetio/fingerprint-ios-sdk", from: "X.X:X")
  ]
  // ...
)
```

```rb
# Podfile
pod 'Fingerprint', '~> X.X.X'
```

### Integrate to your code

```swift
import Fingerprint

// Creates Fingerprint client
let fingerprintService = FingerprintService("<your-api-key>")

do {
    let token = try await fingerprintService.analyze()
    print(token.bayonetID)
} catch {
    // process error
}
```

## Create a pod package
```sh
# Login into cocoapods
pod trunk register your@email.com 'your name' --description='description of this session'
```

Previous to generate the pod, you have to create the version in the repository defined in your Podspec file:
```sh
# Create the git tag version
git tag -a X.X.X -m "description of the version"

# Push to repository
git push --tags
```

```sh
# Verify the podspec file
pod spec lint Fingerprint.podspec

# Upload the pod to cocoapods
pod trunk push
```
