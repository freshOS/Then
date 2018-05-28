//
//  ProgressTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import XCTest
import then

class ProgressTests: XCTestCase {

    func testProgress() {
        let progressExpectation = expectation(description: "progressExpectation")
        let thenExpectation = expectation(description: "thenExpectation")
        upload().progress { p in
            print("PROGRESS \(p)")
            XCTAssertEqual(p, 0.8)
            progressExpectation.fulfill()
        }.then {
            print("Done")
            thenExpectation.fulfill()
        }.onError { _ in
            print("ERROR")
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testProgressFails() {
        let progressExpectation = expectation(description: "thenExpectation")
        let errorExpectation = expectation(description: "errorExpectation")
        failingUpload().progress { p in
            XCTAssertEqual(p, 0.8)
            progressExpectation.fulfill()
        }.then {
            XCTFail("testProgressFails failed")
        }.onError { _ in
            errorExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
