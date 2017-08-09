//
//  WhenAll.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation
import Dispatch

public class Promises {}

extension Promises {
    
    public static func whenAll<T>(_ promises: [Promise<T>]) -> Promise<[T]> {
        let p = Promise<[T]>()
        var ts = [T]()
        var error: Error?
        let group = DispatchGroup()
        for p in promises {
            group.enter()
            p.then { ts.append($0) }
                .onError { error = $0 }
                .finally { group.leave() }
        }
        group.notify(queue: DispatchQueue.main) {
            if let e = error {
                p.reject(e)
            } else {
                p.fulfill(ts)
            }
        }
        return p
    }
    
    public static func whenAll<T>(_ promises: Promise<T>...) -> Promise<[T]> {
        return whenAll(promises)
    }
    
    // Array version
    
    public static func whenAll<T>(_ promises: [Promise<[T]>]) -> Promise<[T]> {
        let p = Promise<[T]>()
        var ts = [T]()
        var error: Error?
        let group = DispatchGroup()
        for p in promises {
            group.enter()
            p.then { ts.append(contentsOf: $0) }
                .onError { error = $0 }
                .finally { group.leave() }
        }
        group.notify(queue: DispatchQueue.main) {
            if let e = error {
                p.reject(e)
            } else {
                p.fulfill(ts)
            }
        }
        return p
    }
    
    public static func whenAll<T>(_ promises: Promise<[T]>...) -> Promise<[T]> {
        return whenAll(promises)
    }
}
