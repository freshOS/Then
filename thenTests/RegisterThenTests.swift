//
//  RegisterThenTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import XCTest
import then

class RegisterThenTests: XCTestCase {

    func testRegisterThenChainedPromisesAreNeverCalledWithoutAThenBlock() {
        let timerExpectation = expectation(description: "timerExpectation")
        fetchUserId()
            .registerThen { _ in
                XCTFail("testRegisterThenChainedPromisesAreNeverCalledWithoutAThenBlock failed")
            }.registerThen {_ in
                XCTFail("testRegisterThenChainedPromisesAreNeverCalledWithoutAThenBlock failed")
            }.registerThen {_ in
                XCTFail("testRegisterThenChainedPromisesAreNeverCalledWithoutAThenBlock failed")
        }
        waitTime(0.3) {
            timerExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testRegisterThenPromiseChainedPromisesAreNeverCalledWithoutAThenBlock() {
        let timerExpectation = expectation(description: "timerExpectation")
        fetchUserId()
            .registerThen(fetchUserNameFromId(10)).registerThen { name in
                print(name)
                XCTFail("testRegisterThenPromiseChainedPromisesAreNeverCalledWithoutAThenBlock failed")
            }.registerThen {_ in
                XCTFail("testRegisterThenPromiseChainedPromisesAreNeverCalledWithoutAThenBlock failed")
            }.registerThen {_ in
                XCTFail("testRegisterThenPromiseChainedPromisesAreNeverCalledWithoutAThenBlock failed")
        }
        waitTime(0.3) {
            timerExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testRegisterThenPromise2ChainedPromisesAreNeverCalledWithoutAThenBlock() {
        let timerExpectation = expectation(description: "timerExpectation")
        fetchUserId().registerThen { id in
            return fetchUserNameFromId(id)
            }.registerThen { _ in
                XCTFail("testRegisterThenPromise2ChainedPromisesAreNeverCalledWithoutAThenBlock failed")
            }.registerThen { _ in
                XCTFail("testRegisterThenPromise2ChainedPromisesAreNeverCalledWithoutAThenBlock failed")
        }
        waitTime(0.3) {
            timerExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testRegisterThenChainedPromisesAreExecutedInOrder() {
        var count = 0
        
        let block1 = expectation(description: "block 1 called")
        let block2 = expectation(description: "block 2 called")
        let block3 = expectation(description: "block 3 called")
        
        let thenExpectation = expectation(description: "thenExpectation")
        fetchUserId()
            .registerThen { _ in
                XCTAssertTrue(count == 0)
                count+=1
                block1.fulfill()
            }.registerThen {_ in
                XCTAssertTrue(count == 1)
                count+=1
                block2.fulfill()
            }.registerThen {_ in
                XCTAssertTrue(count == 2)
                count+=1
                block3.fulfill()
            }.then { name in
                XCTAssertTrue(count == 3)
                count+=1
                print("name :\(name)")
                thenExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testRegisterThenPromiseFuncPointerNotCalled() {
        let timerExpectation = expectation(description: "thenExpectation")
        fetchUserId()
            .registerThen(fetchUserNameFromId)
            .registerThen { _ in
                XCTFail("testRegisterThenPromiseFuncPointerNotCalled failed")
        }
        waitTime(0.3) {
            timerExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testRegisterThenPromise2FuncPointerNotCalled() {
        let timerExpectation = expectation(description: "thenExpectation")
        fetchUserId().registerThen { id -> Promise<String> in
            return fetchUserNameFromId(id)
            }.registerThen { _ in
                XCTFail("testRegisterThenPromise2FuncPointerNotCalled failed")
        }
        waitTime(0.3) {
            timerExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testRegisterThenPromiseFuncPointerCalledWithThenBlock() {
        let timerExpectation = expectation(description: "thenExpectation")
        fetchUserId()
            .registerThen(fetchUserNameFromId)
            .then { _ in
                timerExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testRegisterThenPromise2FuncPointerCalledWithThenBlock() {
        let timerExpectation = expectation(description: "thenExpectation")
        fetchUserId().registerThen { id -> Promise<String> in
            return fetchUserNameFromId(id)
            }.then { _ in
                timerExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testRegisterThenPromiseFuncPointerCalledWithMultipleRegisterThenBlocks() {
        let timerExpectation = expectation(description: "thenExpectation")
        fetchUserId()
            .registerThen(fetchUserNameFromId)
            .registerThen(fetchUserFollowStatusFromName)
            .then { _ in
                timerExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testRegisterThenMultipleThenOnlyCallOriginalPromiseOnce() {
        var count = 0
        
        let block1 = expectation(description: "block 1 called")
        let block2 = expectation(description: "block 2 called")
        let block3 = expectation(description: "block 3 called")
        
        let thenExpectation = expectation(description: "thenExpectation")
        fetchUserId()
            .registerThen { _ in
                XCTAssertTrue(count == 0)
                count+=1
                block1.fulfill()
            }.registerThen {_ in
                XCTAssertTrue(count == 1)
                count+=1
                block2.fulfill()
            }.registerThen {_ in
                XCTAssertTrue(count == 2)
                count+=1
                block3.fulfill()
            }.then { name in
                XCTAssertTrue(count == 3)
                count+=1
                print("name :\(name)")
                thenExpectation.fulfill()
            }.then { _ -> Void in
                print("Just another then block")
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }

}
