//
//  RaceTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 22/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
import then

class RaceTests: XCTestCase {
    
    func testRaceFirstArrivesFirst() {
        let e = expectation(description: "")
        let p1 = Promise<String> { r, _ in
            wait(1) {
                r("1")
            }
        }
        let p2 = Promise<String> { r, _ in
            wait(2) {
                r("2")
            }
        }
        race(p1, p2).then { s in
            e.fulfill()
            XCTAssertEqual(s, "1")
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testRaceWithOneFailing() {
        let e = expectation(description: "")
        let p1 = Promise<String>.reject()
        let p2 = Promise<String> { r, _ in
            wait(2) {
                r("2")
            }
        }
        race(p1, p2).then { s in
            e.fulfill()
            XCTAssertEqual(s, "2")
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testRaceFailsIfAllFail() {
        let e = expectation(description: "")
        let p1 = Promise<String>.reject()
        let p2 = Promise<String>.reject()
        race(p1, p2).then { _ in
            XCTFail()
        }.onError { _ in
            e.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
}
