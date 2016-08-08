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
        let errorExpectation = expectationWithDescription("onError called")
        let finallyExpectation = expectationWithDescription("Finally called")
        fetchUserId()
            .then(fetchUserNameFromId)
            .then(failingFetchUserFollowStatusFromName)
            .then { isFollowed in
                XCTFail("then block shouldn't be called")
            }.onError { e in
                XCTAssertTrue((e as? MyError) == MyError.DefaultError)
                errorExpectation.fulfill()
            }.finally {
                finallyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testOnErrorCalledWhenSynchronousRejects() {
        let errorblock = expectationWithDescription("error block called")
        promiseA()
            .then(syncRejectionPromise())
            .then(syncRejectionPromise())
            .onError { (error) -> Void in
                errorblock.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testMultipleErrorBlockCanBeRegisteredOnSamePromise() {
        let error1 = expectationWithDescription("error called")
        let error2 = expectationWithDescription("error called")
        let error3 = expectationWithDescription("error called")
        let error4 = expectationWithDescription("error called")
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
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testTwoConsecutivErrorBlocks2ndShouldNeverBeCalledOnFail() {
        let errorExpectation = expectationWithDescription("then called")
        failingFetchUserFollowStatusFromName("")
            .then { id in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                errorExpectation.fulfill()
            }.onError { e in
                XCTFail("Second on Error shouldn't be called")
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testTwoConsecutivErrorBlocks2ndShouldNeverBeCalledOnSuccess() {
        let thenExpectation = expectationWithDescription("then called")
        fetchUserId()
            .then { id in
                thenExpectation.fulfill()
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

}
