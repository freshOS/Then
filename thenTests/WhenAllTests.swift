//
//  WhenAllTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import XCTest
import then

class WhenAllTests: XCTestCase {
    
    func testWhenAllAllSynchronousPromises() {
        let block = expectation(description: "Block called")
        Promises.whenAll(Promise(1), Promise(2), Promise(3), Promise(4)).then { array in
            XCTAssertEqual(array, [1, 2, 3, 4])
            block.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testWhenAll() {
        let block = expectation(description: "Block called")
        let promise4 = Promise { resolve, _ in
            waitTime(0.1) {
                resolve(4)
            }
        }
        Promises.whenAll(promise1(), promise2(), promise3(), promise4).then { array in
            XCTAssertEqual(array, [1, 2, 3, 4])
            block.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testWhenAllEmpty() {
        let block = expectation(description: "Block called")
        Promises.whenAll([]).then { (array: [Int]) in
            XCTAssertEqual(array, [])
            block.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testWhenAllArray() {
        let block = expectation(description: "Block called")
        Promises.whenAll(promiseArray1(), promiseArray2(), promiseArray3()).then { array in
            XCTAssertEqual(array, [1, 2, 3, 4, 5, 6, 7, 8, 9])
            block.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testLazyWhenAllLazyTrigger() {
        var array: [Int] = []
        let block = expectation(description: "Block called")
        let promise = Promises.lazyWhenAll(promise1(), promise2()).registerThen {
            array = $0
            XCTAssertEqual(array, [1, 2])
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(array, [])
            promise.then {
                block.fulfill()
            }
        }
        
        waitForExpectations(timeout: 0.6, handler: nil)
    }
  
    private let concurrentQueue = DispatchQueue(
        label: "then.whenAll.test.concurrent",
        qos: .userInitiated,
        attributes: .concurrent)
    func testWhenAllAllAsynchronous() {
        let values = (1...10).map { $0 }
        let promises: [Promise<Int>] = values.map { value in
            return Promise { fulfill, _ in
                self.concurrentQueue.async {
                    fulfill(value)
                }
            }
        }
        let block = expectation(description: "Block called")
        Promises.whenAll(promises).then { array in
            XCTAssertEqual(Set(array), Set(values))
            block.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testLazyWhenAllAllAsynchronous() {
        let values = (1...10).map { $0 }
        let promises: [Promise<Int>] = values.map { value in
            return Promise { fulfill, _ in
                self.concurrentQueue.async {
                    fulfill(value)
                }
            }
        }
        let block = expectation(description: "Block called")
        Promises.lazyWhenAll(promises).then { array in
            XCTAssertEqual(Set(array), Set(values))
            block.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testWhenAllCallsOnErrorWhenOneFailsSynchronous() {
        let block = expectation(description: "Block called")
        let finallyBlock = expectation(description: "Finally called")
        let promise1 = Promise { _, reject in
            reject(MyError.defaultError)
        }
        
        let promise2 = Promise<Void> { resolve, _ in
            resolve()
        }
        
        Promises.whenAll(promise1, promise2)
            .then { _ in
                XCTFail("testWhenAllCallsOnErrorWhenOneFailsSynchronous failed")
            }.onError { _ in
                block.fulfill()
            }.finally {
                finallyBlock.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testWhenAllCallsOnErrorWhenOneFailsAsynchronous() {
        let block = expectation(description: "Block called")
        let finallyBlock = expectation(description: "Finally called")
        let promise1 = Promise { _, reject in
            waitTime(0.2) {
                reject(MyError.defaultError)
            }
        }
        let promise2 = Promise<Void> { resolve, _ in
            waitTime(0.1) {
                resolve()
            }
        }
        Promises.whenAll(promise1, promise2)
            .then { _ in
                XCTFail("testWhenAllCallsOnErrorWhenOneFailsAsynchronous failed")
            }.onError { _ in
                block.fulfill()
            }.finally {
            finallyBlock.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
}
