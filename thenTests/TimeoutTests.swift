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
            waitTime(1) {
                resolve("Hello")
            }
        }.timeout(2).then { string in
            XCTAssertEqual(string, "Hello")
            e.fulfill()
        }.onError { _ in
            XCTFail()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testTimeOutFails() {
        let e = expectation(description: "")
        Promise<String> { resolve, _ in
            waitTime(1) {
                resolve("Hello")
            }
        }.timeout(0.5).then { _ in
            XCTFail()
        }.onError { error in
            if case PromiseError.timeout = error {
                // Good
            } else {
                XCTFail()
            }
            e.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
}
