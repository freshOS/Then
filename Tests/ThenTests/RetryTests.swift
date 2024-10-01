////
////  RetryTests RetryTests.swift
////  then
////
////  Created by Sacha Durand Saint Omer on 22/02/2017.
////  Copyright © 2017 s4cha. All rights reserved.
////
//
//import Testing
//import Then
//
//@Suite
//class RetryTests {
//    
//    var tryCount = 0
//    
//    @Test
//    func retryNumberWhenKeepsFailing() async {
//        let result = await withCheckedContinuation { continuation in
//            testPromise()
//                .retry(5)
//                .then {
//                    continuation.resume(returning: "then")
//                }.onError { _ in
//                    continuation.resume(returning: "onError")
//                }
//        }
//        #expect(result == "onError")
//        #expect(tryCount == 5)
//    }
//    
//    @Test
//    func retrySucceedsAfter3times() async {
//        let result = await withCheckedContinuation { continuation in
//            succeedsAfter3Times()
//                .retry(10)
//                .then {
//                    continuation.resume(returning: "then")
//                }.onError { _ in
//                    continuation.resume(returning: "onError")
//                }
//        }
//        #expect(result == "then")
//        #expect(tryCount == 3)
//    }
//    
//    @Test
//    func testRetryFailsIfNumberOfRetriesposisitethan1() async {
//        let result = await withCheckedContinuation { continuation in
//            testPromise()
//                .retry(0)
//                .onError { _ in
//                    continuation.resume(returning: "onError")
//                }
//        }
//        #expect(result == "onError")
//    }
//    
////    func testPromise() -> Promise<Void> {
////        
////        let callback: ((_ resolve: @escaping @Sendable( @Sendable (()) -> Void), _ reject: @escaping @Sendable (  @Sendable (Error) -> Void)) -> Void)
////            = { (resolve: @escaping @Sendable( @Sendable (()) -> Void), reject: @escaping @Sendable ( @Sendable (Error) -> Void)) in
////            self.tryCount += 1
////            waitTime(0.1) {
////                reject(ARandomError())
////            }
////        }
////        
////        return Promise<Void>(callback: callback)
////    }
////    
////    func succeedsAfter3Times() -> Promise<Void> {
////        
////        let callback: ((_ resolve: @escaping ((()) -> Void), _ reject: @escaping ((Error) -> Void)) -> Void)
////            = { (resolve: @escaping ((()) -> Void), reject: @escaping ((Error) -> Void)) in
////                self.tryCount += 1
////                if self.tryCount == 3 {
////                    resolve(())
////                } else {
////                    reject(ARandomError())
////                }
////        }
////        
////        return Promise<Void>(callback: callback)
////    }
//}
//
//struct ARandomError: Error { }
