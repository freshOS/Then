//
//  ValidateTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 22/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
import then

class ValidateTests: XCTestCase {
    
    func testValidateSucceeds() {
        let e = expectation(description: "")
        Promise<Int>.resolve(24)
            .validate { $0 > 18 }
            .then { _ in
                e.fulfill()
            }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testValidateFails() {
        let e = expectation(description: "")
        Promise<Int>.resolve(16)
            .validate { ($0 > 18) }
            .onError { error in
                if let pe = error as? PromiseError {
                   XCTAssertTrue(pe == .validationFailed)
                } else {
                    XCTFail("testValidateFails failed")
                }
                e.fulfill()
            }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testValidateWithCustomError() {
        let e = expectation(description: "")
        Promise<Int>.resolve(16)
            .validate(withError: MyError.defaultError, { $0 > 18 })
            .onError { error in
                if let pe = error as? MyError {
                    XCTAssertTrue(pe == MyError.defaultError)
                } else {
                    XCTFail("testValidateWithCustomError failed")
                }
                e.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testValidateNotCalledOnError() {
        let e = expectation(description: "")
        Promise.reject().validate {
            XCTFail("testValidateNotCalledOnError failed")
            return true
        }.finally {
            e.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
