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
    
    func testAsyncRaceFirstArrivesFirst() {
        let e = expectation(description: "")
        let p1 = Promise<String> { r, _ in
            waitTime(0.1) {
                r("1")
            }
        }
        let p2 = Promise<String> { r, _ in
            waitTime(0.3) {
                r("2")
            }
        }
        Promises.race(p1, p2).then { s in
            e.fulfill()
            XCTAssertEqual(s, "1")
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testSyncRaceFirstArrivesFirst() {
        let e = expectation(description: "")
        let p1 = Promise("1")
        let p2 = Promise("2")
        Promises.race(p1, p2).then { s in
            e.fulfill()
            XCTAssertEqual(s, "1")
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    struct TestRaceError: Error {}
    
    func testAsyncRaceWithFirsFailingFails() {
        let e = expectation(description: "")
        let p1 = Promise<String>.reject(TestRaceError())
        let p2 = Promise<String> { r, _ in
            waitTime(2) {
                r("2")
            }
        }
        Promises.race(p1, p2).onError { error in
            guard error as? TestRaceError != nil else {
                XCTFail("testRecoverCanThrowANewError failed")
                return
            }
            e.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testAsyncRaceWithSecondFailingSuceeds() {
        let e = expectation(description: "")
        let p1 = Promise("1")
        let p2 = Promise<String> { r, _ in
            waitTime(2) {
                r("2")
            }
        }
        Promises.race(p1, p2).then { s in
            e.fulfill()
            XCTAssertEqual(s, "1")
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
//    func testRaceFailsIfAllFail() {
//        let e = expectation(description: "")
//        let p1 = Promise<String>.reject()
//        let p2 = Promise<String>.reject()
//        Promises.race(p1, p2).then { _ in
//            XCTFail("testRaceFailsIfAllFail failed")
//        }.onError { _ in
//            e.fulfill()
//        }
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
    
}
