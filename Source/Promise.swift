//
//  Promise.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 06/02/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

public class Promise<T> {
    
    internal var numberOfRetries: UInt = 0

    private let lockQueue = DispatchQueue(label: "com.freshOS.then.lockQueue", qos: .userInitiated)
    
    private var threadUnsafeState: PromiseState<T>
    internal var state: PromiseState<T> {
        get {
            return lockQueue.sync { return threadUnsafeState }
        }
        set {
            lockQueue.sync { threadUnsafeState = newValue }
        }
    }
    
    private var threadUnsafeBlocks: PromiseBlocks<T> = PromiseBlocks<T>()
    internal var blocks: PromiseBlocks<T> {
        get {
            return lockQueue.sync { return threadUnsafeBlocks }
        }
        set {
            lockQueue.sync { threadUnsafeBlocks = newValue }
        }
    }

    private var initialPromiseStart:(() -> Void)?
    private var initialPromiseStarted = false
    private var promiseProgressCallBack: ((_ resolve: @escaping ((T) -> Void),
    _ reject: @escaping ((Error) -> Void),
    _ progress: @escaping ((Float) -> Void)) -> Void)?
    
    public init() {
        threadUnsafeState = .dormant
    }
    
    public init(_ value: T) {
        threadUnsafeState = .fulfilled(value: value)
    }
    
    public init(error: Error) {
        threadUnsafeState = PromiseState.rejected(error: error)
    }

    public convenience init(callback: @escaping (
                            _ resolve: @escaping ((T) -> Void),
                            _ reject: @escaping ((Error) -> Void)) -> Void) {
        self.init()
        promiseProgressCallBack = { resolve, reject, progress in
            callback({ [weak self] t in
                self?.fulfill(t)
            }, { [weak self ] e in
                self?.reject(e)
            })
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
        if state.isDormant {
            updateState(PromiseState<T>.pending(progress: 0))
            if let p = promiseProgressCallBack {
                p(fulfill, reject, setProgress)
            }
//            promiseProgressCallBack = nil //Remove callba
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
        blocks = PromiseBlocks<T>()
        promiseProgressCallBack = nil
    }
    
    internal func reject(_ anError: Error) {
        updateState(PromiseState<T>.rejected(error:  anError))
        // Only release callbacks if no retries a registered.
        if numberOfRetries == 0 {
            blocks = PromiseBlocks<T>()
            promiseProgressCallBack = nil
        }
    }
    
    internal func updateState(_ newState: PromiseState<T>) {
        if state.isPendingOrDormant {
            state = newState
        }
        launchCallbacksIfNeeded()
    }
    
    private func launchCallbacksIfNeeded() {
        switch state {
        case .dormant:
            break
        case .pending(let progress):
            if progress != 0 {
                for pb in blocks.progress {
                    pb(progress)
                }
            }
        case .fulfilled(let value):
            for sb in blocks.success {
                sb(value)
            }
            for fb in blocks.finally {
                fb()
            }
            initialPromiseStart = nil
        case .rejected(let anError):
            for fb in blocks.fail {
                fb(anError)
            }
            for fb in blocks.finally {
                fb()
            }
            initialPromiseStart = nil
        }
    }
    
    internal func newLinkedPromise() -> Promise<T> {
        let p = Promise<T>()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    internal func syncStateWithCallBacks(success: @escaping ((T) -> Void),
                                         failure: @escaping ((Error) -> Void),
                                         progress: @escaping ((Float) -> Void)) {
        switch state {
        case let .fulfilled(value):
            success(value)
        case let .rejected(error):
            failure(error)
        case .dormant, .pending:
            blocks.success.append(success)
            blocks.fail.append(failure)
            blocks.progress.append(progress)
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
extension Promise where T == Void {
    
    public convenience init(callback: @escaping (
        _ resolve: @escaping (() -> Void),
        _ reject: @escaping ((Error) -> Void)) -> Void) {
        self.init()
        promiseProgressCallBack = { resolve, reject, progress in
            callback({ [weak self] in
                self?.fulfill(())
            }, { [weak self ] e in
                    self?.reject(e)
            })
        }
    }
    
    public convenience init(callback2: @escaping (
        _ resolve: @escaping (() -> Void),
        _ reject: @escaping ((Error) -> Void),
        _ progress: @escaping ((Float) -> Void)) -> Void) {
        self.init()
        promiseProgressCallBack = { resolve, reject, progress in
            callback2(self.fulfill, self.reject, self.setProgress)
        }
    }
}
