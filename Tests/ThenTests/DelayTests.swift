//
//  DelayTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 09/08/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
actor DelayTests {

    @Test
    func staticDelay() async {
        let name = await withCheckedContinuation { continuation in
            Promises.delay(0.2).then {
                self.ran = true
            }
            waitTime(0.1) {
                Task {
                    await self.setRan1(self.ran)
                }
            }
            
            waitTime(0.5) {
                Task {
                    await self.setRan2(self.ran)
                    continuation.resume(returning: "done")
                }
            }
        }
        
        #expect(!ran1)
        #expect(ran2)
        #expect(name == "done")
    }

    
    var result: Int?
    var result1: Int?
    var result2: Int?
    
    func setResult(_ value: Int?) {
        result = value
    }
    
    func setResult1(_ value: Int?) {
        result1 = value
    }
    
    func setResult2(_ value: Int?) {
        result2 = value
    }
    
    @Test
    func delay() async {
        let name = await withCheckedContinuation { continuation in
            Promise { resolve, _ in
                waitTime(0.1) {
                    resolve(123)
                }
            }
            .delay(0.1)
            .then { int in
                Task {
                    self.setResult(int)
                }
            }
            
            waitTime(0.1) {
                Task {
                    await self.setResult1(self.result)
                }
            }
            waitTime(0.7) {
                Task {
                    await self.setResult2(self.result)
                    continuation.resume(returning: "done")
                }
                
                
            }
        }
        #expect(result1 == nil)
        #expect(result2 == 123)
        #expect(name == "done")
    }
    
    var ran = false
    var ran1 = false
    var ran2 = false
    
    func setRan(_ value: Bool) {
        ran = value
    }
    
    func setRan1(_ value: Bool) {
        ran1 = value
    }
    
    func setRan2(_ value: Bool) {
        ran2 = value
    }
    
    @Test
    func chainDelays() async {
        let name = await withCheckedContinuation { continuation in
            Promises
                .delay(0.1)
                .delay(0.1)
                .delay(0.1)
                .then {
                    self.ran = true
            }
            waitTime(0.2) {
                Task {
                    await self.setRan1(self.ran)
                }
            }
            waitTime(1) {
                Task {
                    await self.setRan2(self.ran)
                    continuation.resume(returning: "done")
                }
            }
        }
        #expect(!ran1)
        #expect(ran2)
        #expect(name == "done")
    }
    
    @Test
    func delayOnlyAppliesOnSuccessfulPromises() async {
        var done = false
        let name = await withCheckedContinuation { continuation in
            Promise<Int> { _, reject in
                waitTime(0.2) {
                    reject(PromiseError.default)
                }
            }
            .delay(0.8)
            .then { _ in
                Issue.record("testDelayOnlyAppliesOnSuccessfulPromises failed")
            }.onError { _ in
                done = true
            }
            waitTime(0.3) {
                continuation.resume(returning: "done")
            }
        }
        #expect(done)
        #expect(name == "done")
    }
}
