//
//  OnErrorTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import XCTest
import then

class OnErrorTests: XCTestCase {

    func testError() {
        let errorExpectation = expectation(description: "onError called")
        let finallyExpectation = expectation(description: "Finally called")
        fetchUserId()
            .then(fetchUserNameFromId)
            .then(failingFetchUserFollowStatusFromName)
            .then { _ in
                XCTFail("then block shouldn't be called")
            }.onError { e in
                XCTAssertTrue((e as? MyError) == MyError.defaultError)
                errorExpectation.fulfill()
            }.finally {
                finallyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testOnErrorCalledWhenSynchronousRejects() {
        let errorblock = expectation(description: "error block called")
        promise1()
            .then(syncRejectionPromise())
            .then(syncRejectionPromise())
            .onError { _ in
                errorblock.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testThenAfterOnErrorWhenSynchronousResolves() {
        let thenblock = expectation(description: "then block called")
        promise1()
            .then(promise1())
            .onError { _ in
                XCTFail("on Error shouldn't be called")
            }.then { _ in
                 thenblock.fulfill()
            }
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testMultipleErrorBlockCanBeRegisteredOnSamePromise() {
        let error1 = expectation(description: "error called")
        let error2 = expectation(description: "error called")
        let error3 = expectation(description: "error called")
        let error4 = expectation(description: "error called")
        let p = failingFetchUserFollowStatusFromName("")
        p.onError { _ in
            error1.fulfill()
        }
        p.onError { _ in
            error2.fulfill()
        }
        p.onError { _ in
            error3.fulfill()
        }
        p.onError { _ in
            error4.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testTwoConsecutivErrorBlocks2ndShouldNeverBeCalledOnFail() {
        let errorExpectation = expectation(description: "then called")
        failingFetchUserFollowStatusFromName("")
            .then { _ in
                XCTFail("on Error shouldn't be called")
            }.onError { _ in
                errorExpectation.fulfill()
            }.onError { _ in
                XCTFail("Second on Error shouldn't be called")
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testTwoConsecutivErrorBlocks2ndShouldNeverBeCalledOnSuccess() {
        let thenExpectation = expectation(description: "then called")
        fetchUserId()
            .then { _ in
                thenExpectation.fulfill()
            }.onError { _ in
                XCTFail("on Error shouldn't be called")
            }.onError { _ in
                XCTFail("on Error shouldn't be called")
            }.onError { _ in
                XCTFail("on Error shouldn't be called")
            }.onError { _ in
                XCTFail("on Error shouldn't be called")
            }.onError { _ in
                XCTFail("on Error shouldn't be called")
            }.onError { _ in
                XCTFail("on Error shouldn't be called")
            }.onError { _ in
                XCTFail("on Error shouldn't be called")
            }.onError { _ in
                XCTFail("on Error shouldn't be called")
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testRegisterOnErrorDoesntStartThePromise() {
        let exp = expectation(description: "error block called")
        syncRejectionPromise().registerOnError { _ in
            XCTFail("testRegisterOnErrorDoesntStartThePromise failed")
        }
        waitTime(0.1) {
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testRegisterOnError() {
        let exp = expectation(description: "error block called")
        let p = syncRejectionPromise()
        p.registerOnError { _ in
            exp.fulfill()
        }
        p.start()
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
