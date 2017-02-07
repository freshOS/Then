![Then](https://raw.githubusercontent.com/freshOS/then/master/banner.png)

# then
[![Language: Swift 2 and 3](https://img.shields.io/badge/language-swift2|3-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platform: iOS 8+](https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Cocoapods compatible](https://img.shields.io/badge/Cocoapods-compatible-4BC51D.svg?style=flat)](https://cocoapods.org)
[![Build Status](https://www.bitrise.io/app/ea9933b066f6a2c4.svg?token=i7LK0uQC1rVuXhDq1iskYg&branch=master)](https://www.bitrise.io/app/ea9933b066f6a2c4)
[![codebeat badge](https://codebeat.co/badges/768d3017-1e65-47e0-b287-afcb8954a1da)](https://codebeat.co/projects/github-com-s4cha-then)
[![Join the chat at https://gitter.im/s4cha/then](https://badges.gitter.im/s4cha/then.svg)](https://gitter.im/s4cha/then?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/freshOS/then/blob/master/LICENSE)
[![Release version](https://img.shields.io/badge/release-2.0-blue.svg)]()

[Reason](#why) - [Example](#example) - [Installation](#installation)

```swift
fetchUserId().then { id in
    print("UserID : \(id)")
}.onError { e in
    print("An error occured : \(e)")
}.finally {
    print("Everything is Done :)")
}
```
Because async code is hard to write, hard to read, hard to reason about.   **A pain to maintain**

## Try it
then is part of [freshOS](http://freshos.org) iOS toolset. Try it in an example App !  <a class="github-button" href="https://github.com/freshOS/StarterProject/archive/master.zip" data-icon="octicon-cloud-download" data-style="mega" aria-label="Download freshOS/StarterProject on GitHub">Download Starter Project</a>

## How
By using a **then** keyword that enables you to write aSync code that *reads like an English sentence*  
Async code is now **concise**, **flexible** and **maintainable** ❤️

## What
- [x] Based on the popular Promise / Future concept
- [x] Strongly Typed
- [x] Pure Swift & Lightweight
- [x] Chainable
- [x] Progress support


## Example
### Before
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

### After

```swift
fetchUserId()
    .then(fetchUserNameFromId)
    .then(fetchUserFollowStatusFromName)
    .then(updateFollowStatus)
    .onError(showErrorPopup)
    .finally(reloadList)
```
## 🎉🎉🎉


## Going further 🤓

```swift
fetchUserId().then { id in
    print("UserID : \(id)")
}.onError { e in
    print("An error occured : \(e)")
}.finally {
    print("Everything is Done :)")
}
```

If we want this to be **maintainable**, it should read *like an English sentence*  
We can do this by extracting our blocks into separate functions:

```swift
fetchUserId()
    .then(printUserID)
    .onError(showErrorPopup)
    .finally(reloadList)
```

This is now **concise**, **flexible**, **maintainable**, and it reads like an English sentence <3  
Mental sanity saved
// #goodbyeCallbackHell


## Writing your own Promise 💪
Wondering what fetchUserId() is?  
It is a simple function that returns a strongly typed promise :

```swift
func fetchUserId() -> Promise<Int> {
    return Promise { resolve, reject in
        print("fetching user Id ...")
        wait { resolve(1234) }
    }
}
```
Here you would typically replace the dummy wait function by your network request <3

## Progress

As for `then` and `onError`, you can also call a `progress` block for things like uploading an avatar for example.

```swift
uploadAvatar().progress { p in
  // Here update progressView for example
}
.then(doSomething)
.onError(showErrorPopup)
.finally(doSomething)
```

## Registering a block for later
Calling `then` starts a promise if it is not already started.
In some cases, we only want to register some code for later.
For instance, in the case of JSON to Swift model parsing, we often want to attach parsing blocks to JSON promises, but without starting them.

In order to do that we need to use `registerThen` instead. It's the exact same thing as `then` without starting the promise right away.

```swift
let fetchUsers:Promise<[User]> = fetchUsersJSON().registerThen(parseUsersJSON)

// Here promise is not launched yet \o/

// later...
fetchUsers.then { users in
    // YAY
}
```

## Bonus : whenAll

`whenAll` calls you back when all the promises passed are fullfiled :
```swift
whenAll(fetchUsersA(),fetchUsersB(), fetchUsersC()).then { allUsers in
  // All the promises came back
}
```

## Returning a rejecting promise

Oftetimes we need to return a rejecting promise as such :

```swift
return Promise { _, reject in
  reject(anError)
}
```

This can be written with the following shortcut :
```swift
return Promise.reject(error:anError)
```

## Installation

### Cocoapods
```swift
pod 'thenPromise'
use_frameworks!
```

#### Carthage
```
github "freshOS/then"
```
#### Manually
Simply Copy and Paste `.swift` files in your Xcode Project :)

#### As A Framework
Grab this repository and build the Framework target on the example project. Then Link against this framework.


## Contributors

[S4cha](https://github.com/S4cha), [YannickDot](https://github.com/YannickDot), [Damien](https://github.com/damien-nd),
[piterlouis](https://github.com/piterlouis)

## Swift Version
Swift 2 -> version **1.4.2**  
Swift 3 -> version **2.0.3**

<!-- Place this tag in your head or just before your close body tag. -->
<script async defer src="https://buttons.github.io/buttons.js"></script>
