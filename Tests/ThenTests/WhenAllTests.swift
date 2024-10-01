//
//  WhenAllTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Testing
import Foundation
import Then

@Suite
actor WhenAllTests {
    
    @Test
    func whenAllAllSynchronousPromises() async {
        let result = await withCheckedContinuation { continuation in
            Promises.whenAll(Promise(1), Promise(2), Promise(3), Promise(4)).then { array in
                continuation.resume(returning: array)
            }
        }
        #expect(result == [1, 2, 3, 4])
    }

    @Test
    func whenAll() async {
        let result = await withCheckedContinuation { continuation in
            let promise4 = Promise { resolve, _ in
                waitTime(0.1) {
                    resolve(4)
                }
            }
            Promises.whenAll(promise1(), promise2(), promise3(), promise4).then { array in
                continuation.resume(returning: array)
            }
        }
        #expect(result == [1, 2, 3, 4])
    }
    
    @Test
    func whenAllEmpty() async {
        let result = await withCheckedContinuation { continuation in
            Promises.whenAll([]).then { (array: [Int]) in
                continuation.resume(returning: array)
            }
        }
        #expect(result == [])
    }
    
    @Test
    func testWhenAllArray() async {
        let result = await withCheckedContinuation { continuation in
            Promises.whenAll(promiseArray1(), promiseArray2(), promiseArray3()).then { array in
                continuation.resume(returning: array)
            }
        }
        #expect(result == [1, 2, 3, 4, 5, 6, 7, 8, 9])
    }
    
    var array: [Int] = []
    
    @Test
    func testLazyWhenAllLazyTrigger() async {
        let result = await withCheckedContinuation { continuation in
            let promise = Promises.lazyWhenAll(promise1(), promise2()).registerThen { res in
                return res
            }
            waitTime(0.3) {
                promise.then { res in
                    continuation.resume(returning: res)
                }
            }
        }
        #expect(result == [1, 2])
    }
  
    private let concurrentQueue = DispatchQueue(
        label: "then.whenAll.test.concurrent",
        qos: .userInitiated,
        attributes: .concurrent)
    
    @Test
    func testWhenAllAllAsynchronous() async {
        let values = (1...10).map { $0 }
        let promises: [Promise<Int>] = values.map { value in
            return Promise { fulfill, _ in
                self.concurrentQueue.async {
                    fulfill(value)
                }
            }
        }
        let result = await withCheckedContinuation { continuation in
            Promises.whenAll(promises).then { array in
                continuation.resume(returning: array)
            }
        }
        #expect(Set(result) == Set(values))
    }
    
    @Test
    func testLazyWhenAllAllAsynchronous() async {
        let values = (1...10).map { $0 }
        let promises: [Promise<Int>] = values.map { value in
            return Promise { fulfill, _ in
                self.concurrentQueue.async {
                    fulfill(value)
                }
            }
        }
        let result = await withCheckedContinuation { continuation in
            Promises.lazyWhenAll(promises).then { array in
                continuation.resume(returning: array)
            }
        }
        #expect(Set(result) == Set(values))
    }
    
    @Test
    func testWhenAllCallsOnErrorWhenOneFailsSynchronous() async {
        let promise1 = Promise<Void> { _, reject in
            reject(MyError.defaultError)
        }
        let promise2 = Promise { resolve, _ in
            resolve(())
        }
        var onErrorCalled = false
        let result = await withCheckedContinuation { continuation in
            Promises.whenAll(promise1, promise2)
                .then { _ in
                    continuation.resume(returning: "then")
                }.onError { _ in
                    onErrorCalled = true
                }.finally {
                    continuation.resume(returning: "finally")
                }
        }
        #expect(onErrorCalled)
        #expect(result == "finally")
    }
    
    @Test
    func testWhenAllCallsOnErrorWhenOneFailsAsynchronous() async {
        let promise1 = Promise<Void> { _, reject in
            waitTime(0.2) {
                reject(MyError.defaultError)
            }
        }
        
        let promise2 = Promise { resolve, _ in
            waitTime(0.1) {
                resolve(())
            }
        }
        
        var onErrorCalled = false
        let result = await withCheckedContinuation { continuation in
            Promises.whenAll(promise1, promise2)
                .then { _ in
                    continuation.resume(returning: "then")
                }.onError { _ in
                    onErrorCalled = true
                }.finally {
                    continuation.resume(returning: "finally")
                }
        }
        #expect(onErrorCalled)
        #expect(result == "finally")
    }
}
