//
//  Promise.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 06/02/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

public class Promise<T> {

    internal var state: PromiseState<T>
    internal var blocks = PromiseBlocks<T>()
    private var initialPromiseStart:(() -> Void)?
    private var initialPromiseStarted = false
    private var promiseProgressCallBack: ((_ resolve: @escaping ((T) -> Void),
    _ reject: @escaping ((Error) -> Void),
    _ progress: @escaping ((Float) -> Void)) -> Void)?
    
    public init() {
        state = .dormant
    }
    
    public init(value: T) {
        state = .fulfilled(value: value)
    }
    
    public init(error: Error) {
        state = PromiseState.rejected(error: error)
    }

    public convenience init(callback: @escaping (
                            _ resolve: @escaping ((T) -> Void),
                            _ reject: @escaping ((Error) -> Void)) -> Void) {
        self.init()
        promiseProgressCallBack = { resolve, reject, progress in
            callback(self.fulfill, self.reject)
        }
    }
    
    public convenience init(callback: @escaping (
                            _ resolve: @escaping ((T) -> Void),
                            _ reject: @escaping ((Error) -> Void),
                            _ progress: @escaping ((Float) -> Void)) -> Void) {
        self.init()
        promiseProgressCallBack = { resolve, reject, progress in
            callback(self.fulfill, self.reject, self.setProgress)
        }
    }
    
    internal func resetState() {
        state = .dormant
    }
    
    public func start() {
        updateState(PromiseState<T>.pending(progress: 0))
        if let p = promiseProgressCallBack {
            p(fulfill, reject, setProgress)
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
        if !isStarted {
            start()
        }
    }
    
    internal func fulfill(_ value: T) {
        updateState(PromiseState<T>.fulfilled(value: value))
    }
    
    internal func reject(_ anError: Error) {
        updateState(PromiseState<T>.rejected(error:  anError))
    }
    
    func updateState(_ state: PromiseState<T>) {
        //  TODO here use sync lock queue to avoid race conditions?
        // Only change state if state is pending or dormant.
        switch self.state {
        case .dormant, .pending:
            self.state = state
        default:
            print("Trying to change a finished promise")
        }
        launchCallbacksIfNeeded()
    }
    
    func launchCallbacksIfNeeded() {
        switch self.state {
        case .dormant:
            break
        case .pending(let progress):
            for pb in blocks.progress {
                pb(progress)
            }
        case .fulfilled(let value):
            for sb in blocks.success {
                sb(value)
            }
            blocks.finally()
            initialPromiseStart = nil
        case .rejected(let anError):
            for fb in blocks.fail {
                fb(anError)
            }
            blocks.finally()
            initialPromiseStart = nil
        }
    }
}

// Helpers
extension Promise {
    
    var isStarted: Bool {
        switch state {
        case .dormant:
            return false
        default:
            return true
        }
    }
}
