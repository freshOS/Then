//
//  ResgisterThenTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import XCTest
import then

class ResgisterThenTests: XCTestCase {

    func testRegisterThenChainedPromisesAreNeverCalledWithoutAThenBlock() {
        let timerExpectation = expectationWithDescription("timerExpectation")
        fetchUserId()
            .registerThen { _ in
                XCTFail()
            }.registerThen {_ in
                XCTFail()
            }.registerThen {_ in
                XCTFail()
        }
        wait(1) {
            timerExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenPromiseChainedPromisesAreNeverCalledWithoutAThenBlock() {
        let timerExpectation = expectationWithDescription("timerExpectation")
        fetchUserId()
            .registerThen(fetchUserNameFromId(10)).registerThen { name in
                print(name)
                XCTFail()
            }.registerThen {_ in
                XCTFail()
            }.registerThen {_ in
                XCTFail()
        }
        wait(1) {
            timerExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenPromise2ChainedPromisesAreNeverCalledWithoutAThenBlock() {
        let timerExpectation = expectationWithDescription("timerExpectation")
        fetchUserId().registerThen { id in
            return fetchUserNameFromId(id)
            }.registerThen { name in
                print(name)
                XCTFail()
            }.registerThen { _ in
                XCTFail()
        }
        wait(1) {
            timerExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenChainedPromisesAreExecutedInOrder() {
        var count = 0
        
        let block1 = expectationWithDescription("block 1 called")
        let block2 = expectationWithDescription("block 2 called")
        let block3 = expectationWithDescription("block 3 called")
        
        let thenExpectation = expectationWithDescription("thenExpectation")
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
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenPromiseFuncPointerNotCalled() {
        let timerExpectation = expectationWithDescription("thenExpectation")
        fetchUserId()
            .registerThen(fetchUserNameFromId)
            .registerThen { _ in
                XCTFail()
        }
        wait(1) {
            timerExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenPromise2FuncPointerNotCalled() {
        let timerExpectation = expectationWithDescription("thenExpectation")
        fetchUserId().registerThen { id -> Promise<String> in
            return fetchUserNameFromId(id)
            }.registerThen { _ in
                XCTFail()
        }
        wait(1) {
            timerExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenPromiseFuncPointerCalledWithThenBlock() {
        let timerExpectation = expectationWithDescription("thenExpectation")
        fetchUserId()
            .registerThen(fetchUserNameFromId)
            .then { name in
                timerExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenPromise2FuncPointerCalledWithThenBlock() {
        let timerExpectation = expectationWithDescription("thenExpectation")
        fetchUserId().registerThen { id -> Promise<String> in
            return fetchUserNameFromId(id)
            }.then { name in
                timerExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenPromiseFuncPointerCalledWithMultipleRegisterThenBlocks() {
        let timerExpectation = expectationWithDescription("thenExpectation")
        fetchUserId()
            .registerThen(fetchUserNameFromId)
            .registerThen(fetchUserFollowStatusFromName)
            .then { name in
                timerExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenMultipleThenOnlyCallOriginalPromiseOnce() {
        var count = 0
        
        let block1 = expectationWithDescription("block 1 called")
        let block2 = expectationWithDescription("block 2 called")
        let block3 = expectationWithDescription("block 3 called")
        
        let thenExpectation = expectationWithDescription("thenExpectation")
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
        waitForExpectationsWithTimeout(5, handler: nil)
    }

}
