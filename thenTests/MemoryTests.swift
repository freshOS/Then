//
//  MemoryTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 09/08/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
@testable import then

class MemoryTests: XCTestCase {
    
    func testRaceConditionWriteState() {
        let p = Promise<String>()
        
        func loopState() {
            for i in 0...10000 {
                p.updateState(PromiseState<String>.fulfilled(value: "Test1-\(i)"))
                p.updateState(PromiseState<String>.fulfilled(value: "Test2-\(i)"))
                p.updateState(PromiseState<String>.fulfilled(value: "Test3-\(i)"))
            }
        }
        
        if #available(iOS 10.0, *) {
            let t1 = Thread { loopState() }
            let t2 = Thread { loopState() }
            let t3 = Thread { loopState() }
            let t4 = Thread { loopState() }
            t1.start()
            t2.start()
            t3.start()
            t4.start()
        } else {
            // Fallback on earlier versions
        }
        loopState()
    }
    
    func testRaceConditionReadState() {
        let p = Promise(value: "Hello")
        
        func loopState() {
            for i in 0...10000 {
                p.updateState(PromiseState<String>.fulfilled(value: "Test1-\(i)"))
                p.updateState(PromiseState<String>.fulfilled(value: "Test2-\(i)"))
                p.updateState(PromiseState<String>.fulfilled(value: "Test3-\(i)"))
                //Access Value
                let value = p.value
                print(value)
            }
        }
        
        if #available(iOS 10.0, *) {
            let t1 = Thread { loopState() }
            let t2 = Thread { loopState() }
            let t3 = Thread { loopState() }
            let t4 = Thread { loopState() }
            t1.start()
            t2.start()
            t3.start()
            t4.start()
        } else {
            // Fallback on earlier versions
        }
        loopState()
    }
}
