//
//  Promise+Zip.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 10/08/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

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
}
