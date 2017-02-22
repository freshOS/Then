//
//  RecoverTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 22/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
import then

class RecoverTests: XCTestCase {
    
    func testRecoverWithString() {
        let e = expectation(description: "")
        Promise<String>.reject()
            .recover(with: "Banana")
            .then { s in
                XCTAssertEqual(s, "Banana")
                e.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRecoverWithInt() {
        let e = expectation(description: "")
        Promise<Int>.reject()
            .recover(with: 12)
            .then { s in
                XCTAssertEqual(s, 12)
                e.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRecoverWithPromise() {
        let e = expectation(description: "")
        Promise<Int>.reject()
            .recover { _ in
                return Promise.resolve(56)
            }
            .then { s in
                XCTAssertEqual(s, 56)
                e.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
}
