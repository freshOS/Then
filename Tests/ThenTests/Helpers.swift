//
//  Helpers.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Testing
import Foundation
@testable import Then

var globalCount = 0

func promiseA() -> Promise<Int> {
    return Promise { resolve, _ in
        #expect(globalCount == 0)
        globalCount+=1
        resolve(globalCount)
    }
}

func promiseB() -> Promise<Int> {
    return Promise { resolve, _ in
        #expect(globalCount == 1)
        globalCount+=1
        resolve(globalCount)
    }
}

func promiseC(completion: @escaping () -> Void) -> Promise<Int> {
    return Promise { resolve, _ in
        #expect(globalCount == 2)
        globalCount+=1
        resolve(globalCount)
        completion()
//        blockPromiseCExpectation.fulfill()
        
    }
}

func promise1() -> Promise<Int> {
    return Promise.resolve(1)
}

func promise2() -> Promise<Int> {
    return Promise.resolve(2)
}

func promise3() -> Promise<Int> {
    return Promise.resolve(3)
}

func promiseArray1() -> Promise<[Int]> {
    return Promise.resolve([1, 2, 3])
}

func promiseArray2() -> Promise<[Int]> {
    return Promise.resolve([4, 5, 6])
}

func promiseArray3() -> Promise<[Int]> {
    return Promise.resolve([7, 8, 9])
}

func syncRejectionPromise() -> Promise<Int> {
    return Promise.reject(MyError.defaultError)
}

func fetchUserId() -> Promise<Int> {
    return Promise { resolve, _ in
        print("fetching user Id ...")
        waitTime {
            resolve(1234)
            print("GOT USER ID 1234")
        }
    }
}

func fetchUserNameFromId(_ identifier: Int) -> Promise<String> {
    return Promise { resolve, _ in
        print("fetching UserName FromId : \(identifier) ...")
        waitTime { resolve("John Smith") }
    }
}

func fetchUserFollowStatusFromName(_ name: String) -> Promise<Bool> {
    return Promise { resolve, _ in
        print("fetchUserFollowStatusFromName: \(name) ...")
        waitTime { resolve(false) }
    }
}

func failingFetchUserFollowStatusFromName(_ name: String) -> Promise<Bool> {
    return Promise { _, reject in
        print("fetchUserFollowStatusFromName: \(name) ...")
        waitTime { reject(MyError.defaultError) }
    }
}

func waitTime(_ callback:@escaping () -> Void) {
    let delay = 0.01 * Double(NSEC_PER_SEC)
    let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).asyncAfter(deadline: time) {
        callback()
    }
}

func waitTime(_ time: Double, callback: @escaping () -> Void) {
    let delay = time * Double(NSEC_PER_SEC)
    let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time) {
        callback()
    }
}

func upload() -> Promise<Void> {
    return Promise { (resolve: @escaping (() -> Void), _: @escaping ((Error) -> Void), progress) in
        waitTime {
            progress(0.8)
            waitTime {
                resolve()
            }
        }
    }
}

func failingUpload() -> Promise<Void> {
    return Promise { (_: @escaping (() -> Void), reject: @escaping ((Error) -> Void), progress) in
        waitTime {
            progress(0.8)
            waitTime {
                reject(NSError(domain: "", code: 1223, userInfo: nil))
            }
        }
    }
}

enum MyError: Error {
    case defaultError
}

extension Promise {
    var blocks: PromiseBlocks<T> {
        get {
            return synchronize { _, blocks in
                let temp = blocks
                return temp
            }
        }
        set {
            synchronize { _, blocks in
                blocks = newValue
            }
        }
    }
}
