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
    
    public static func whenAll<T>(_ promises: [Promise<T>], callbackQueue: DispatchQueue? = nil) -> Promise<[T]> {
        return reduceWhenAll(promises, callbackQueue: callbackQueue) { (result, element) in
            result.append(element)
        }
    }
    
    public static func whenAll<T>(_ promises: Promise<T>..., callbackQueue: DispatchQueue? = nil) -> Promise<[T]> {
        return whenAll(promises, callbackQueue: callbackQueue)
    }
    
    // Array version
    
    public static func whenAll<T>(_ promises: [Promise<[T]>], callbackQueue: DispatchQueue? = nil) -> Promise<[T]> {
        return reduceWhenAll(promises, callbackQueue: callbackQueue, updatePartialResult: { (result, element) in
            result.append(contentsOf: element)
        })
    }
    
    public static func whenAll<T>(_ promises: Promise<[T]>..., callbackQueue: DispatchQueue? = nil) -> Promise<[T]> {
        return whenAll(promises, callbackQueue: callbackQueue)
    }
    
    private static func reduceWhenAll<Result, Source>(
        _ promises: [Promise<Source>],
        callbackQueue: DispatchQueue?,
        updatePartialResult: @escaping (_ result: inout [Result], _ element: Source) -> Void) -> Promise<[Result]> {
        
        let p = Promise<[Result]>()
        let ts = ArrayContainer<Result>()
        var error: Error?
        let group = DispatchGroup()
        for p in promises {
            group.enter()
            p.then { element in
                updatePartialResult(&ts.array, element)
                }
                .onError { error = $0 }
                .finally { group.leave() }
        }
        let callingQueue = OperationQueue.current?.underlyingQueue
        let queue = callbackQueue ?? callingQueue ??  DispatchQueue.main
        group.notify(queue: queue) {
            if let e = error {
                p.reject(e)
            } else {
                p.fulfill(ts.array)
            }
        }
        return p
    }
    
    private class ArrayContainer<T> {
        private var _array: [T] = []
        private let lockQueue = DispatchQueue(label: "com.freshOS.then.whenAll.lockQueue", qos: .userInitiated)
        
        var array: [T] {
            get {
                return lockQueue.sync {
                    _array
                }
            }
            set {
                lockQueue.sync {
                    _array = newValue
                }
            }
        }
    }
}
