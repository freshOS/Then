//
//  WhenAll.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation


public func whenAll<T>(promises:[Promise<T>]) -> Promise<[T]> {
    return Promise { resolve, _ in
        var ts = [T]()
        let group = dispatch_group_create()
        for p in promises {
            dispatch_group_enter(group)
            p.then { r in ts.append(r) }
                .finally { dispatch_group_leave(group) }
        }
        dispatch_group_notify(group, dispatch_get_main_queue()) { resolve(ts) }
    }
}

public func whenAll<T>(promises:Promise<T>...) -> Promise<[T]> {
    return whenAll(promises)
}


/// Array version

public func whenAll<T>(promises:[Promise<[T]>]) -> Promise<[T]> {
    return Promise { resolve, _ in
        var ts = [T]()
        let group = dispatch_group_create()
        for p in promises {
            dispatch_group_enter(group)
            p.then { r in ts.appendContentsOf(r) }
                .finally { dispatch_group_leave(group) }
        }
        dispatch_group_notify(group, dispatch_get_main_queue()) { resolve(ts) }
    }
}

public func whenAll<T>(promises:Promise<[T]>...) -> Promise<[T]> {
    return whenAll(promises)
}


