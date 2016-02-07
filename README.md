# then [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Join the chat at https://gitter.im/s4cha/then](https://badges.gitter.im/s4cha/then.svg)](https://gitter.im/s4cha/then?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Write maintainable Async code in Swift



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


## Other repos ❤️
then is part of a series of lightweight libraries aiming to make developing iOs Apps a breeze :
- Layout : https://github.com/s4cha/Stevia
- Json Parsing : https://github.com/s4cha/Arrow
