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
        let thenExpectation = expectation(description: "then called")
        let finallyExpectation = expectation(description: "Finally called")
        fetchUserId()
        .then(fetchUserNameFromId)
        .then(fetchUserFollowStatusFromName)
        .then { isFollowed in
            XCTAssertFalse(isFollowed)
            thenExpectation.fulfill()
        }.onError { _ in
            XCTFail("on Error shouldn't be called")
        }.finally {
            finallyExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testChainedPromises() {
        let thenExpectation = expectation(description: "then called")
        fetchUserId()
        .then(fetchUserNameFromId(1))
        .then(fetchUserNameFromId(2))
        .then(fetchUserNameFromId(3)).then { name in
            print("name :\(name)")
            thenExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testChainedPromisesAreExecutedInOrder() {
        var count = 0
        
        let block1 = expectation(description: "block 1 called")
        let block2 = expectation(description: "block 2 called")
        let block3 = expectation(description: "block 3 called")
        
        let thenExpectation = expectation(description: "then called")
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
        .then(fetchUserNameFromId(3)).then { _ in
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
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testSynchronousChainsWorksProprely() {
        globalCount = 0
        blockPromiseCExpectation = expectation(description: "block C called")
        promiseA()
            .then(promiseB())
            .then(promiseC())
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testClassicThenLaunchesPromise() {
        let thenExpectation = expectation(description: "then called")
        fetchUserId().then { id in
            XCTAssertEqual(id, 1234)
            thenExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testMultipleThenBlockCanBeRegisteredOnSamePromise() {
        let then1 = expectation(description: "then called")
        let then2 = expectation(description: "then called")
        let then3 = expectation(description: "then called")
        let then4 = expectation(description: "then called")
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
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testThenWorksAfterErrorBlock() {
        let thenExpectation = expectation(description: "then called")
        fetchUserId()
            .then { _ in
                thenExpectation.fulfill()
            }.onError { _ in
                XCTFail("on Error shouldn't be called")
            }.then {
                print("Ok bro")
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testCanContinueWithThenAfterErrorBlock() {
        let thenExpectation = expectation(description: "then called")
        let errorExpectation = expectation(description: "Finally called")
        failingFetchUserFollowStatusFromName("").then { _ in
            XCTFail("testCanContinueWithThenAfterErrorBlock failed")
            }.onError { _ in
                errorExpectation.fulfill()
            }.then {
                thenExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
