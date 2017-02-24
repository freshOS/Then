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
            .recover(with: Promise<Int>.resolve(56))
            .then { s in
                XCTAssertEqual(s, 56)
                e.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRecoverWithFailablePromise() {
        let e = expectation(description: "")
        Promise<Int>.reject()
            .recover(with: Promise<Int>.reject())
            .then { _ in
                XCTFail("then shouldn't be called")
            }
            .onError { _ in
                e.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRecoverCanUseABlock() {
        let e = expectation(description: "")
        Promise<Int>.reject()
            .recover { _ in
                return 32
            }
            .then { s in
                XCTAssertEqual(s, 32)
                e.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRecoverCanThrowANewError() {
        let exp = expectation(description: "")
        Promise<Int>.reject()
            .recover { e in
                if let e = e as? PromiseError, e == .default {
                    throw MyError.defaultError
                }
                return 32
            } .then { _ in
                XCTFail("then shouldn't be called")
            }.onError { e in
                if let e = e as? MyError {
                    XCTAssertTrue(e == .defaultError)
                } else {
                    XCTFail()
                }
                exp.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRecoverForSpecificError() {
        let exp = expectation(description: "")
        Promise<Int>.resolve(10)
            .validate { $0 > 100 }
            .recover(PromiseError.validationFailed, with: 123)
            .then { i in
                XCTAssertEqual(i, 123)
                exp.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRecoverForSpecificErrorDoesNotRecoverWhenTypeNotMatching() {
        let exp = expectation(description: "")
        Promise<Int>.reject()
            .recover(PromiseError.validationFailed, with: 123)
            .then { _ in
                XCTFail()
        }.onError { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
}
