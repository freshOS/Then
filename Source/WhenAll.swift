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
    
    public static func zip<T, U>(_ p1: Promise<T>, _ p2: Promise<U>) -> (Promise<(T, U)>) {
        let p = Promise<(T, U)>()
        var t: T!
        var u: U!
        var error: Error?
        let group = DispatchGroup()
        
        //p1
        group.enter()
        p1.then { t = $0 }
            .onError { error = $0 }
            .finally { group.leave() }
        
        //p2
        group.enter()
        p2.then { u = $0 }
            .onError { error = $0 }
            .finally { group.leave() }
        
        group.notify(queue: DispatchQueue.main) {
            if let e = error {
                p.reject(e)
            } else {
                p.fulfill((t, u))
            }
        }
        return p
    }
    
    public static func zip<T, U, V>(_ p1: Promise<T>, _ p2: Promise<U>, _ p3: Promise<V>) -> (Promise<(T, U, V)>) {
        let p = Promise<(T, U, V)>()
        var t: T!
        var u: U!
        var v: V!
        var error: Error?
        let group = DispatchGroup()
        
        //p1
        group.enter()
        p1.then { t = $0 }
            .onError { error = $0 }
            .finally { group.leave() }
        
        //p2
        group.enter()
        p2.then { u = $0 }
            .onError { error = $0 }
            .finally { group.leave() }
        
        //p3
        group.enter()
        p3.then { v = $0 }
            .onError { error = $0 }
            .finally { group.leave() }
        
        group.notify(queue: DispatchQueue.main) {
            if let e = error {
                p.reject(e)
            } else {
                p.fulfill((t, u, v))
            }
        }
        return p
    }
    
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
