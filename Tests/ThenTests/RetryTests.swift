//
//  RetryTests RetryTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 22/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
actor RetryTests {
    
    var tryCount = 0
    
    @Test
    func retryNumberWhenKeepsFailing() async {
        let result = await withCheckedContinuation { continuation in
            testPromise()
                .retry(5)
                .then {
                    continuation.resume(returning: "then")
                }.onError { _ in
                    continuation.resume(returning: "onError")
                }
        }
        #expect(result == "onError")
        #expect(tryCount == 5)
    }
    
    @Test
    func retrySucceedsAfter3times() async {
        let result = await withCheckedContinuation { continuation in
            succeedsAfter3Times()
                .retry(10)
                .then {
                    continuation.resume(returning: "then")
                }.onError { _ in
                    continuation.resume(returning: "onError")
                }
        }
        #expect(result == "then")
        #expect(tryCount == 3)
    }
    
    @Test
    func testRetryFailsIfNumberOfRetriesposisitethan1() async {
        let result = await withCheckedContinuation { continuation in
            testPromise()
                .retry(0)
                .onError { _ in
                    continuation.resume(returning: "onError")
                }
        }
        #expect(result == "onError")
    }
    
    func incrementCount() {
        tryCount += 1
    }
    
    func testPromise() -> Promise<Void> {
        return Promise { resolve, reject in
            Task {
                await self.incrementCount()
                waitTime(0.1) {
                    reject(ARandomError())
                }
            }
        }
    }
  
    func succeedsAfter3Times() -> Promise<Void> {
        return Promise { resolve, reject in
            Task {
                await self.incrementCount()
                if await self.tryCount == 3 {
                    resolve(())
                } else {
                    reject(ARandomError())
                }
            }
        }
    }
}

struct ARandomError: Error { }
