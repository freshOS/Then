//
//  RegisterThenTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
struct RegisterThenTests {

    @Test
    func registerThenChainedPromisesAreNeverCalledWithoutAThenBlock() async {
        let result = await withCheckedContinuation { continuation in
            fetchUserId()
                .registerThen { _ in
                    Issue.record("testRegisterThenChainedPromisesAreNeverCalledWithoutAThenBlock failed")
                }.registerThen {_ in
                    Issue.record("testRegisterThenChainedPromisesAreNeverCalledWithoutAThenBlock failed")
                }.registerThen {_ in
                    Issue.record("testRegisterThenChainedPromisesAreNeverCalledWithoutAThenBlock failed")
                }
            waitTime(0.3) {
                continuation.resume(returning: "done")
            }
        }
        #expect(result == "done")
    }
    
    @Test
    func registerThenPromiseChainedPromisesAreNeverCalledWithoutAThenBlock() async {
        let result = await withCheckedContinuation { continuation in
            fetchUserId()
                .registerThen(fetchUserNameFromId(10))
                .registerThen { name in
                    Issue.record("testRegisterThenPromiseChainedPromisesAreNeverCalledWithoutAThenBlock failed")
                }.registerThen {_ in
                    Issue.record("testRegisterThenPromiseChainedPromisesAreNeverCalledWithoutAThenBlock failed")
                }.registerThen {_ in
                    Issue.record("testRegisterThenPromiseChainedPromisesAreNeverCalledWithoutAThenBlock failed")
                }
            waitTime(0.3) {
                continuation.resume(returning: "done")
            }
        }
        #expect(result == "done")
    }
    
    @Test
    func registerThenPromise2ChainedPromisesAreNeverCalledWithoutAThenBlock() async {
        let result = await withCheckedContinuation { continuation in
            fetchUserId().registerThen { id in
                return fetchUserNameFromId(id)
            }.registerThen { _ in
                Issue.record("testRegisterThenPromise2ChainedPromisesAreNeverCalledWithoutAThenBlock failed")
            }.registerThen { _ in
                Issue.record("testRegisterThenPromise2ChainedPromisesAreNeverCalledWithoutAThenBlock failed")
            }
            waitTime(0.3) {
                continuation.resume(returning: "done")
            }
        }
        #expect(result == "done")
    }
    
    @Test
    func registerThenChainedPromisesAreExecutedInOrder() async {
        var count = 0
        
        var block1Called = false
        var block2Called = false
        var block3Called = false
        
        let result = await withCheckedContinuation { continuation in
            fetchUserId()
                .registerThen { _ -> Void in
                    #expect(count == 0)
                    count+=1
                    block1Called = true
                }.registerThen {_ -> Void in
                    #expect(count == 1)
                    count+=1
                    block2Called = true
                }.registerThen {_ -> Void in
                    #expect(count == 2)
                    count+=1
                    block3Called = true
                }.then { name in
                    #expect(count == 3)
                    count+=1
                    continuation.resume(returning: "done")
                }
        }
        #expect(block1Called)
        #expect(block2Called)
        #expect(block3Called)
        #expect(result == "done")
    }
    
    @Test
    func registerThenPromiseFuncPointerNotCalled() async {
        let result = await withCheckedContinuation { continuation in
            fetchUserId()
                .registerThen(fetchUserNameFromId)
                .registerThen { _ in
                    Issue.record("testRegisterThenPromiseFuncPointerNotCalled failed")
                }
            waitTime(0.3) {
                continuation.resume(returning: "done")
            }
        }
        #expect(result == "done")
    }
    
    @Test
    func registerThenPromise2FuncPointerNotCalled() async {
        let result = await withCheckedContinuation { continuation in
            fetchUserId().registerThen { id -> Promise<String> in
                return fetchUserNameFromId(id)
            }.registerThen { _ in
                Issue.record("testRegisterThenPromise2FuncPointerNotCalled failed")
            }
            waitTime(0.3) {
                continuation.resume(returning: "done")
            }
        }
        #expect(result == "done")
    }
    
    @Test
    func registerThenPromiseFuncPointerCalledWithThenBlock() async {
        let result = await withCheckedContinuation { continuation in
            fetchUserId()
                .registerThen(fetchUserNameFromId)
                .then { _ in
                    continuation.resume(returning: "done")
                }
        }
        #expect(result == "done")
    }
    
    @Test
    func testRegisterThenPromise2FuncPointerCalledWithThenBlock() async {
        let result = await withCheckedContinuation { continuation in
            fetchUserId().registerThen { id -> Promise<String> in
                return fetchUserNameFromId(id)
            }.then { _ in
                continuation.resume(returning: "done")
            }
        }
        #expect(result == "done")
    }
    
    @Test
    func testRegisterThenPromiseFuncPointerCalledWithMultipleRegisterThenBlocks() async {
        let result = await withCheckedContinuation { continuation in
            fetchUserId()
                .registerThen(fetchUserNameFromId)
                .registerThen(fetchUserFollowStatusFromName)
                .then { _ in
                    continuation.resume(returning: "done")
                }
        }
        #expect(result == "done")
    }
    
    @Test
    func testRegisterThenMultipleThenOnlyCallOriginalPromiseOnce() async {
        var count = 0
        
        var block1Called = false
        var block2Called = false
        var block3Called = false
        
        let result = await withCheckedContinuation { continuation in
            fetchUserId()
                .registerThen { _ -> Void in
                    #expect(count == 0)
                    count+=1
                    block1Called = true
                }.registerThen {_ -> Void in
                    #expect(count == 1)
                    count+=1
                    block2Called = true
                }.registerThen { _ -> Void in
                    #expect(count == 2)
                    count+=1
                    block3Called = true
                }
                .then { name in
                    #expect(count == 3)
                    count+=1
                    continuation.resume(returning: "done")
                }
                .then { _ -> Void in
                    print("Just another then block")
                }
        }
        #expect(block1Called)
        #expect(block2Called)
        #expect(block3Called)
        #expect(result == "done")
    }
}
