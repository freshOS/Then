//
//  TimeoutTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 10/08/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
import then

class TimeoutTests: XCTestCase {
    
    func testTimeOutTriggers() {
        let e = expectation(description: "")
        Promise<String> { resolve, _ in
            waitTime(0.1) {
                resolve("Hello")
            }
        }.timeout(0.2).then { string in
            XCTAssertEqual(string, "Hello")
            e.fulfill()
        }.onError { _ in
            XCTFail("testTimeOutTriggers failed")
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testTimeOutFails() {
        let e = expectation(description: "")
        Promise<String> { resolve, _ in
            waitTime(0.3) {
                resolve("Hello")
            }
        }.timeout(0.1).then { _ in
            XCTFail("testTimeOutFails failed")
        }.onError { error in
            if case PromiseError.timeout = error {
                // Good
            } else {
                XCTFail("testTimeOutFails failed")
            }
            e.fulfill()
        }
        
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
