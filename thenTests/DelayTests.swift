//
//  DelayTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 09/08/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
import then

class DelayTests: XCTestCase {
    
    func testfoo() {
//        
//        Promises.delay(4.5).then {
//            
//        }
//        
//        Promise("").delay(4.5).then { _ in
//            
//        
//        }
   
    }
    
    func testTimeOutTriggers() {
        let e = expectation(description: "")
        Promise<String> { resolve, _ in
            waitTime(1) {
                resolve("Hello")
            }
        }.timeout(2).then { string in
            print("OK \(string)")
            e.fulfill()
        }.onError { e in
            XCTFail()
            print("Error \(e)")
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testTimeOutFails() {
        let e = expectation(description: "")
        Promise<String> { resolve, _ in
            waitTime(1) {
                resolve("Hello")
            }
        }.timeout(0.5).then { string in
            print("OK \(string)")
            XCTFail()
        }.onError { error in
            print("Error \(error)")
            if let error = error as? PromiseError {
                XCTAssertTrue(error == .timeout)
            } else {
                XCTFail()
            }
            e.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
}
