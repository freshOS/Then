//
//  ChainTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 13/03/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
struct ChainTests {
    
    @Test
    func chainSyncPromise() async {
        _ = await confirmation { done in
            Promise<String>.resolve("Cool").chain { s in
                #expect(s == "Cool")
                done()
            }.then { _ in
                print("OK")
            }
        }
    }
    
    @Test
    func chainASyncPromise() async {
        let name = await withCheckedContinuation { continuation in
            fetchUserNameFromId(123).chain { s in
                
            } .then { s2 in
                continuation.resume(returning: s2)
            }
        }
        #expect(name == "John Smith")
    }
    
    @Test
    func chainNotCalledWhenSyncPromiseFails() async {
        _ = await confirmation { done in
            Promise<Int>.reject().chain { _ in
                Issue.record("testChainNotCalledWhenSyncPromiseFails failed")
            }.onError { _ in
                done()
            }
        }
    }
    
    @Test
    func chainNotCalledWhenAsyncPromiseFails() async {
        let name = await withCheckedContinuation { continuation in
            failingFetchUserFollowStatusFromName("Tom").chain { _ in
                continuation.resume(returning: "failed")
            }.onError { _ in
                continuation.resume(returning: "works")
            }
        }
        #expect(name == "works")
    }

    @Test
    func chainKeepsProgress() async {
        var chainCalled = false
        var progress: Float = 0
        
        let name: String = await withCheckedContinuation { continuation in
            upload().chain {
                chainCalled = true
            }.progress { p in
                progress = p
            }.then {
                continuation.resume(returning: "OK")
            }.onError { _ in
                Issue.record("error should'nt be called")
            }
        }
        #expect(name == "OK")
        #expect(chainCalled)
        #expect(progress == 0.8)
    }
}
