//
//  BridgeErrorTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 24/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
@testable import then

class BridgeErrorTests: XCTestCase {
    
    func testBridgeAllErrorsToMine() {
        let exp = expectation(description: "")
        Promise<Int>.reject()
            .bridgeError(to: MyError.defaultError)
            .then { _ in
                XCTFail("then shouldn't be called")
            }.onError { e in
                if let e = e as? MyError {
                    XCTAssertTrue(e == .defaultError)
                } else {
                    XCTFail("testBridgeAllErrorsToMine failed")
                }
                exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testBridgeAllErrorsNoError() {
        let exp = expectation(description: "")
        Promise<Int>.resolve(42)
            .bridgeError(to: MyError.defaultError)
            .then { _ in
                exp.fulfill()
            }.onError { _ in
                XCTFail("onError shouldn't be called")

        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testBridgeASpecificErrorToMine() {
        let exp = expectation(description: "")
        Promise<Int>.reject(PromiseError.retryInvalidInput)
            .bridgeError(PromiseError.retryInvalidInput, to: MyError.defaultError)
            .then { _ in
                XCTFail("then shouldn't be called")
            }.onError { e in
                if let e = e as? MyError {
                    XCTAssertTrue(e == .defaultError)
                } else {
                    XCTFail("testBridgeASpecificErrorToMine failed")
                }
                exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testBridgeASpecificErrorToMineNotMatchingError() {
        let exp = expectation(description: "")
        Promise<Int>.reject(PromiseError.default)
            .bridgeError(PromiseError.retryInvalidInput, to: MyError.defaultError)
            .then { _ in
                XCTFail("then shouldn't be called")
            }.onError { e in
                if let e = e as? PromiseError {
                    XCTAssertTrue(e == .default)
                } else {
                    XCTFail("testBridgeASpecificErrorToMineNotMatchingError failed")
                }
                exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testBridgeErrorCanUseBlockAndThrow() {
        let exp = expectation(description: "")
        Promise<Int>.reject()
            .bridgeError { _ in
                throw MyError.defaultError
            }
            .then { _ in
                XCTFail("then shouldn't be called")
            }.onError { e in
                if let e = e as? MyError {
                    XCTAssertTrue(e == .defaultError)
                } else {
                    XCTFail("failed testBridgeErrorCanUseBlockAndThrow")
                }
                exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
