//
//  ZipTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 10/08/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
import then

class ZipTests: XCTestCase {
    
    // 2 promises
    
    func testZipSynchronousPromises() {
        let block = expectation(description: "Block called")
        Promises.zip(Promise(1), Promise("Hello")).then { int, string in
            XCTAssertEqual(int, 1)
            XCTAssertEqual(string, "Hello")
            block.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testZipAsynchronousPromises() {
        let block = expectation(description: "Block called")
        let p1 = Promise { resolve, _ in
            waitTime(0.1) { resolve("Cool") }
        }
        let p2 = Promise { resolve, _ in
            waitTime(0.2) { resolve(23) }
        }
        Promises.zip(p1, p2).then { string, int in
            XCTAssertEqual(string, "Cool")
            XCTAssertEqual(int, 23)
            block.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testZipSynchronousPromisesFails() {
        let block = expectation(description: "Block called")
        Promises.zip(Promise<Int>.reject(), Promise("Hello")).then { _, _ in
            XCTFail("testZipSynchronousPromisesFails failed")
        }.onError { _ in
            block.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testZipAsynchronousPromisesFails() {
        let block = expectation(description: "Block called")
        let p1 = Promise { resolve, _ in
            waitTime(0.1) { resolve("Cool") }
        }
        let p2 = Promise<Int> { _, reject in
            waitTime(0.2) { reject(PromiseError.default) }
        }
        Promises.zip(p1, p2).then { _, _ in
            XCTFail("testZipAsynchronousPromisesFails failed")
        }.onError { _ in
            block.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    // 3 promises
    
    func testZip3SynchronousPromises() {
        let block = expectation(description: "Block called")
        Promises.zip(Promise(1), Promise("Hello"), Promise(0.45)).then { int, string, double in
            XCTAssertEqual(int, 1)
            XCTAssertEqual(string, "Hello")
            XCTAssertEqual(double, 0.45)
            
            block.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testZip3AsynchronousPromises() {
        let block = expectation(description: "Block called")
        let p1 = Promise { resolve, _ in
            waitTime(0.1) { resolve("Cool") }
        }
        let p2 = Promise { resolve, _ in
            waitTime(0.2) { resolve(23) }
        }
        let p3 = Promise { resolve, _ in
            waitTime(0.1) { resolve(0.45) }
        }
        Promises.zip(p1, p2, p3).then { string, int, double in
            XCTAssertEqual(string, "Cool")
            XCTAssertEqual(int, 23)
            XCTAssertEqual(double, 0.45)
            block.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testZip3SynchronousPromisesFails() {
        let block = expectation(description: "Block called")
        Promises.zip(Promise<Int>.reject(), Promise("Hello"), Promise<Double>.reject()).then { _, _, _ in
            XCTFail("testZip3SynchronousPromisesFails failed")
        }.onError { _ in
            block.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testZip3AsynchronousPromisesFails() {
        let block = expectation(description: "Block called")
        let p1 = Promise { resolve, _ in
            waitTime(0.2) { resolve("Cool") }
        }
        let p2 = Promise<Int> { _, reject in
            waitTime(0.1) { reject(PromiseError.default) }
        }
        let p3 = Promise { resolve, _ in
            waitTime(0.1) { resolve(0.45) }
        }
        Promises.zip(p1, p2, p3).then { _, _, _ in
            XCTFail("testZip3AsynchronousPromisesFails failed")
        }.onError { _ in
            block.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
