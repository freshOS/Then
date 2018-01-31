//
//  NoMatterWhatTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 24/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
import then

class NoMatterWhatTests: XCTestCase {
    
    func testNoMatterWhatCalledOnSuccess() {
        let exp = expectation(description: "")
        var isLoading = true
        XCTAssertTrue(isLoading)
        Promise<String>.resolve("Cool").noMatterWhat {
            isLoading = false
        }.finally {
            XCTAssertFalse(isLoading)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testNoMatterWhatCalledOnError() {
        let exp = expectation(description: "")
        var isLoading = true
        XCTAssertTrue(isLoading)
        Promise<String>.reject().noMatterWhat {
            isLoading = false
        }.finally {
            XCTAssertFalse(isLoading)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
