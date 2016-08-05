//
//  WhenAll.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation


<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
public func whenAll<T>(promises: [Promise<T>]) -> Promise<[T]> {
    return Promise { resolve, reject in
        var ts = [T]()
        var error: ErrorType?
        let group = dispatch_group_create()
        for p in promises {
            dispatch_group_enter(group)
            p.then { ts.append($0) }
                .onError { error = $0 }
                .finally { dispatch_group_leave(group) }
        }
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            if let e = error {
                reject(e)
            } else {
                resolve(ts)
            }
        }
    }
}

public func whenAll<T>(promises: Promise<T>...) -> Promise<[T]> {
=======
public func whenAll<T>(_ promises:[Promise<T>]) -> Promise<[T]> {
    return Promise { resolve, _ in
        var ts = [T]()
        let group = DispatchGroup()
        for p in promises {
            group.enter()
            p.then { r in ts.append(r) }
                .finally { group.leave() }
        }
        group.notify(queue: DispatchQueue.main) { resolve(ts) }
    }
}

public func whenAll<T>(_ promises:Promise<T>...) -> Promise<[T]> {
>>>>>>> Migrates to swift 3
    return whenAll(promises)
}


// Array version

<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
public func whenAll<T>(promises: [Promise<[T]>]) -> Promise<[T]> {
    return Promise { resolve, reject in
        var ts = [T]()
        var error: ErrorType?
        let group = dispatch_group_create()
        for p in promises {
            dispatch_group_enter(group)
            p.then { ts.appendContentsOf($0) }
                .onError { error = $0 }
                .finally { dispatch_group_leave(group) }
        }
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            if let e = error {
                reject(e)
            } else {
                resolve(ts)
            }
        }
    }
}

public func whenAll<T>(promises: Promise<[T]>...) -> Promise<[T]> {
=======
public func whenAll<T>(_ promises:[Promise<[T]>]) -> Promise<[T]> {
    return Promise { resolve, _ in
        var ts = [T]()
        let group = DispatchGroup()
        for p in promises {
            group.enter()
            p.then { r in ts.append(contentsOf: r) }
                .finally { group.leave() }
        }
        group.notify(queue: DispatchQueue.main) { resolve(ts) }
    }
}

public func whenAll<T>(_ promises:Promise<[T]>...) -> Promise<[T]> {
>>>>>>> Migrates to swift 3
    return whenAll(promises)
}
