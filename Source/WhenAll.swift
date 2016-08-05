//
//  WhenAll.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation


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
    return whenAll(promises)
}


/// Array version

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
    return whenAll(promises)
}


