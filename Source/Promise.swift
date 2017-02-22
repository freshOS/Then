//
//  Promise.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 06/02/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

public class Promise<T>: AsyncType {
    public typealias AType = T

    fileprivate var promiseProgressCallBack: ((_ resolve: @escaping ((T) -> Void),
    _ reject: @escaping ((Error) -> Void),
    _ progress: @escaping ((Float) -> Void)) -> Void)?
    public var state: PromiseState<T> = .pending
    public var progress: Float = 0
    internal var blocks = PromiseBlocks<T>()
    fileprivate var initialPromiseStart:(() -> Void)?
    fileprivate var initialPromiseStarted = false
    fileprivate var promiseStarted = false
    
    internal convenience init() {
        self.init { _, _, _ in }
    }

    public convenience init(callback: @escaping (_ resolve: @escaping ((T) -> Void),
                            _ reject: @escaping ((Error) -> Void)) -> Void) {
        self.init { rs, rj, _ in
            callback(rs, rj)
        }
    }
    
    public required init(callback: @escaping (
                         _ resolve: @escaping ((T) -> Void),
                         _ reject: @escaping ((Error) -> Void),
                         _ progress: @escaping ((Float) -> Void)) -> Void) {
        promiseProgressCallBack = callback
    }
    
    internal func resetState() {
        state = .pending
        progress = 0
        promiseStarted = false
    }
    
    public func start() {
        promiseStarted = true
        if let p = promiseProgressCallBack {
            p(resolvePromise, rejectPromise, progressPromise)
        }
    }
    
    internal func passAlongFirstPromiseStartFunctionAndStateTo<X>(_ promise: Promise<X>) {
        // Pass along First promise start block
        if let startBlock = self.initialPromiseStart {
            promise.initialPromiseStart = startBlock
        } else {
            promise.initialPromiseStart = self.start
        }
        // Pass along initil promise start state.
        promise.initialPromiseStarted = self.initialPromiseStarted
    }

    internal func tryStartInitialPromiseAndStartIfneeded() {
        if !initialPromiseStarted {
            initialPromiseStart?()
            initialPromiseStarted = true
        }
        if !promiseStarted {
            start()
        }
    }
    
    internal func resolvePromise(_ result: T) {
        state = .fulfilled(value:result)
        for sb in blocks.success {
            sb(result)
        }
        blocks.finally()
        initialPromiseStart = nil
    }
    
    internal func rejectPromise(_ anError: Error) {
        state = .rejected(error:anError)
        for fb in blocks.fail {
            fb(anError)
        }
        blocks.finally()
        initialPromiseStart = nil
    }
}
