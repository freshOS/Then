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
    
    public static func lazyWhenAll<T>(_ promises: [Promise<T>], callbackQueue: DispatchQueue? = nil) -> Promise<[T]> {
        return lazyReduceWhenAll(promises, callbackQueue: callbackQueue) { (result, element) in
            result.append(element)
        }
    }
    
    public static func lazyWhenAll<T>(_ promises: Promise<T>..., callbackQueue: DispatchQueue? = nil) -> Promise<[T]> {
        return lazyWhenAll(promises, callbackQueue: callbackQueue)
    }
    
    // Array version
    
    public static func whenAll<T>(_ promises: [Promise<[T]>], callbackQueue: DispatchQueue? = nil) -> Promise<[T]> {
        return reduceWhenAll(promises, callbackQueue: callbackQueue) { (result, element) in
            result.append(contentsOf: element)
        }
    }
    
    public static func whenAll<T>(_ promises: Promise<[T]>..., callbackQueue: DispatchQueue? = nil) -> Promise<[T]> {
        return whenAll(promises, callbackQueue: callbackQueue)
    }
    
    public static func lazyWhenAll<T>(_ promises: [Promise<[T]>], callbackQueue: DispatchQueue? = nil) -> Promise<[T]> {
        return lazyReduceWhenAll(promises, callbackQueue: callbackQueue) { (result, element) in
            result.append(contentsOf: element)
        }
    }
    
    public static func lazyWhenAll<T>(
        _ promises: Promise<[T]>...,
        callbackQueue: DispatchQueue? = nil) -> Promise<[T]> {
        return lazyWhenAll(promises, callbackQueue: callbackQueue)
    }
    
    // Private implementations
    
    private static func lazyReduceWhenAll<Result, Source>(
        _ promises: [Promise<Source>],
        callbackQueue: DispatchQueue?,
        updatePartialResult: @escaping (_ result: inout [Result], _ element: Source) -> Void) -> Promise<[Result]> {
        return Promise { fulfill, reject in
            reducePromises(
                promises,
                callbackQueue: callbackQueue,
                fulfill: fulfill,
                reject: reject,
                updatePartialResult: updatePartialResult)
        }
    }
    
    private static func reduceWhenAll<Result, Source>(
        _ promises: [Promise<Source>],
        callbackQueue: DispatchQueue?,
        updatePartialResult: @escaping (_ result: inout [Result], _ element: Source) -> Void) -> Promise<[Result]> {
        
        let p = Promise<[Result]>()
        reducePromises(
            promises,
            callbackQueue: callbackQueue,
            fulfill: p.fulfill,
            reject: p.reject,
            updatePartialResult: updatePartialResult)
        return p
    }
    
    private static func reducePromises<Result, Source>(
        _ promises: [Promise<Source>],
        callbackQueue: DispatchQueue?,
        fulfill: @escaping ([Result]) -> Void,
        reject: @escaping (Error) -> Void,
        updatePartialResult: @escaping (_ result: inout [Result], _ element: Source) -> Void) {
        
        let ts = ArrayContainer<Result>()
        var error: Error?
        let group = DispatchGroup()
        for p in promises {
            group.enter()
            p.then { element in
                ts.updateArray({ updatePartialResult(&$0, element) })
                }
                .onError { error = $0 }
                .finally { group.leave() }
        }
        let callingQueue = OperationQueue.current?.underlyingQueue
        let queue = callbackQueue ?? callingQueue ??  DispatchQueue.main
        group.notify(queue: queue) {
            if let e = error {
                reject(e)
            } else {
                fulfill(ts.array)
            }
        }
    }
    
    private class ArrayContainer<T> {
        private var _array: [T] = []
        private let lockQueue = DispatchQueue(label: "com.freshOS.then.whenAll.lockQueue", qos: .userInitiated)
        
        func updateArray(_ updates: @escaping (_ result: inout [T]) -> Void) {
            lockQueue.async {
                updates(&self._array)
            }
        }
      
        var array: [T] {
            return lockQueue.sync {
                _array
            }
        }
    }
}
