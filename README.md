# CallbackURLKit

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat
            )](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-ios_osx_tvos-lightgrey.svg?style=flat
             )](https://developer.apple.com/resources/)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat
             )](https://developer.apple.com/swift)
[![Issues](https://img.shields.io/github/issues/phimage/CallbackURLKit.svg?style=flat
           )](https://github.com/phimage/CallbackURLKit/issues)
[![Cocoapod](http://img.shields.io/cocoapods/v/CallbackURLKit.svg?style=flat)](http://cocoadocs.org/docsets/Prephirences/)
[![Join the chat at https://gitter.im/phimage/Prephirences](https://img.shields.io/badge/GITTER-join%20chat-00D06F.svg)](https://gitter.im/phimage/CallbackURLKit?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[<img align="left" src="http://x-callback-url.com/wp-content/uploads/2013/02/copy-xcallback.png" hspace="20">](#logo) Starting to integrate URL scheme in an app,
be complaint with [x-callback-url](http://x-callback-url.com/specifications/) using CallbackURLKit framework.
```swift
CallbackURLKit.registerAction("play") { parameters, success, failure, cancel in
  self.player.play()
  success(..)
}
```
Want to interact with other application which implement also [x-callback-url](http://x-callback-url.com/specifications/) you can also use this framework.

```swift
CallbackURLKit.performAction("googlechrome-x-callback", action: "open", parameters: ["url": "http://www.google.com"])
```

## Installation

### Support CocoaPods

* Into Podfile

```
use_frameworks!

pod "CallbackURLKit"
```

## Usage

(Coming soon)
