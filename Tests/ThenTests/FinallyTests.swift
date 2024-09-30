//
//  FinallyTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 23/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
struct FinallyTests {
    
    @Test
    func finallyCalledWhenSynchronousSuccess() async {
        await confirmation { done in
            Promise.resolve("Done").finally {
                done()
            }
        }
    }
    
    @Test
    func finallyCalledWhenSynchronousFail() async {
        await confirmation { done in
            Promise<String>.reject().finally {
                done()
            }
        }
    
    }
    
    @Test
    func finallyCalledWhenAsynchronousSuccess() async {
        await withCheckedContinuation { continuation in
            Promise<String> { resolve, _ in
                waitTime(0.1) {
                    resolve("Hello")
                }
            }.finally {
                continuation.resume()
            }
        }
    }
    
    @Test
    func finallyCalledWhenAsynchronousFail() async {
        await withCheckedContinuation { continuation in
            Promise<String> { _, reject in
                waitTime(0.1) {
                    reject(PromiseError.default)
                }
            }.finally {
                continuation.resume()
            }
        }
    }
    
    @Test
    func testMultipleFinallyBlockCanBeRegisteredOnSamePromise() async {
        var finally1 = false
        var finally2 = false
        var finally3 = false
        let name = await withCheckedContinuation { continuation in
            let p = failingFetchUserFollowStatusFromName("")
            p.finally {
                finally1 = true
            }
            p.finally {
                finally2 = true
            }
            p.finally {
                finally3 = true
            }
            p.finally {
                continuation.resume(returning: "done")
            }
        }
        #expect(finally1)
        #expect(finally2)
        #expect(finally3)
        #expect(name == "done")
    }

    @Test
    func finallyDoesntStartThePromise() async {
        await withCheckedContinuation { continuation in
            syncRejectionPromise().registerFinally {
                Issue.record("testRegisterFinallyDoesntStartThePromise failed")
            }
            waitTime(0.1) {
                continuation.resume()
            }
        }
    }
    
    @Test
    func registerFinally() async {
        await confirmation { done in
            let p = syncRejectionPromise()
            p.registerFinally {
                done()
            }
            p.start()
        }
    }
}
