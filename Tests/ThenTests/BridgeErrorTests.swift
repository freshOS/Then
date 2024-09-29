//
//  BridgeErrorTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 24/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
struct BridgeErrorTests {
    
    @Test
    func bridgeAllErrorsToMine() async {
        _ = await confirmation { done in
            Promise<Int>.reject()
                .bridgeError(to: MyError.defaultError)
                .then { _ in
                    Issue.record("then shouldn't be called")
                }.onError { e in
                    if let e = e as? MyError {
                        #expect(e == .defaultError)
                    } else {
                        Issue.record("testBridgeAllErrorsToMine failed")
                    }
                    done()
                }
        }
    }
    
    @Test
    func bridgeAllErrorsNoError() async {
        _ = await confirmation { done in
            Promise<Int>.resolve(42)
                .bridgeError(to: MyError.defaultError)
                .then { _ in
                    done()
                }.onError { _ in
                    Issue.record("onError shouldn't be called")
                }
        }
    }
    
    @Test
    func bridgeASpecificErrorToMine() async {
        _ = await confirmation { done in
            Promise<Int>.reject(PromiseError.retryInvalidInput)
                .bridgeError(PromiseError.retryInvalidInput, to: MyError.defaultError)
                .then { _ in
                    Issue.record("then shouldn't be called")
                }.onError { e in
                    if let e = e as? MyError {
                        #expect(e == .defaultError)
                    } else {
                        Issue.record("testBridgeASpecificErrorToMine failed")
                    }
                    done()
                }
        }
    }
    
    @Test
    func bridgeASpecificErrorToMineNotMatchingError() async {
        _ = await confirmation { done in
            Promise<Int>.reject(PromiseError.default)
                .bridgeError(PromiseError.retryInvalidInput, to: MyError.defaultError)
                .then { _ in
                    Issue.record("then shouldn't be called")
                }.onError { e in
                    if let e = e as? PromiseError {
                        #expect(e == .default)
                    } else {
                        Issue.record("testBridgeASpecificErrorToMineNotMatchingError failed")
                    }
                    done()
                }
        }
    }
    
    @Test
    func bridgeErrorCanUseBlockAndThrow() async {
        _ = await confirmation { done in
            Promise<Int>.reject()
                .bridgeError { _ in
                    throw MyError.defaultError
                }
                .then { _ in
                    Issue.record("then shouldn't be called")
                }.onError { e in
                    if let e = e as? MyError {
                        #expect(e == .defaultError)
                    } else {
                        Issue.record("failed testBridgeErrorCanUseBlockAndThrow")
                    }
                    done()
                }
        }
    }
}
