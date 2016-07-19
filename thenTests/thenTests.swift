//
//  thenTests.swift
//  thenTests
//
//  Created by Sacha Durand Saint Omer on 06/02/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import XCTest
@testable import then

class thenTests: XCTestCase {
    
    override func setUp() { super.setUp() }
    override func tearDown() { super.tearDown() }
    
    func testThen() {
        let thenExpectation = expectationWithDescription("then called")
        let finallyExpectation = expectationWithDescription("Finally called")
        fetchUserId()
        .then(fetchUserNameFromId)
        .then(fetchUserFollowStatusFromName)
        .then { isFollowed in
            XCTAssertFalse(isFollowed)
            thenExpectation.fulfill()
        }.onError { e in
            XCTFail("on Error shouldn't be called")
        }.finally {
            finallyExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testError() {
        let errorExpectation = expectationWithDescription("onError called")
        let finallyExpectation = expectationWithDescription("Finally called")
        fetchUserId()
            .then(fetchUserNameFromId)
            .then(failingFetchUserFollowStatusFromName)
            .then { isFollowed in
                XCTFail("then block shouldn't be called")
            }.onError { e in
                XCTAssertTrue((e as! MyError) == MyError.DefaultError)
                errorExpectation.fulfill()
            }.finally {
                finallyExpectation.fulfill()
            }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testChainedPromises() {
        let thenExpectation = expectationWithDescription("then called")
        fetchUserId()
        .then(fetchUserNameFromId(1))
        .then(fetchUserNameFromId(2))
        .then(fetchUserNameFromId(3))
        .then(fetchUserNameFromId(4)).then { name in
            print("name :\(name)")
            thenExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testChainedPromisesAreExecutedInOrder() {
        var count = 0
        
        let block1 = expectationWithDescription("block 1 called")
        let block2 = expectationWithDescription("block 2 called")
        let block3 = expectationWithDescription("block 3 called")
        
        let thenExpectation = expectationWithDescription("then called")
        fetchUserId()
        .then(fetchUserNameFromId(1)).then({ _ in
            XCTAssertTrue(count == 0)
            count+=1
            block1.fulfill()
        })
        .then(fetchUserNameFromId(2)).then {_ in
            XCTAssertTrue(count == 1)
            count+=1
            block2.fulfill()
        }
        .then(fetchUserNameFromId(3)).then {_ in
            XCTAssertTrue(count == 2)
            count+=1
            block3.fulfill()
        }
        .then(fetchUserNameFromId(4)).then { name in
            XCTAssertTrue(count == 3)
            count+=1
            print("name :\(name)")
            thenExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testSynchronousChainsWorksProprely() {
        globalCount = 0
        blockPromiseCExpectation = expectationWithDescription("block C called")
        promiseA()
            .then(promiseB())
            .then(promiseC())
        waitForExpectationsWithTimeout(1, handler: nil)

        
    }
    
    func testOnErrorCalledWhenSynchronousRejects() {
        let errorblock = expectationWithDescription("error block called")
        promiseA()
            .then(syncRejectionPromise())
            .then(syncRejectionPromise())
            .onError { (error) -> Void in
            errorblock.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testFinallyCalledWhenSynchronous() {
        let finallyblock = expectationWithDescription("error block called")
        syncRejectionPromise().finally {
            finallyblock.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testWhenAll() {
        let block = expectationWithDescription("Block called")
        whenAll(promise1(),promise2(),promise3()).then { array in
            XCTAssertEqual(array, [1,2,3])
            block.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testWhenAllArray() {
        let block = expectationWithDescription("Block called")
        whenAll(promiseArray1(),promiseArray2(),promiseArray3()).then { array in
            XCTAssertEqual(array, [1,2,3,4,5,6,7,8,9])
            block.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testClassicThenLaunchesPromise() {
        let thenExpectation = expectationWithDescription("then called")
        fetchUserId().then { id in
            XCTAssertEqual(id, 1234)
            thenExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testRegisterThenChainedPromisesAreNeverCalledWithoutAThenBlock() {
        let timerExpectation = expectationWithDescription("timerExpectation")
        fetchUserId()
            .registerThen { _ in
                XCTFail()
            }.registerThen {_ in
                XCTFail()
            }.registerThen {_ in
                XCTFail()
            }
        wait(1) {
            timerExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testRegisterThenPromiseChainedPromisesAreNeverCalledWithoutAThenBlock() {
        let timerExpectation = expectationWithDescription("timerExpectation")
        fetchUserId()
            .registerThen(fetchUserNameFromId(10)).registerThen { name in
                print(name)
                XCTFail()
            }.registerThen {_ in
                XCTFail()
            }.registerThen {_ in
                XCTFail()
        }
        wait(1) {
            timerExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenPromise2ChainedPromisesAreNeverCalledWithoutAThenBlock() {
        let timerExpectation = expectationWithDescription("timerExpectation")
        fetchUserId().registerThen { id in
            return fetchUserNameFromId(id)
        }.registerThen { name in
            print(name)
            XCTFail()
        }.registerThen { _ in
            XCTFail()
        }
        wait(1) {
            timerExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenChainedPromisesAreExecutedInOrder() {
        var count = 0
        
        let block1 = expectationWithDescription("block 1 called")
        let block2 = expectationWithDescription("block 2 called")
        let block3 = expectationWithDescription("block 3 called")
        
        let thenExpectation = expectationWithDescription("thenExpectation")
        fetchUserId()
            .registerThen { _ in
                XCTAssertTrue(count == 0)
                count+=1
                block1.fulfill()
            }.registerThen {_ in
                XCTAssertTrue(count == 1)
                count+=1
                block2.fulfill()
            }.registerThen {_ in
                XCTAssertTrue(count == 2)
                count+=1
                block3.fulfill()
            }.then { name in
                XCTAssertTrue(count == 3)
                count+=1
                print("name :\(name)")
                thenExpectation.fulfill()
            }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenPromiseFuncPointerNotCalled() {
        let timerExpectation = expectationWithDescription("thenExpectation")
        fetchUserId()
            .registerThen(fetchUserNameFromId)
            .registerThen { _ in
                XCTFail()
        }
        wait(1) {
            timerExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenPromise2FuncPointerNotCalled() {
        let timerExpectation = expectationWithDescription("thenExpectation")
        fetchUserId().registerThen { id -> Promise<String> in
            return fetchUserNameFromId(id)
        }.registerThen { _ in
                XCTFail()
        }
        wait(1) {
            timerExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenPromiseFuncPointerCalledWithThenBlock() {
        let timerExpectation = expectationWithDescription("thenExpectation")
        fetchUserId()
            .registerThen(fetchUserNameFromId)
            .then { name in
                timerExpectation.fulfill()
            }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenPromise2FuncPointerCalledWithThenBlock() {
        let timerExpectation = expectationWithDescription("thenExpectation")
        fetchUserId().registerThen { id -> Promise<String> in
            return fetchUserNameFromId(id)
        }.then { name in
            timerExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenPromiseFuncPointerCalledWithMultipleRegisterThenBlocks() {
        let timerExpectation = expectationWithDescription("thenExpectation")
        fetchUserId()
            .registerThen(fetchUserNameFromId)
            .registerThen(fetchUserFollowStatusFromName)
            .then { name in
                timerExpectation.fulfill()
            }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRegisterThenMultipleThenOnlyCallOriginalPromiseOnce() {
        var count = 0
        
        let block1 = expectationWithDescription("block 1 called")
        let block2 = expectationWithDescription("block 2 called")
        let block3 = expectationWithDescription("block 3 called")
        
        let thenExpectation = expectationWithDescription("thenExpectation")
        fetchUserId()
            .registerThen { _ in
                XCTAssertTrue(count == 0)
                count+=1
                block1.fulfill()
            }.registerThen {_ in
                XCTAssertTrue(count == 1)
                count+=1
                block2.fulfill()
            }.registerThen {_ in
                XCTAssertTrue(count == 2)
                count+=1
                block3.fulfill()
            }.then { name in
                XCTAssertTrue(count == 3)
                count+=1
                print("name :\(name)")
                thenExpectation.fulfill()
            }.then { _ -> Void in
                print("Just another then block")
            }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testProgress() {
        
        let progressExpectation = expectationWithDescription("thenExpectation")
        let thenExpectation = expectationWithDescription("thenExpectation")
    
        upload().registerThen {
            print("Done")
        }.then {
            print("Done")
            thenExpectation.fulfill()
        }.progress { p in
            print("PROGRESS \(p)")
            XCTAssertEqual(p, 0.8)
            progressExpectation.fulfill()
        }

        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
    
    func testMultipleThenBlockCanBeRegisteredOnSamePromise() {
        let then1 = expectationWithDescription("then called")
        let then2 = expectationWithDescription("then called")
        let then3 = expectationWithDescription("then called")
        let then4 = expectationWithDescription("then called")
        let p = fetchUserId()
        p.then { _ in
            then1.fulfill()
        }
        p.then { _ in
            then2.fulfill()
        }
        p.then { _ in
            then3.fulfill()
        }
        p.then { _ in
            then4.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testMultipleErrorBlockCanBeRegisteredOnSamePromise() {
        let error1 = expectationWithDescription("error called")
        let error2 = expectationWithDescription("error called")
        let error3 = expectationWithDescription("error called")
        let error4 = expectationWithDescription("error called")
        let p = failingFetchUserFollowStatusFromName("")
        p.onError { _ in
            error1.fulfill()
        }
        p.onError { _ in
            error2.fulfill()
        }
        p.onError { _ in
            error3.fulfill()
        }
        p.onError { _ in
            error4.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testMultipleFinallyBlockCanBeRegisteredOnSamePromise() {
        let finally1 = expectationWithDescription("finally called")
        let finally2 = expectationWithDescription("finally called")
        let finally3 = expectationWithDescription("finally called")
        let finally4 = expectationWithDescription("finally called")
        let p = failingFetchUserFollowStatusFromName("")
        p.finally {
            finally1.fulfill()
        }
        p.finally {
            finally2.fulfill()
        }
        p.finally {
            finally3.fulfill()
        }
        p.finally {
            finally4.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testTwoConsecutivErrorBlocks2ndShouldNeverBeCalledOnFail() {
        let errorExpectation = expectationWithDescription("then called")
        failingFetchUserFollowStatusFromName("")
            .then { id in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                errorExpectation.fulfill()
            }.onError { e in
                XCTFail("Second on Error shouldn't be called")
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    
    func testThenWorksAfterErrorBlock() {
        let thenExpectation = expectationWithDescription("then called")
        fetchUserId()
            .then { id in
                thenExpectation.fulfill()
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.then {
                print("Ok bro")
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    
    func testTwoConsecutivErrorBlocks2ndShouldNeverBeCalledOnSuccess() {
        let thenExpectation = expectationWithDescription("then called")
        fetchUserId()
            .then { id in
                thenExpectation.fulfill()
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testCanContinueWithThenAfterErrorBlock() {
        let thenExpectation = expectationWithDescription("then called")
        let errorExpectation = expectationWithDescription("Finally called")
        failingFetchUserFollowStatusFromName("").then { _ in
            XCTFail()
            }.onError { e in
                errorExpectation.fulfill()
            }.then {
                thenExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
}

var globalCount = 0
var blockPromiseCExpectation:XCTestExpectation!


func upload() -> Promise<Void> {
    return Promise<Void> { resolve, reject, progress in
        wait {
            progress(0.8)
            wait {
                resolve()
            }
        }
    }
}

func promiseA() -> Promise<Int> {
    return Promise { resolve, reject in
        XCTAssertTrue(globalCount == 0)
        globalCount+=1
        resolve(globalCount)
    }
}

func promiseB() -> Promise<Int> {
    return Promise { resolve, reject in
        XCTAssertTrue(globalCount == 1)
        globalCount+=1
        resolve(globalCount)
    }
}

func promiseC() -> Promise<Int> {
    return Promise { resolve, reject in
        XCTAssertTrue(globalCount == 2)
        globalCount+=1
        resolve(globalCount)
        blockPromiseCExpectation.fulfill()
        
    }
}

func promise1() -> Promise<Int> {
    return Promise { resolve, _ in
        resolve(1)
    }
}

func promise2() -> Promise<Int> {
    return Promise { resolve, _ in
        resolve(2)
    }
}

func promise3() -> Promise<Int> {
    return Promise { resolve, _ in
        resolve(3)
    }
}

func promiseArray1() -> Promise<[Int]> {
    return Promise { resolve, _ in
        resolve([1,2,3])
    }
}

func promiseArray2() -> Promise<[Int]> {
    return Promise { resolve, _ in
        resolve([4,5,6])
    }
}

func promiseArray3() -> Promise<[Int]> {
    return Promise { resolve, _ in
        resolve([7,8,9])
    }
}


func syncRejectionPromise() -> Promise<Int> {
    return Promise { resolve, reject in
        reject(MyError.DefaultError)
    }
}

func fetchUserId() -> Promise<Int> {
    return Promise { resolve, reject in
        print("fetching user Id ...")
        wait { resolve(1234) }
    }
}

func fetchUserNameFromId(id:Int) -> Promise<String> {
    return Promise { resolve, reject in
        print("fetching UserName FromId : \(id) ...")
        wait { resolve("John Smith") }
    }
}

func fetchUserFollowStatusFromName(name:String) -> Promise<Bool> {
    return Promise { resolve, reject in
        print("fetchUserFollowStatusFromName: \(name) ...")
        wait { resolve(false) }
    }
}

func failingFetchUserFollowStatusFromName(name:String) -> Promise<Bool> {
    return Promise { resolve, reject in
        print("fetchUserFollowStatusFromName: \(name) ...")
        wait { reject(MyError.DefaultError) }
    }
}

func wait(callback:()->()) {
    let delay = 0.1 * Double(NSEC_PER_SEC)
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
    dispatch_after(time, dispatch_get_main_queue()) {
        callback()
    }
}

func wait(time:Double, callback:()->()) {
    let delay = time * Double(NSEC_PER_SEC)
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
    dispatch_after(time, dispatch_get_main_queue()) {
        callback()
    }
}

enum MyError:ErrorType {
    case DefaultError
}
