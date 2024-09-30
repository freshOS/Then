//
//  ThenTests.swift
//  ThenTests
//
//  Created by Sacha Durand Saint Omer on 06/02/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Testing
@testable import Then

@Suite
struct ThenTests {
    
    @Test
    func then() async {
        var isFollowed = true
        let result = await withCheckedContinuation { continuation in
            fetchUserId()
                .then(fetchUserNameFromId)
                .then(fetchUserFollowStatusFromName)
                .then { isFollowedValue -> Void in
                    isFollowed = isFollowedValue
                }.onError { _ in
                    Issue.record("on Error shouldn't be called")
                }.finally {
                    continuation.resume(returning: "finally")
                }
        }
        #expect(!isFollowed)
        #expect(result == "finally")
    }
    
    @Test
    func chainedPromises() async {
        let result = await withCheckedContinuation { continuation in
            fetchUserId()
                .then(fetchUserNameFromId(1))
                .then(fetchUserNameFromId(2))
                .then(fetchUserNameFromId(3)).then { name in
                    continuation.resume(returning: "then")
                }
        }
        #expect(result == "then")
    }

    @Test
    func testChainedPromisesAreExecutedInOrder() async {
        var count = 0
        var block1Called = false
        var block2Called = false
        var block3Called = false
        let result = await withCheckedContinuation { continuation in
            fetchUserId()
                .then(fetchUserNameFromId(1)).then({ _ in
                    #expect(count == 0)
                    count+=1
                    block1Called = true
                })
                .then(fetchUserNameFromId(2)).then {_ in
                    #expect(count == 1)
                    count+=1
                    block2Called = true
                }
                .then(fetchUserNameFromId(3)).then { _ in
                    #expect(count == 2)
                    count+=1
                    block3Called = true
                }
                .then(fetchUserNameFromId(4)).then { name in
                    #expect(count == 3)
                    count+=1
                    continuation.resume(returning: "then")
                }
        }
        #expect(result == "then")
        #expect(block1Called)
        #expect(block2Called)
        #expect(block3Called)
    }

    
    @Test
    func synchronousChainsWorksProprely() async {
        globalCount = 0
        let result = await withCheckedContinuation { continuation in
            promiseA()
                .then(promiseB())
                .then(promiseC(completion: {
                    continuation.resume(returning: "then")
                }))
        }
        #expect(result == "then")
    }
    
    @Test
    func classicThenLaunchesPromise() async {
        let result = await withCheckedContinuation { continuation in
            fetchUserId().then { id in
                continuation.resume(returning: id)
            }
        }
        #expect(result == 1234)
    }
    
    @Test
    func multipleThenBlockCanBeRegisteredOnSamePromise() async {
        var then1Called = false
        var then2Called = false
        var then3Called = false
        let result = await withCheckedContinuation { continuation in
            let p = fetchUserId()
            p.then { _ in
                then1Called = true
            }
            p.then { _ in
                then2Called = true
            }
            p.then { _ in
                then3Called = true
            }
            p.then { _ in
                continuation.resume(returning: "then")
            }
        }
        #expect(then1Called)
        #expect(then2Called)
        #expect(then3Called)
        #expect(result == "then")
    }

    @Test
    func thenWorksAfterErrorBlock() async {
        var then1Called = false
        let result = await withCheckedContinuation { continuation in
            fetchUserId()
                .then { _ in
                    then1Called = true
                }.onError { _ in
                    Issue.record("on Error shouldn't be called")
                }.then {
                    continuation.resume(returning: "then")
                }
        }
        #expect(then1Called)
        #expect(result == "then")
    }
    
    @Test
    func canContinueWithThenAfterErrorBlock() async {
        var onErrorCalled = false
        let result = await withCheckedContinuation { continuation in
            failingFetchUserFollowStatusFromName("")
                .then { _ in
                    Issue.record("testCanContinueWithThenAfterErrorBlock failed")
                }.onError { _ in
                    onErrorCalled = true
                }.then {
                    continuation.resume(returning: "then")
                }
        }
        #expect(onErrorCalled)
        #expect(result == "then")
    }
}
