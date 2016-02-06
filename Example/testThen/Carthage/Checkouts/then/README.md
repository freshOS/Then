# then
Swift Async code made simple

## Turn this
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
```
🙉🙈🙊#callbackHell

## into ... this !

```swift
fetchUserId()
    .then(fetchUserNameFromId)
    .then(fetchUserFollowStatusFromName)
    .then(updateFollowStatus)
    .onError(showErrorPopup)
    .finally(reloadList)
```
## 🎉🎉🎉


## Explanations
This is usually what nested Async calls look like.
Hard to write, hard to read, hard to reason about, a pain to maintain
#callbackHell

then is based on the famous "Promise/Future" pattern, very popular in javascript for example.

then turns your nested calls into sequential actions, the same way we think about them

## Example
```swift
fetchUserId().then { id in
    print("UserID : \(id)")
}.onError { e in
    print("An error occured : \(e)")
}.finally{
    print("Everything is Done :)")
}
```

## Going further 🤓

If we want this to be maintainable, it should read like an english sentence

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
In case you wonder fetchUserId() is a simple function that returns a strongly typed promise :

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
then is part of a series of lightweight libraries aiming to make developping iOs Apps a breeze :
- Layout : https://github.com/s4cha/Stevia
- Json Parsing : https://github.com/s4cha/Arrow
