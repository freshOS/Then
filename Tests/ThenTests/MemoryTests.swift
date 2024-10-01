//
//  MemoryTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 09/08/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Testing
@testable import Then
import Foundation

@Suite
struct MemoryTests {
    
    @Test
    func raceConditionWriteState() {
        let p = Promise<String>()
        
        @Sendable func loopState() {
            for i in 0...10000 {
                p.updateState(PromiseState<String>.fulfilled(value: "Test1-\(i)"))
                p.updateState(PromiseState<String>.fulfilled(value: "Test2-\(i)"))
                p.updateState(PromiseState<String>.fulfilled(value: "Test3-\(i)"))
            }
        }
        
        let t1 = Thread { loopState() }
        let t2 = Thread { loopState() }
        let t3 = Thread { loopState() }
        let t4 = Thread { loopState() }
        t1.start()
        t2.start()
        t3.start()
        t4.start()

        loopState()
    }
    
    @Test
    func raceConditionReadState() {
        let p = Promise("Hello")
        
        @Sendable func loopState() {
            for i in 0...10000 {
                p.updateState(PromiseState<String>.fulfilled(value: "Test1-\(i)"))
                p.updateState(PromiseState<String>.fulfilled(value: "Test2-\(i)"))
                p.updateState(PromiseState<String>.fulfilled(value: "Test3-\(i)"))
                //Access Value
                let value = p.value
                print(value ?? "")
            }
        }
        
     
        let t1 = Thread { loopState() }
        let t2 = Thread { loopState() }
        let t3 = Thread { loopState() }
        let t4 = Thread { loopState() }
        t1.start()
        t2.start()
        t3.start()
        t4.start()

        loopState()
    }
    
    @Test
    func raceConditionResigterBlocks() {
        let p = Promise<String>()
        
        @Sendable func loop() {
            for _ in 0...1000 {
                p.registerThen { _ in }
                p.registerOnError { _ in }
                p.registerFinally { }
                p.progress { _ in }
            }
        }
        
        let t1 = Thread { loop() }
        let t2 = Thread { loop() }
        let t3 = Thread { loop() }
        let t4 = Thread { loop() }
        t1.start()
        t2.start()
        t3.start()
        t4.start()

        loop()
    }
    
    @Test
    func raceConditionWriteWriteBlocks() {
        let p = Promise<String>()
        @Sendable func loop() {
            for _ in 0...1000 {
                p.blocks.success.append({ _ in })
                p.blocks.fail.append({ _ in })
                p.blocks.progress.append({ _ in })
                p.blocks.finally.append({ })
            }
        }
    
        let t1 = Thread { loop() }
        let t2 = Thread { loop() }
        let t3 = Thread { loop() }
        let t4 = Thread { loop() }
        t1.start()
        t2.start()
        t3.start()
        t4.start()

        loop()
    }
    
    @Test
    func raceConditionWriteReadBlocks() {
        let p = Promise<String>()
        p.blocks.success.append({ _ in })
        p.blocks.fail.append({ _ in })
        p.blocks.progress.append({ _ in })
        p.blocks.success.append({ _ in })
        p.blocks.fail.append({ _ in })
        p.blocks.progress.append({ _ in })
        p.blocks.finally.append({ })
        
        @Sendable
        func loop() {
            for _ in 0...10000 {
                
                for sb in p.blocks.success {
                    sb("YO")
                }
                
                for fb in p.blocks.fail {
                    fb(PromiseError.default)
                }
                
                for p in p.blocks.progress {
                    p(0.5)
                }
                
                for fb in p.blocks.finally {
                    fb()
                }
            }
        }
    
        let t1 = Thread { loop() }
        let t2 = Thread { loop() }
        let t3 = Thread { loop() }
        let t4 = Thread { loop() }
        t1.start()
        t2.start()
        t3.start()
        t4.start()

        loop()
    }
}
