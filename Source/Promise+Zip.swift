//
//  Promise+Zip.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 10/08/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation
import Dispatch

extension Promises {
    
    public static func zip<T, U>(_ p1: Promise<T>, _ p2: Promise<U>) -> Promise<(T, U)> {
        
        let p = Promise<(T, U)>()
        var t: T!
        var u: U!
        var error: Error?
        let group = DispatchGroup()
        
        // We run the promises concurrently on a concurent queue and go back
        // to a local queue to read/modify global variables.
        // .barrier blocks concurrency so that we can write values
        // without then beeing read at the same time.
        // It pauses reads until write are done
        let concurentQueue = DispatchQueue(label: "then.zip.concurrent", attributes: .concurrent)
        let localQueue = DispatchQueue(label: "then.zip.local", attributes: .concurrent)
        
        group.enter()
        concurentQueue.async {
            p1.then { aT in
                localQueue.async(flags: .barrier) {
                    t = aT
                }
                }.onError { e in
                    localQueue.async(flags: .barrier) {
                        error = e
                    }
                }.finally {
                    localQueue.async { // barrier needed?
                        group.leave()
                    }
            }
        }
        
        group.enter()
        concurentQueue.async {
            p2.then { aU in
                localQueue.async(flags: .barrier) {
                    u = aU
                }
                }.onError { e in
                    localQueue.async(flags: .barrier) {
                        error = e
                    }
                }.finally {
                    localQueue.async {
                        group.leave()
                    }
            }
        }
        
        let callingQueue = OperationQueue.current?.underlyingQueue
        let queue = callingQueue ?? DispatchQueue.main
        group.notify(queue: queue) {
            localQueue.async {
                if let e = error {
                    p.reject(e)
                } else {
                    p.fulfill((t, u))
                }
            }
        }
        return p
    }
    
    // zip 3
    public static func zip<T, U, V>(_ p1: Promise<T>, _ p2: Promise<U>, _ p3: Promise<V>) -> Promise<(T, U, V)> {
        return zip(zip(p1, p2), p3).then { ($0.0, $0.1, $1) }
    }
    
    // zip 4
    public static func zip<A, B, C, D>(_ p1: Promise<A>,
                                       _ p2: Promise<B>,
                                       _ p3: Promise<C>,
                                       _ p4: Promise<D>) -> Promise<(A, B, C, D)> {
        return zip(zip(p1, p2, p3), p4).then { ($0.0, $0.1, $0.2, $1) }
    }
    
    // zip 5
    public static func zip<A, B, C, D, E>(_ p1: Promise<A>,
                                          _ p2: Promise<B>,
                                          _ p3: Promise<C>,
                                          _ p4: Promise<D>,
                                          _ p5: Promise<E>) -> Promise<(A, B, C, D, E)> {
        return zip(zip(p1, p2, p3, p4), p5).then { ($0.0, $0.1, $0.2, $0.3, $1) }
    }
    
    // zip 6 swiftlint:disable function_parameter_count
    public static func zip<A, B, C, D, E, F>(_ p1: Promise<A>,
                                             _ p2: Promise<B>,
                                             _ p3: Promise<C>,
                                             _ p4: Promise<D>,
                                             _ p5: Promise<E>,
                                             _ p6: Promise<F>) -> Promise<(A, B, C, D, E, F)> {
        return zip(zip(p1, p2, p3, p4, p5), p6 ).then { ($0.0, $0.1, $0.2, $0.3, $0.4, $1) }
    }
    
    // zip 7
    public static func zip<A, B, C, D, E, F, G>(_ p1: Promise<A>,
                                                _ p2: Promise<B>,
                                                _ p3: Promise<C>,
                                                _ p4: Promise<D>,
                                                _ p5: Promise<E>,
                                                _ p6: Promise<F>,
                                                _ p7: Promise<G>) -> Promise<(A, B, C, D, E, F, G)> {
        return zip(zip(p1, p2, p3, p4, p5, p6), p7).then { ($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $1) }
    }
    
    // zip 8
    public static func zip<A, B, C, D, E, F, G, H>(_ p1: Promise<A>,
                                                   _ p2: Promise<B>,
                                                   _ p3: Promise<C>,
                                                   _ p4: Promise<D>,
                                                   _ p5: Promise<E>,
                                                   _ p6: Promise<F>,
                                                   _ p7: Promise<G>,
                                                   _ p8: Promise<H>) -> Promise<(A, B, C, D, E, F, G, H)> {
        return zip(zip(p1, p2, p3, p4, p5, p6, p7), p8).then { ($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $1) }
    }
    // swiftlint:enable function_parameter_count
}
