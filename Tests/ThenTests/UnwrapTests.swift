//
//  UnwrapTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 18/03/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
struct UnwrapTests {
    
    @Test
    func uwrapWorks() {
        let username: String? = "JohnDoe"
        unwrap(username).then { s in
            #expect(s == username)
        }
        .onError { _ in
            Issue.record("testUwrap failed")
        }
    }
    
    @Test
    func uwrapFails() {
        let username: String? = nil
        unwrap(username).then { _ in
            Issue.record("testUwrapFails failed")
        }.onError { e in
            if let pe = e as? PromiseError {
                #expect(pe == .unwrappingFailed)
            } else {
                Issue.record("testUwrapFails failed")
            }
        }
    }
}
