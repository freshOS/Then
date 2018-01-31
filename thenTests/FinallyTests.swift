//
//  FinallyTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 23/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
import then

class FinallyTests: XCTestCase {
    
    func testFinallyCalledWhenSynchronousSuccess() {
        let finallyblock = expectation(description: "finally block block called")
        Promise.resolve("Done").finally {
            finallyblock.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testFinallyCalledWhenSynchronousFail() {
        let finallyblock = expectation(description: "finally block block called")
        Promise<String>.reject().finally {
            finallyblock.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testFinallyCalledWhenAsynchronousSuccess() {
        let finallyblock = expectation(description: "finally block block called")
        Promise<String> { resolve, _ in
            waitTime(0.1) {
                resolve("Hello")
            }
        }.finally {
            finallyblock.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testFinallyCalledWhenAsynchronousFail() {
        let finallyblock = expectation(description: "finally block block called")
        Promise<String> { _, reject in
            waitTime(0.1) {
                reject(PromiseError.default)
            }
        }.finally {
            finallyblock.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testMultipleFinallyBlockCanBeRegisteredOnSamePromise() {
        let finally1 = expectation(description: "finally called")
        let finally2 = expectation(description: "finally called")
        let finally3 = expectation(description: "finally called")
        let finally4 = expectation(description: "finally called")
        let p = failingFetchUserFollowStatusFromName("")
        p.finally {
            finally1.fulfill()
        }
        p.finally {
            finally2.fulfill()
        }
        p.finally {
            finally3.fulfill()
        }
        p.finally {
            finally4.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testRegisterFinallyDoesntStartThePromise() {
        let exp = expectation(description: "error block called")
        syncRejectionPromise().registerFinally {
             XCTFail("testRegisterFinallyDoesntStartThePromise failed")
        }
        waitTime(0.1) {
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testRegisterFinally() {
        let exp = expectation(description: "error block called")
        let p = syncRejectionPromise()
        p.registerFinally {
            exp.fulfill()
        }
        p.start()
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
