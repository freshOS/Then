# then 🎬
[![Language: Swift 2](https://img.shields.io/badge/language-swift2-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platform: iOS 8+](https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Cocoapods compatible](https://img.shields.io/badge/Cocoapods-compatible-4BC51D.svg?style=flat)](https://cocoapods.org)
[![Build Status](https://www.bitrise.io/app/ea9933b066f6a2c4.svg?token=i7LK0uQC1rVuXhDq1iskYg&branch=master)](https://www.bitrise.io/app/ea9933b066f6a2c4)
[![codebeat badge](https://codebeat.co/badges/768d3017-1e65-47e0-b287-afcb8954a1da)](https://codebeat.co/projects/github-com-s4cha-then)
[![Join the chat at https://gitter.im/s4cha/then](https://badges.gitter.im/s4cha/then.svg)](https://gitter.im/s4cha/then?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/s4cha/then/blob/master/LICENSE)
[![Release version](https://img.shields.io/badge/release-1.1-blue.svg)]()

Elegant Async code for Swift

```swift
fetchUserId().then { id in
    print("UserID : \(id)")
}.onError { e in
    print("An error occured : \(e)")
}.finally {
    print("Everything is Done :)")
}
```

## Before
```swift
fetchUserId({ id in
    fetchUserNameFromId(id, success: { name in
        fetchUserFollowStatusFromName(name, success: { isFollowed in
            // The three calls in a row succeeded YAY!
            reloadList()
        }, failure: { error in
            // Fetching user ID failed
            reloadList()
        })
    }, failure: { error in
        // Fetching user name failed
        reloadList()
    })
}) {  error in
    // Fetching user follow status failed
    reloadList()
}
🙉🙈🙊#callbackHell
```

----

## After

```swift
fetchUserId()
    .then(fetchUserNameFromId)
    .then(fetchUserFollowStatusFromName)
    .then(updateFollowStatus)
    .onError(showErrorPopup)
    .finally(reloadList)
```
## 🎉🎉🎉

## Why
Because async code is hard to write, hard to read, hard to reason about.  
**A pain to maintain**

## How
By using a **then** keyword that enables you to write aSync code that *reads like an English sentence*  
Async code is now **concise**, **flexible** and **maintainable** ❤️


## What
- [x] Based on the popular Promise/Future concept
- [x] Lightweight (1 file ~100lines)
- [x] Pure Swift
- [x] No magic involved
- [x] Strongly Typed
- [x] Chainable

## Installation

### Cocoapods
```swift
pod 'thenPromise'
use_frameworks!
```

#### Carthage
```
github "s4cha/then"
```
#### Manually
Simply Copy and Paste Promise.swift in your Xcode Project :)
https://github.com/s4cha/then/blob/master/Code/then/Promise.swift

#### As A Framework
Grab this repository and build the Framework target on the example project. Then Link against this framework.

## Example
```swift
fetchUserId().then { id in
    print("UserID : \(id)")
}.onError { e in
    print("An error occured : \(e)")
}.finally {
    print("Everything is Done :)")
}
```

## Going further 🤓

If we want this to be **maintainable**, it should read *like an english sentence*  
We can do this by extracting our blocks into separate functions :

```swift
fetchUserId()
    .then(printUserID)
    .onError(showErrorPopup)
    .finally(reloadList)
```

This is now **concise**, **flexible**, **maintainable** and it reads like an english sentence <3  
Mental sanity saved
// #goodbyeCallbackHell


## Writing your own Promise 💪
Wondering what fetchUserId() is?  
It is a simple function that returns a strongly typed promise :

```swift
func fetchUserId() -> Promise<Int> {
    return Promise { resolve, reject in
        print("fetching user Id ...")
        wait { resolve(object: 1234) }
    }
}
```
Here you would typically replace the dummy wait function by your network request <3


## Contributors

[S4cha](https://github.com/S4cha), [YannickDot](https://github.com/YannickDot), [Damien](https://github.com/damien-nd),
[piterlouis](https://github.com/piterlouis)


## Other repos ❤️
then is part of a series of lightweight libraries aiming to make developing iOS Apps a *breeze* :
- Layout : [Stevia](https://github.com/s4cha/Stevia)
- Json Parsing : [Arrow](https://github.com/s4cha/Arrow)
- JSON WebServices : [ws](https://github.com/s4cha/ws)
