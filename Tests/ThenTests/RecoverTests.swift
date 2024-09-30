//
//  RecoverTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 22/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
struct RecoverTests {
    
    @Test
    func recoverWithString() async {
        let result = await withCheckedContinuation { continuation in
            Promise<String>.reject()
                .recover(with: "Banana")
                .then { s in
                    continuation.resume(returning: s)
                }
        }
        #expect(result == "Banana")
    }
    
    @Test
    func recoverWithInt() async {
        let result = await withCheckedContinuation { continuation in
            Promise<Int>.reject()
                .recover(with: 12)
                .then { s in
                    continuation.resume(returning: s)
                }
        }
        #expect(result == 12)
    }
    
    @Test
    func recoverWithPromise() async {
        let result = await withCheckedContinuation { continuation in
            Promise<Int>.reject()
                .recover(with: Promise<Int>.resolve(56))
                .then { s in
                    continuation.resume(returning: s)
                }
        }
        #expect(result == 56)
    }
    
    @Test
    func recoverWithFailablePromise() async {
        let result = await withCheckedContinuation { continuation in
            Promise<Int>.reject()
                .recover(with: Promise<Int>.reject())
                .then { _ in
                    Issue.record("then shouldn't be called")
                }
                .onError { _ in
                    continuation.resume(returning: "onError")
                }
        }
        #expect(result == "onError")
    }
    
    @Test
    func testRecoverCanUseABlock() async {
        let result = await withCheckedContinuation { continuation in
            Promise<Int>.reject()
                .recover { _ in
                    return 32
                }
                .then { s in
                    continuation.resume(returning: s)
                }
        }
        #expect(result == 32)
    }
    
    @Test
    func recoverCanThrowANewError() async {
        var error: Error? = nil
        let result = await withCheckedContinuation { continuation in
            Promise<Int>.reject()
                .recover { e -> Int in
                    if let e = e as? PromiseError, e == .default {
                        throw MyError.defaultError
                    }
                    return 32
                } .then { _ in
                    continuation.resume(returning: "then")
                }.onError { e in
                    error = e
                    continuation.resume(returning: "onError")
                }
        }
        #expect(error as? MyError == MyError.defaultError)
        #expect(result == "onError")
    }
    
    @Test
    func recoverForSpecificError() async {
        let result = await withCheckedContinuation { continuation in
            Promise<Int>.resolve(10)
                .validate { $0 > 100 }
                .recover(PromiseError.validationFailed, with: 123)
                .then { i in
                    continuation.resume(returning: i)
                }
        }
        #expect(result == 123)
    }
    
    @Test
    func recoverForSpecificErrorDoesNotRecoverWhenTypeNotMatching() async {
        let result = await withCheckedContinuation { continuation in
            Promise<Int>.reject()
                .recover(PromiseError.validationFailed, with: 123)
                .then { _ in
                    continuation.resume(returning: "then")
                }.onError { _ in
                    continuation.resume(returning: "onError")
                }
        }
        #expect(result == "onError")
    }
    
    @Test
    func equatableError() async {
        let result = await withCheckedContinuation { continuation in
            Promise<Int>.reject(SomeError())
                .recover(SomeError(), with: 123)
                .then { r in
                    continuation.resume(returning: r)
                }
        }
        #expect(result == 123)
        
    }
    
    @Test
    func recoverPromiseBlockCanUseABlock() async {
        let result = await withCheckedContinuation { continuation in
            Promise<Int>.reject()
                .recover { _ in
                    return Promise(32)
                }
                .then { s in
                    continuation.resume(returning: s)
                }
        }
        #expect(result == 32)
    }
    
    @Test
    func recoverPromiseBlockCanThrowANewError() async {
        var error: Error? = nil
        let result = await withCheckedContinuation { continuation in
            Promise<Int>.reject()
                .recover { e -> Promise<Int> in
                    if let e = e as? PromiseError, e == .default {
                        throw MyError.defaultError
                    }
                    return Promise(32)
                } .then { _ in
                    continuation.resume(returning: "then")
                }.onError { e in
                    error = e
                    continuation.resume(returning: "onError")
                }
        }
        #expect(error as? MyError == MyError.defaultError)
        #expect(result == "onError")
    }
}

struct SomeError: Error { }
extension SomeError: Equatable { }
func == (lhs: SomeError, rhs: SomeError) -> Bool {
    return true
}
