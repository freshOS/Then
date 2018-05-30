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
    
    /// Operator ..
    
    func testAsyncAwaitChainWorksOperator() {
        let exp = expectation(description: "")
        async {
            let userId = try ..fetchUserId()
            XCTAssertEqual(userId, 1234)
            let userName = try ..fetchUserNameFromId(userId)
            XCTAssertEqual(userName, "John Smith")
            let isFollowed = try ..fetchUserFollowStatusFromName(userName)
            XCTAssertFalse(isFollowed)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testFailingAsyncAwaitOperator() {
        let exp = expectation(description: "")
        async {
            _ = try ..failingFetchUserFollowStatusFromName("JohnDoe")
            XCTFail("testFailingAsyncAwait failed")
        }.onError { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testCatchFailingAsyncAwaitOperator() {
        let exp = expectation(description: "")
        do {
            _ = try ..failingFetchUserFollowStatusFromName("JohnDoe")
            XCTFail("testCatchFailingAsyncAwait failed")
        } catch {
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testAsyncAwaitUnwrapAtYourOwnRiskOperator() {
        let exp = expectation(description: "")
        let userId = try! ..fetchUserId()
        XCTAssertEqual(userId, 1234)
        let userName = try! ..fetchUserNameFromId(userId)
        XCTAssertEqual(userName, "John Smith")
        let isFollowed = try! ..fetchUserFollowStatusFromName(userName)
        XCTAssertFalse(isFollowed)
        exp.fulfill()
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testAsyncBlockCanReturnAValueOperator() {
        let exp = expectation(description: "")
        async { () -> Int in
            let userId = try ..fetchUserId()
            return userId
        }.then { userId in
            XCTAssertEqual(userId, 1234)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    /// Optional Promises
    
    func testOptionalPromises() {
        let exp = expectation(description: "")
        async {
            let optionalPromise: Promise? = fetchUserId()
            let userId = try ..optionalPromise
            XCTAssertEqual(userId, 1234)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testNilOptionalPromisesFail() {
        let exp = expectation(description: "")
        async {
            let optionalPromise: Promise<Int>? = nil
            _ = try ..optionalPromise
            XCTFail("testFailingAsyncAwait failed")
        }.onError { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    /// Operator ..? - nils out instead of throwing
    
    func testAwaitNilingOperator() {
        let exp = expectation(description: "")
        async {
            let userId = ..?fetchUserId()
            XCTAssertEqual(userId, 1234)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testAwaitNilingOperatorError() {
        let exp = expectation(description: "")
        async {
            let string = ..?(failingFetchUserFollowStatusFromName("JohnDoe"))
            XCTAssertNil(string)
            exp.fulfill()
        }.onError { _ in
            XCTFail("testFailingAsyncAwait failed")
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    /// Optional Operator ..? - nils out instead of throwing
    
    func testAwaitNilingOperatorOptional() {
        let exp = expectation(description: "")
        async {
            let promise: Promise<Int>? = fetchUserId()
            let userId = ..?promise
            XCTAssertEqual(userId, 1234)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testAwaitNilingOperatorErrorOptinal() {
        let exp = expectation(description: "")
        async {
            let promise: Promise<Bool>? = failingFetchUserFollowStatusFromName("JohnDoe")
            let string = ..?promise
            XCTAssertNil(string)
            exp.fulfill()
        }.onError { _ in
            XCTFail("testFailingAsyncAwait failed")
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testAwaitNilingOperatorErrorNilOptional() {
        let exp = expectation(description: "")
        async {
            let promise: Promise<Bool>? = nil
            let string = ..?promise
            XCTAssertNil(string)
            exp.fulfill()
        }.onError { _ in
            XCTFail("testFailingAsyncAwait failed")
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
}
