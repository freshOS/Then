//
//  ThenTests.swift
//  ThenTests
//
//  Created by Sacha Durand Saint Omer on 06/02/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import XCTest
@testable import then

class ThenTests: XCTestCase {
    
    override func setUp() { super.setUp() }
    override func tearDown() { super.tearDown() }
    
    func testThen() {
        let thenExpectation = expectationWithDescription("then called")
        let finallyExpectation = expectationWithDescription("Finally called")
        fetchUserId()
        .then(fetchUserNameFromId)
        .then(fetchUserFollowStatusFromName)
        .then { isFollowed in
            XCTAssertFalse(isFollowed)
            thenExpectation.fulfill()
        }.onError { e in
            XCTFail("on Error shouldn't be called")
        }.finally {
            finallyExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testChainedPromises() {
        let thenExpectation = expectationWithDescription("then called")
        fetchUserId()
        .then(fetchUserNameFromId(1))
        .then(fetchUserNameFromId(2))
        .then(fetchUserNameFromId(3))
        .then(fetchUserNameFromId(4)).then { name in
            print("name :\(name)")
            thenExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testChainedPromisesAreExecutedInOrder() {
        var count = 0
        
        let block1 = expectationWithDescription("block 1 called")
        let block2 = expectationWithDescription("block 2 called")
        let block3 = expectationWithDescription("block 3 called")
        
        let thenExpectation = expectationWithDescription("then called")
        fetchUserId()
        .then(fetchUserNameFromId(1)).then({ _ in
            XCTAssertTrue(count == 0)
            count+=1
            block1.fulfill()
        })
        .then(fetchUserNameFromId(2)).then {_ in
            XCTAssertTrue(count == 1)
            count+=1
            block2.fulfill()
        }
        .then(fetchUserNameFromId(3)).then {_ in
            XCTAssertTrue(count == 2)
            count+=1
            block3.fulfill()
        }
        .then(fetchUserNameFromId(4)).then { name in
            XCTAssertTrue(count == 3)
            count+=1
            print("name :\(name)")
            thenExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testSynchronousChainsWorksProprely() {
        globalCount = 0
        blockPromiseCExpectation = expectationWithDescription("block C called")
        promiseA()
            .then(promiseB())
            .then(promiseC())
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testFinallyCalledWhenSynchronous() {
        let finallyblock = expectationWithDescription("error block called")
        syncRejectionPromise().finally {
            finallyblock.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testClassicThenLaunchesPromise() {
        let thenExpectation = expectationWithDescription("then called")
        fetchUserId().then { id in
            XCTAssertEqual(id, 1234)
            thenExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testMultipleThenBlockCanBeRegisteredOnSamePromise() {
        let then1 = expectationWithDescription("then called")
        let then2 = expectationWithDescription("then called")
        let then3 = expectationWithDescription("then called")
        let then4 = expectationWithDescription("then called")
        let p = fetchUserId()
        p.then { _ in
            then1.fulfill()
        }
        p.then { _ in
            then2.fulfill()
        }
        p.then { _ in
            then3.fulfill()
        }
        p.then { _ in
            then4.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testMultipleFinallyBlockCanBeRegisteredOnSamePromise() {
        let finally1 = expectationWithDescription("finally called")
        let finally2 = expectationWithDescription("finally called")
        let finally3 = expectationWithDescription("finally called")
        let finally4 = expectationWithDescription("finally called")
        let p = failingFetchUserFollowStatusFromName("")
        p.finally {
            finally1.fulfill()
        }
        p.finally {
            finally2.fulfill()
        }
        p.finally {
            finally3.fulfill()
        }
        p.finally {
            finally4.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testThenWorksAfterErrorBlock() {
        let thenExpectation = expectationWithDescription("then called")
        fetchUserId()
            .then { id in
                thenExpectation.fulfill()
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.then {
                print("Ok bro")
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testCanContinueWithThenAfterErrorBlock() {
        let thenExpectation = expectationWithDescription("then called")
        let errorExpectation = expectationWithDescription("Finally called")
        failingFetchUserFollowStatusFromName("").then { _ in
            XCTFail()
            }.onError { e in
                errorExpectation.fulfill()
            }.then {
                thenExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
}
