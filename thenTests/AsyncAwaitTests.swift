//
//  AsyncAwaitTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 13/03/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
import then

class AsyncAwaitTests: XCTestCase {
    
    func testAsyncAwaitChainWorks() {
        let exp = expectation(description: "")
        async {
            let userId = try await(fetchUserId())
            XCTAssertEqual(userId, 1234)
            let userName = try await(fetchUserNameFromId(userId))
            XCTAssertEqual(userName, "John Smith")
            let isFollowed = try await(fetchUserFollowStatusFromName(userName))
            XCTAssertFalse(isFollowed)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testFailingAsyncAwait() {
        let exp = expectation(description: "")
        async {
            _ = try await(failingFetchUserFollowStatusFromName("JohnDoe"))
            XCTFail("testFailingAsyncAwait failed")
        }.onError { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testCatchFailingAsyncAwait() {        
        let exp = expectation(description: "")
        do {
            _ = try await(failingFetchUserFollowStatusFromName("JohnDoe"))
            XCTFail("testCatchFailingAsyncAwait failed")
        } catch {
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testAsyncAwaitUnwrapAtYourOwnRisk() {
        let exp = expectation(description: "")
        let userId = try! await(fetchUserId())
        XCTAssertEqual(userId, 1234)
        let userName = try! await(fetchUserNameFromId(userId))
        XCTAssertEqual(userName, "John Smith")
        let isFollowed = try! await(fetchUserFollowStatusFromName(userName))
        XCTAssertFalse(isFollowed)
        exp.fulfill()
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testAsyncBlockCanReturnAValue() {
        let exp = expectation(description: "")
        async { () -> Int in
            let userId = try await(fetchUserId())
            return userId
        }.then { userId in
            XCTAssertEqual(userId, 1234)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
