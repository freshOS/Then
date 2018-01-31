//
//  ChainTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 13/03/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
import then

class ChainTests: XCTestCase {
    
    func testChainSyncPromise() {
        let exp = expectation(description: "")
        Promise<String>.resolve("Cool").chain { s in
            XCTAssertEqual(s, "Cool")
            exp.fulfill()
        }.then { _ in }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testChainASyncPromise() {
        let exp = expectation(description: "")
        fetchUserNameFromId(123).chain { s in
            XCTAssertEqual(s, "John Smith")
            exp.fulfill()
        }.then { _ in }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testChainNotCalledWhenSyncPromiseFails() {
        let exp = expectation(description: "")
        Promise<Int>.reject().chain { _ in
            XCTFail("testChainNotCalledWhenSyncPromiseFails failed")
        }.onError { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testChainNotCalledWhenAsyncPromiseFails() {
        let exp = expectation(description: "")
        failingFetchUserFollowStatusFromName("Tom").chain { _ in
            XCTFail("testChainNotCalledWhenAsyncPromiseFails failed")
        }.onError { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testChainKeepsProgress() {
        let progressExpectation = expectation(description: "thenExpectation")
        let thenExpectation = expectation(description: "thenExpectation")
        let chainExpectation = expectation(description: "chainExpectation")
        upload().chain {
            chainExpectation.fulfill()
        }.progress { p in
            XCTAssertEqual(p, 0.8)
            progressExpectation.fulfill()
        }.then {
            thenExpectation.fulfill()
        }.onError { _ in
             print("ERROR")
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
