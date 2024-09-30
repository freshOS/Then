//
//  OnErrorTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
struct OnErrorTests {

    @Test
    func error() async {
        var error: Error? = nil
        let result = await withCheckedContinuation { continuation in
            fetchUserId()
                .then(fetchUserNameFromId)
                .then(failingFetchUserFollowStatusFromName)
                .then { _ in
                    Issue.record("then block shouldn't be called")
                }.onError { e in
                    error = e
                }.finally {
                    continuation.resume(returning: "finally")
                }
        }
        #expect((error as? MyError) == MyError.defaultError)
        #expect(result == "finally")
    }
    
    @Test
    func onErrorCalledWhenSynchronousRejects() async {
        let result = await withCheckedContinuation { continuation in
            promise1()
                .then(syncRejectionPromise())
                .then(syncRejectionPromise())
                .onError { _ in
                    continuation.resume(returning: "error")
                }
        }
        #expect(result == "error")
    }

    @Test
    func testThenAfterOnErrorWhenSynchronousResolves() async {
        let result = await withCheckedContinuation { continuation in
            promise1()
                .then(promise1())
                .onError { _ in
                    continuation.resume(returning: "error")
                }.then { _ in
                    continuation.resume(returning: "then")
                }
        }
        #expect(result == "then")
    }

    @Test
    func testMultipleErrorBlockCanBeRegisteredOnSamePromise() async {
        var onError1Called = false
        var onError2Called = false
        var onError3Called = false
        let result = await withCheckedContinuation { continuation in
            let p = failingFetchUserFollowStatusFromName("")
            p.onError { _ in
                onError1Called = true
            }
            p.onError { _ in
                onError2Called = true
            }
            p.onError { _ in
                onError3Called = true
            }
            p.onError { _ in
                continuation.resume(returning: "onError4")
            }
        }
        #expect(onError1Called)
        #expect(onError2Called)
        #expect(onError3Called)
        #expect(result == "onError4")
    }

    @Test
    func twoConsecutivErrorBlocks2ndShouldNeverBeCalledOnFail() async {
        let result = await withCheckedContinuation { continuation in
            failingFetchUserFollowStatusFromName("")
                .then { _ in
                    Issue.record("then shouldn't be called")
                }.onError { _ in
                    continuation.resume(returning: "onError")
                }.onError { _ in
                    Issue.record("Second on Error shouldn't be called")
                }
        }
        #expect(result == "onError")
    }
    
    @Test
    func twoConsecutivErrorBlocks2ndShouldNeverBeCalledOnSuccess() async {
        let result = await withCheckedContinuation { continuation in
            fetchUserId()
                .then { _ in
                    continuation.resume(returning: "then")
                }.onError { _ in
                    Issue.record("on Error shouldn't be called")
                }.onError { _ in
                    Issue.record("on Error shouldn't be called")
                }.onError { _ in
                    Issue.record("on Error shouldn't be called")
                }.onError { _ in
                    Issue.record("on Error shouldn't be called")
                }.onError { _ in
                    Issue.record("on Error shouldn't be called")
                }.onError { _ in
                    Issue.record("on Error shouldn't be called")
                }.onError { _ in
                    Issue.record("on Error shouldn't be called")
                }.onError { _ in
                    Issue.record("on Error shouldn't be called")
                }
        }
        #expect(result == "then")
    }

    @Test
    func registerOnErrorDoesntStartThePromise() async {
        let result = await withCheckedContinuation { continuation in
            syncRejectionPromise().registerOnError { _ in
                continuation.resume(returning: "registerOnError")
            }
            waitTime(0.1) {
                continuation.resume(returning: "done")
            }
        }
        #expect(result == "done")
    }

    @Test
    func registerOnError() async {
        let result = await withCheckedContinuation { continuation in
            let p = syncRejectionPromise()
            p.registerOnError { _ in
                continuation.resume(returning: "registerOnError")
            }
            p.start()
        }
        #expect(result == "registerOnError")
    }
}
