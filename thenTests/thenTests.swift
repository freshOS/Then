//
//  thenTests.swift
//  thenTests
//
//  Created by Sacha Durand Saint Omer on 06/02/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import XCTest
@testable import then

class thenTests: XCTestCase {
    
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
    
    func testError() {
        let errorExpectation = expectationWithDescription("onError called")
        let finallyExpectation = expectationWithDescription("Finally called")
        fetchUserId()
            .then(fetchUserNameFromId)
            .then(failingFetchUserFollowStatusFromName)
            .then { isFollowed in
                XCTFail("then block shouldn't be called")
            }.onError { e in
                XCTAssertTrue((e as! MyError) == MyError.DefaultError)
                errorExpectation.fulfill()
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
        waitForExpectationsWithTimeout(10, handler: nil)
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
                count++
                block1.fulfill()
            })
            .then(fetchUserNameFromId(2)).then {_ in
                XCTAssertTrue(count == 1)
                count++
                block2.fulfill()
            }
            .then(fetchUserNameFromId(3)).then {_ in
                XCTAssertTrue(count == 2)
                count++
                block3.fulfill()
            }
            .then(fetchUserNameFromId(4)).then { name in
                XCTAssertTrue(count == 3)
                count++
                print("name :\(name)")
                thenExpectation.fulfill()
            }
            waitForExpectationsWithTimeout(10, handler: nil)
        }
}


func fetchUserId() -> Promise<Int> {
    return Promise { resolve, reject in
        print("fetching user Id ...")
        wait { resolve(result: 1234) }
    }
}

func fetchUserNameFromId(id:Int) -> Promise<String> {
    return Promise { resolve, reject in
        print("fetching UserName FromId : \(id) ...")
        wait { resolve(result: "John Smith") }
    }
}

func fetchUserFollowStatusFromName(name:String) -> Promise<Bool> {
    return Promise { resolve, reject in
        print("fetchUserFollowStatusFromName: \(name) ...")
        wait { resolve(result: false) }
    }
}

func failingFetchUserFollowStatusFromName(name:String) -> Promise<Bool> {
    return Promise { resolve, reject in
        print("fetchUserFollowStatusFromName: \(name) ...")
        wait { reject(error:MyError.DefaultError) }
    }
}

func wait(callback:()->()) {
    let delay = 1 * Double(NSEC_PER_SEC)
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
    dispatch_after(time, dispatch_get_main_queue()) {
        callback()
    }
}

enum MyError:ErrorType {
    case DefaultError
}
