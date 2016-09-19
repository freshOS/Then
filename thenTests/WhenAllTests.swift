//
//  WhenAllTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import XCTest
import then

class WhenAllTests: XCTestCase {

    func testWhenAll() {
        let block = expectation(description: "Block called")
        whenAll(promise1(), promise2(), promise3()).then { array in
            XCTAssertEqual(array, [1, 2, 3])
            block.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWhenAllArray() {
        let block = expectation(description: "Block called")
        whenAll(promiseArray1(), promiseArray2(), promiseArray3()).then { array in
            XCTAssertEqual(array, [1, 2, 3, 4, 5, 6, 7, 8, 9])
            block.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWhenAllCallsOnErrorWhenOneFails() {
        let block = expectation(description: "Block called")
        let finallyBlock = expectation(description: "Finally called")
        let promise1 = Promise<Void> { resolve, reject in
            reject(MyError.defaultError)
        }
        
        let promise2 = Promise<Void> { resolve, _ in
            resolve()
        }
        
        whenAll(promise1, promise2)
            .then { _ in
                XCTFail()
            }.onError { _ in
                block.fulfill()
            }.finally { _ in
                finallyBlock.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

}
