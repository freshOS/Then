//
//  RaceTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 22/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
struct RaceTests {
    
    func asyncRaceFirstArrivesFirst() async{
        let result = await withCheckedContinuation { continuation in
            let p1 = Promise<String> { r, _ in
                waitTime(0.1) {
                    r("1")
                }
            }
            let p2 = Promise<String> { r, _ in
                waitTime(0.3) {
                    r("2")
                }
            }
            Promises.race(p1, p2).then { s in
                continuation.resume(returning: s)
            }
        }
        #expect(result == "1")
    }
    
    @Test
    func testSyncRaceFirstArrivesFirst() async {
        let result = await withCheckedContinuation { continuation in
            let p1 = Promise("1")
            let p2 = Promise("2")
            Promises.race(p1, p2).then { s in
                continuation.resume(returning: s)
            }
        }
        #expect(result == "1")
    }
    
    struct TestRaceError: Error {}
    
    @Test
    func asyncRaceWithFirsFailingFails() async {
        let result = await withCheckedContinuation { continuation in
            let p1 = Promise<String>.reject(TestRaceError())
            let p2 = Promise<String> { r, _ in
                waitTime(2) {
                    r("2")
                }
            }
            Promises.race(p1, p2).onError { error in
                guard error as? TestRaceError != nil else {
                    Issue.record("testRecoverCanThrowANewError failed")
                    return
                }
                continuation.resume(returning: "done")
            }
        }
        #expect(result == "done")
    }
    
    @Test
    func asyncRaceWithSecondFailingSuceeds() async {
        let result = await withCheckedContinuation { continuation in
            let p1 = Promise("1")
            let p2 = Promise<String> { r, _ in
                waitTime(2) {
                    r("2")
                }
            }
            Promises.race(p1, p2).then { s in
                continuation.resume(returning: s)
            }
        }
        #expect(result == "1")
    }
    
    @Test
    func raceFailsIfAllFail() async {
        let result = await withCheckedContinuation { continuation in
            let p1 = Promise<String>.reject()
            let p2 = Promise<String>.reject()
            Promises.race(p1, p2).then { _ in
                Issue.record("testRaceFailsIfAllFail failed")
            }.onError { _ in
                continuation.resume(returning: "error")
            }
        }
        #expect(result == "error")
    }
}
