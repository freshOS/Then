//
//  UnwrapTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 18/03/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
import then

class UnwrapTests: XCTestCase {
    
    func testUwrap() {
        let username: String? = "JohnDoe"
        unwrap(username).then { s in
            XCTAssertEqual(s, username)
        }.onError { _ in
            XCTFail("testUwrap failed")
        }
    }
    
    func testUwrapFails() {
        let username: String? = nil
        unwrap(username).then { _ in
            XCTFail("testUwrapFails failed")
        }.onError { e in
            if let pe = e as? PromiseError {
                XCTAssertTrue(pe == .unwrappingFailed)
            } else {
                XCTFail("testUwrapFails failed")
            }
        }
    }
}
