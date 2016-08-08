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
        let progressExpectation = expectationWithDescription("thenExpectation")
        let thenExpectation = expectationWithDescription("thenExpectation")
        upload().progress { p in
            print("PROGRESS \(p)")
            XCTAssertEqual(p, 0.8)
            progressExpectation.fulfill()
            }.then {
                print("Done")
                thenExpectation.fulfill()
            }.onError { e in
                print("ERROR")
        }
        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
    func testProgressFails() {
        let progressExpectation = expectationWithDescription("thenExpectation")
        let errorExpectation = expectationWithDescription("errorExpectation")
        failingUpload().progress { p in
            XCTAssertEqual(p, 0.8)
            progressExpectation.fulfill()
            }.then {
                XCTFail()
            }.onError { e in
                errorExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(3, handler: nil)
    }
}
