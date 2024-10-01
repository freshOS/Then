//
//  ZipTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 10/08/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
struct ZipTests {
    
    // 2 promises
        
    @Test
    func zipSynchronousPromises() async {
        let result = await withCheckedContinuation { continuation in
            Promises.zip(Promise(1), Promise("Hello")).then { int, string in
                continuation.resume(returning: (int, string))
            }
        }
        #expect(result == (1, "Hello"))
    }
    
    @Test
    func zipAsynchronousPromises() async {
        let result = await withCheckedContinuation { continuation in
            let p1 = Promise { resolve, _ in
                waitTime(0.1) { resolve("Cool") }
            }
            let p2 = Promise { resolve, _ in
                waitTime(0.2) { resolve(23) }
            }
            Promises.zip(p1, p2).then { string, int in
                continuation.resume(returning: (string, int))
            }
        }
        #expect(result == ("Cool", 23))
    }
    
    @Test
    func zipSynchronousPromisesFails() async {
        let result = await withCheckedContinuation { continuation in
            Promises.zip(Promise<Int>.reject(), Promise("Hello")).then { _, _ in
                continuation.resume(returning: "then")
            }.onError { _ in
                continuation.resume(returning: "onError")
            }
        }
        #expect(result == "onError")
    }
    
    @Test
    func zipAsynchronousPromisesFails() async {
        let result = await withCheckedContinuation { continuation in
            let p1 = Promise { resolve, _ in
                waitTime(0.1) { resolve("Cool") }
            }
            let p2 = Promise<Int> { _, reject in
                waitTime(0.2) { reject(PromiseError.default) }
            }
            Promises.zip(p1, p2).then { _, _ in
                continuation.resume(returning: "then")
            }.onError { _ in
                continuation.resume(returning: "onError")
            }
        }
        #expect(result == "onError")
    }
    
    // 3 promises
    
    @Test
    func testZip3SynchronousPromises() async {
        let result = await withCheckedContinuation { continuation  in
            Promises.zip(Promise(1), Promise("Hello"), Promise(0.45)).then { res in
                continuation.resume(returning: res)
            }
        }
        #expect(result == (1, "Hello", 0.45))
    }
    
    @Test
    func testZip3AsynchronousPromises() async {
        let result = await withCheckedContinuation { continuation in
            let p1 = Promise { resolve, _ in
                waitTime(0.1) { resolve("Cool") }
            }
            let p2 = Promise { resolve, _ in
                waitTime(0.2) { resolve(23) }
            }
            let p3 = Promise { resolve, _ in
                waitTime(0.1) { resolve(0.45) }
            }
            Promises.zip(p1, p2, p3).then { res in
                continuation.resume(returning: res)
            }
        }
        #expect(result == ("Cool", 23, 0.45))
    }
    
    @Test
    func testZip3SynchronousPromisesFails() async {
        let result = await withCheckedContinuation { continuation in
            Promises.zip(Promise<Int>.reject(), Promise("Hello"), Promise<Double>.reject()).then { _, _, _ in
                continuation.resume(returning: "then")
            }.onError { _ in
                continuation.resume(returning: "onError")
            }
        }
        #expect(result == "onError")
    }
    
    @Test
    func testZip3AsynchronousPromisesFails() async {
        let result = await withCheckedContinuation { continuation in
            let p1 = Promise { resolve, _ in
                waitTime(0.2) { resolve("Cool") }
            }
            let p2 = Promise<Int> { _, reject in
                waitTime(0.1) { reject(PromiseError.default) }
            }
            let p3 = Promise { resolve, _ in
                waitTime(0.1) { resolve(0.45) }
            }
            Promises.zip(p1, p2, p3).then { _, _, _ in
                continuation.resume(returning: "then")
            }.onError { _ in
                continuation.resume(returning: "onError")
            }
        }
        #expect(result == "onError")
    }
}
