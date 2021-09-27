//
//  AhoyAvastTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 13/03/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
import Then

class AhoyAvastTests: XCTestCase {
    
    func testAhoyAvastChainWorks() {
        let exp = expectation(description: "")
        ahoy {
            let userId = try avast(fetchUserId())
            XCTAssertEqual(userId, 1234)
            let userName = try avast(fetchUserNameFromId(userId))
            XCTAssertEqual(userName, "John Smith")
            let isFollowed = try avast(fetchUserFollowStatusFromName(userName))
            XCTAssertFalse(isFollowed)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testFailingAhoyAvast() {
        let exp = expectation(description: "")
        ahoy {
            _ = try avast(failingFetchUserFollowStatusFromName("JohnDoe"))
            XCTFail("testFailingAhoyAvast failed")
        }.onError { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testCatchFailingAhoyAvast() {
        let exp = expectation(description: "")
        do {
            _ = try avast(failingFetchUserFollowStatusFromName("JohnDoe"))
            XCTFail("testCatchFailingAhoyAvast failed")
        } catch {
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testAhoyAvastUnwrapAtYourOwnRisk() {
        let exp = expectation(description: "")
        let userId = try! avast(fetchUserId())
        XCTAssertEqual(userId, 1234)
        let userName = try! avast(fetchUserNameFromId(userId))
        XCTAssertEqual(userName, "John Smith")
        let isFollowed = try! avast(fetchUserFollowStatusFromName(userName))
        XCTAssertFalse(isFollowed)
        exp.fulfill()
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testAhoyBlockCanReturnAValue() {
        let exp = expectation(description: "")
        ahoy { () -> Int in
            let userId = try avast(fetchUserId())
            return userId
        }.then { userId in
            XCTAssertEqual(userId, 1234)
            exp.fulfill()
        }
       waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    /// Operator ..
    
    func testAhoyAvastChainWorksOperator() {
        let exp = expectation(description: "")
        ahoy {
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
    
    func testFailingAhoyAvastOperator() {
        let exp = expectation(description: "")
        ahoy {
            _ = try ..failingFetchUserFollowStatusFromName("JohnDoe")
            XCTFail("testFailingAhoyAvast failed")
        }.onError { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }

    func testCatchFailingAhoyAvastOperator() {
        let exp = expectation(description: "")
        do {
            _ = try ..failingFetchUserFollowStatusFromName("JohnDoe")
            XCTFail("testCatchFailingAhoyAvast failed")
        } catch {
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testAhoyAvastUnwrapAtYourOwnRiskOperator() {
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

    func testAhoyBlockCanReturnAValueOperator() {
        let exp = expectation(description: "")
        ahoy { () -> Int in
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
        ahoy {
            let optionalPromise: Promise? = fetchUserId()
            let userId = try ..optionalPromise
            XCTAssertEqual(userId, 1234)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testNilOptionalPromisesFail() {
        let exp = expectation(description: "")
        ahoy {
            let optionalPromise: Promise<Int>? = nil
            _ = try ..optionalPromise
            XCTFail("testFailingAhoyAvast failed")
        }.onError { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    /// Operator ..? - nils out instead of throwing
    
    func testAvastNilingOperator() {
        let exp = expectation(description: "")
        ahoy {
            let userId = ..?fetchUserId()
            XCTAssertEqual(userId, 1234)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testAvastNilingOperatorError() {
        let exp = expectation(description: "")
        ahoy {
            let string = ..?(failingFetchUserFollowStatusFromName("JohnDoe"))
            XCTAssertNil(string)
            exp.fulfill()
        }.onError { _ in
            XCTFail("testFailingAhoyAvast failed")
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    /// Optional Operator ..? - nils out instead of throwing
    
    func testAvastNilingOperatorOptional() {
        let exp = expectation(description: "")
        ahoy {
            let promise: Promise<Int>? = fetchUserId()
            let userId = ..?promise
            XCTAssertEqual(userId, 1234)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testAvastNilingOperatorErrorOptinal() {
        let exp = expectation(description: "")
        ahoy {
            let promise: Promise<Bool>? = failingFetchUserFollowStatusFromName("JohnDoe")
            let string = ..?promise
            XCTAssertNil(string)
            exp.fulfill()
        }.onError { _ in
            XCTFail("testFailingAhoyAvast failed")
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testAvastNilingOperatorErrorNilOptional() {
        let exp = expectation(description: "")
        ahoy {
            let promise: Promise<Bool>? = nil
            let string = ..?promise
            XCTAssertNil(string)
            exp.fulfill()
        }.onError { _ in
            XCTFail("testFailingAhoyAvast failed")
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
}
