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
    
    func testFinallyCalledWhenSynchronous() {
        let finallyblock = expectation(description: "error block called")
        syncRejectionPromise().finally {
            finallyblock.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
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
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testRegisterFinallyDoesntStartThePromise() {
        let exp = expectation(description: "error block called")
        syncRejectionPromise().registerFinally {
             XCTFail()
        }
        wait(1) {
            exp.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRegisterFinally() {
        let exp = expectation(description: "error block called")
        let p = syncRejectionPromise()
        p.registerFinally {
            exp.fulfill()
        }
        p.start()
        waitForExpectations(timeout: 1, handler: nil)
    }
}
