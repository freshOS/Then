![Then](https://raw.githubusercontent.com/freshOS/then/master/banner.png)

# then
[![Language: Swift 2 and 3|4](https://img.shields.io/badge/language-swift2|3|4-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platform: iOS 8+/macOS10.11](https://img.shields.io/badge/platform-iOS%208%2B|OSX|tvOS-blue.svg?style=flat) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Cocoapods compatible](https://img.shields.io/badge/Cocoapods-compatible-4BC51D.svg?style=flat)](https://cocoapods.org)
[![Build Status](https://www.bitrise.io/app/2c01c6f861c526d9.svg?token=H26l2Nish0WWF6yfDTL1kA&branch=master)](https://www.bitrise.io/app/2c01c6f861c526d9)
[![codebeat badge](https://codebeat.co/badges/768d3017-1e65-47e0-b287-afcb8954a1da)](https://codebeat.co/projects/github-com-s4cha-then)
[![Join the chat at https://gitter.im/s4cha/then](https://badges.gitter.im/s4cha/then.svg)](https://gitter.im/s4cha/then?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/freshOS/then/blob/master/LICENSE)
[![Release version](https://img.shields.io/badge/release-2.2-blue.svg)]()

[Reason](#why) - [Example](#example) -  [Documentation](#documentation) - [Installation](#installation)

```swift
fetchUserId().then { id in
    print("UserID : \(id)")
}.onError { e in
    print("An error occured : \(e)")
}.finally {
    print("Everything is Done :)")
}
```

```swift
  let userId = try! await(fetchUserId())
```

Because async code is hard to write, hard to read, hard to reason about.   **A pain to maintain**

## Try it
then is part of [freshOS](http://freshos.org) iOS toolset. Try it in an example App !  <a class="github-button" href="https://github.com/freshOS/StarterProject/archive/master.zip" data-icon="octicon-cloud-download" data-style="mega" aria-label="Download freshOS/StarterProject on GitHub">Download Starter Project</a>

## How
By using a **then** keyword that enables you to write aSync code that *reads like an English sentence*  
Async code is now **concise**, **flexible** and **maintainable** ❤️

## What
- [x] Based on the popular `Promise` / `Future` concept
- [x] `Async` / `Await`
- [x] `progress` `race` `recover` `validate` `retry` `bridgeError` `chain` `noMatterWhat` ...
- [x] Strongly Typed
- [x] Pure Swift & Lightweight

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


## Documentation

1. [Writing your own Promise](#writing-your-own-promise-💪)
2. [Progress](#progress)
3. [Registering a block for later](#registering-a-block-for-later)
4. [Returning a rejecting promise](#returning-a-rejecting-promise)
5. [Common Helpers](#common-helpers)
  1. [race](#race)
  2. [recover](#recover)
  3. [validate](#validate)
  4. [retry](#retry)
  5. [bridgeError](#bridgeError)
  6. [whenAll](#whenAll)
  7. [chain](#chain)
  8. [noMatterWhat](#nomatterwhat)
  9. [unwrap](#unwrap)
6. [AsyncTask](#asynctask)
7. [Async/Await](#async/await)

### Writing your own Promise 💪
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

### Progress

As for `then` and `onError`, you can also call a `progress` block for things like uploading an avatar for example.

```swift
uploadAvatar().progress { p in
  // Here update progressView for example
}
.then(doSomething)
.onError(showErrorPopup)
.finally(doSomething)
```

### Registering a block for later
Our implementation slightly differs from the original javascript Promises. Indeed, they do not start right away, on purpose. Calling `then`, `onError`, or `finally` will start them automatically.

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
Note that `onError` and `finally` also have their non-starting counterparts : `registerOnError` and `registerFinally`.

### Returning a rejecting promise

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

### Common Helpers

#### Race

With `race`, you can send multiple tasks and get the result of the first one coming back :
```swift
race(task1, task2, task3).then { work in
  // The first result !
}
```

#### Recover

With `.recover`, you can provide a fallback value for a failed Promise.  
You can :
  - Recover with a value
  - Recover with a value for a specific Error type
  - Return a value from a block, enabling you to test the type of error and return distinct values.
  - Recover with another Promise with the same Type

```swift
.recover(with: 12)
.recover(MyError.defaultError, with: 12)
.recover { e in
  if e == x { return 32 }
  if e == y { return 143 }
  throw MyError.defaultError
}
.recover(with: Promise<Int>.resolve(56))
```
Note that in the block version you can also throw your own error \o/


#### Validate

With `.validate`, you can break the promise chain with an assertion block.

You can:
  - Insert assertion in Promise chain
  - Insert assertion and return you own Error

For instance checking if a user is allowed to drink alcohol :
```swift
fetchUserAge()
.validate { $0 > 18 }
.then { age in
  // Offer a drink
}

.validate(withError: MyError.defaultError, { $0 > 18 })`
```
A failed validation will retrun a `PromiseError.validationFailed` by default.

#### Retry

With `retry`, you can restart a failed Promise X number of times.
```swift
doSomething()
  .retry(10)
  .then { v in
   // YAY!
  }.onError { e in
    // Failed 10 times in a row
  }
```

#### BridgeError

With `.bridgeError`, you can intercept a low-level Error and return your own high level error.
The classic use-case is when you receive an api error and you bridge it to your own domain error.

You can:
  - Catch all errors and use your own Error type
  - Catch only a specific error

```swift
.bridgeError(to: MyError.defaultError)
.bridgeError(SomeError, to: MyError.defaultError)
```

#### WhenAll

With `.whenAll`, you can combine multiple calls and get all the results when all the promises are fulfilled :

```swift
whenAll(fetchUsersA(),fetchUsersB(), fetchUsersC()).then { allUsers in
  // All the promises came back
}
```

#### Chain

With `chain`, you can add behaviours without changing the chain of Promises.

A common use-case is for adding Analytics tracking like so:

```swift
extension Photo {
    public func post() -> Async<Photo> {
        return api.post(self).chain { _ in
            Tracker.trackEvent(.postPicture)
        }
    }
}
```

#### NoMatterWhat

With `noMatterWhat` you can add code to be executed in the middle of a promise chain, no matter what happens.

```swift
func fetchNext() -> Promise<[T]> {
    isLoading = true
    call.params["page"] = page + 1
    return call.fetch()
        .registerThen(parseResponse)
        .resolveOnMainThread()
        .noMatterWhat {
            self.isLoading = false
    }
}
```

#### Unwrap

With `unwrap` you can transform an optional into a promise :

```swift    
func fetch(userId: String?) -> Promise<Void> {
   return unwrap(userId).then {
        network.get("/user/\($0)")
    }
}
```
Unwrap will fail the promise chain with `unwrappingFailed` error in case of a nil value :)

### AsyncTask
`AsyncTask` and `Async<T>` typealisases are provided for those of us who think that Async can be clearer than `Promise`.
Feel free to replace `Promise<Void>` by `AsyncTask` and `Promise<T>` by `Async<T>` wherever needed.  
This is purely for the eyes :)


### Async/Await

`await` waits for a promise to complete synchronously and yields the result :

```swift
let photos = try! await(getPhotos())
```

`async` takes a block and wraps it in a background Promise.

```swift
async {
  let photos = try await(getPhotos())
}
```
Notice how we don't need the `!` anymore because `async` will catch the errors.


Together, `async`/`await` enable us to write asynchronous code in a synchronous manner :

```swift
async {
  let userId = try await(fetchUserId())
  let userName = try await(fetchUserNameFromId(userId))
  let isFollowed = try await(fetchUserFollowStatusFromName(userName))
  return isFollowed
}.then { isFollowed in
  print(isFollowed)
}.onError { e in
  // handle errors
}
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

[S4cha](https://github.com/S4cha), [Max Konovalov](https://github.com/maxkonovalov), [YannickDot](https://github.com/YannickDot), [Damien](https://github.com/damien-nd),
[piterlouis](https://github.com/piterlouis)

## Swift Version
Swift 2 -> version **1.4.2**  
Swift 3 -> version **2.2.5**  
Swift 4 -> version **3.0.0**

<!-- Place this tag in your head or just before your close body tag. -->
<script async defer src="https://buttons.github.io/buttons.js"></script>
