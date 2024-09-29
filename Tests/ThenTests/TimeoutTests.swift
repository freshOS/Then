//
//  TimeoutTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 10/08/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
struct TimeoutTests {
    
    @Test
    func timeOutTriggers() async {
        let name = await withCheckedContinuation { continuation in
            Promise<String> { resolve, _ in
                waitTime(0.1) {
                    resolve("Hello")
                }
            }
            .timeout(0.2)
            .then { string in
                continuation.resume(returning: string)
            }
            .onError { _ in
                Issue.record("testTimeOutTriggers failed")
            }
        }
        #expect(name == "Hello")
    }
    
    @Test
    func testTimeOutFails() async {
        let name = await withCheckedContinuation { continuation in
            Promise<String> { resolve, _ in
                waitTime(0.3) {
                    resolve("Hello")
                }
            }
            .timeout(0.1)
            .then { _ in
                Issue.record("testTimeOutFails failed")
            }
            .onError { error in
                if case PromiseError.timeout = error {
                    // Good
                } else {
                    Issue.record("testTimeOutFails failed")
                }
                continuation.resume(returning: "erroring")
            }
        }
        #expect(name == "erroring")
    }
}
