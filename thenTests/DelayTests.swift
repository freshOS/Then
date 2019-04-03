//
//  DelayTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 09/08/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
import then

class DelayTests: XCTestCase {
    
    func testStaticDelay() {
        let e = expectation(description: "")
        var run = false
        Promises.delay(0.2).then {
            run = true
            e.fulfill()
        }
        waitTime(0.1) {
            XCTAssertFalse(run)
        }
        waitTime(0.3) {
            XCTAssertTrue(run)
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testDelay() {
        let e = expectation(description: "")
        var result: Int?
        Promise { resolve, _ in
            waitTime(0.1) {
                resolve(123)
            }
        }.delay(0.1).then { int in
            result = int
            e.fulfill()
        }
        
        waitTime(0.1) {
            XCTAssertNil(result)
        }
        waitTime(0.3) {
            XCTAssertEqual(result, 123)
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testChainDelays() {
        let e = expectation(description: "")
        var run = false
        Promises.delay(0.1).delay(0.1).delay(0.1).then {
            run = true
            e.fulfill()
        }
        waitTime(0.2) {
            XCTAssertFalse(run)
        }
        waitTime(0.4) {
            XCTAssertTrue(run)
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testDelayOnlyAppliesOnSuccessfulPromises() {
        let e = expectation(description: "")
        var done = false
        Promise<Int> { _, reject in
            waitTime(0.2) {
                reject(PromiseError.default)
            }
        }.delay(0.8).then { _ in
            XCTFail("testDelayOnlyAppliesOnSuccessfulPromises failed")
        }.onError { _ in
            done = true
            e.fulfill()
        }
        
        waitTime(0.3) {
            XCTAssertTrue(done)
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
