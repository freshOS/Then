////
////  DelayTests.swift
////  then
////
////  Created by Sacha Durand Saint Omer on 09/08/2017.
////  Copyright © 2017 s4cha. All rights reserved.
////
//
//import Testing
//import Then
//
//@Suite
//actor DelayTests {
//    
////    var ran = false
////    var ran1 = false
////    var ran2 = false
////    
////    @Test
////    func staticDelay() async {
////        let name = await withCheckedContinuation { continuation in
////            Promises.delay(0.2).then {
////                self.ran = true
////            }
////            waitTime(0.1) {
////                self.ran1 = self.ran
////            }
////            waitTime(0.3) {
////                self.ran2 = self.ran
////                continuation.resume(returning: "done")
////            }
////        }
////        
////        #expect(!ran1)
////        #expect(ran2)
////        #expect(name == "done")
////    }
////    
////    @Test
////    func delay() async {
////        var result: Int?
////        var result1: Int?
////        var result2: Int?
////        let name = await withCheckedContinuation { continuation in
////            Promise { resolve, _ in
////                waitTime(0.1) {
////                    resolve(123)
////                }
////            }
////            .delay(0.1)
////            .then { int in
////                result = int
////            }
////            
////            waitTime(0.1) {
////                result1 = result
////            }
////            waitTime(0.3) {
////                result2 = result
////                continuation.resume(returning: "done")
////            }
////        }
////        #expect(result1 == nil)
////        #expect(result2 == 123)
////        #expect(name == "done")
////    }
////    
////
////    
////    @Test
////    func chainDelays() async {
////        var ran = false
////        var ran1 = false
////        var ran2 = false
////        let name = await withCheckedContinuation { continuation in
////            Promises
////                .delay(0.1)
////                .delay(0.1)
////                .delay(0.1).then {
////                    ran = true
////                    print(ran)
////                
////            }
////            waitTime(0.2) {
////                ran1 = ran
////            }
////            waitTime(0.4) {
////                print(ran)
////                ran2 = ran
////                continuation.resume(returning: "done")
////            }
////        }
////        #expect(!ran1)
////        #expect(ran2)
////        #expect(name == "done")
////    }
////    
////    @Test
////    func delayOnlyAppliesOnSuccessfulPromises() async {
////        var done = false
////        let name = await withCheckedContinuation { continuation in
////            Promise<Int> { _, reject in
////                waitTime(0.2) {
////                    reject(PromiseError.default)
////                }
////            }
////            .delay(0.8)
////            .then { _ in
////                Issue.record("testDelayOnlyAppliesOnSuccessfulPromises failed")
////            }.onError { _ in
////                done = true
////            }
////            waitTime(0.3) {
////                continuation.resume(returning: "done")
////            }
////        }
////        #expect(done)
////        #expect(name == "done")
////    }
//}
