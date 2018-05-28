//
//  Promise.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 06/02/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation
import Dispatch

public class Promise<T> {
    
    internal var numberOfRetries: UInt = 0

    private let lockQueue = DispatchQueue(label: "com.freshOS.then.lockQueue", qos: .userInitiated)
    
    private var threadUnsafeState: PromiseState<T>
    
    private var threadUnsafeBlocks: PromiseBlocks<T> = PromiseBlocks<T>()

    private var initialPromiseStart:(() -> Void)?
    private var initialPromiseStarted = false
    
    internal typealias ProgressCallBack = (_ resolve: @escaping ((T) -> Void),
        _ reject: @escaping ((Error) -> Void),
        _ progress: @escaping ((Float) -> Void)) -> Void
    
    private var promiseProgressCallBack: ProgressCallBack?
    
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
        synchronize { (_, _) in
            _updateState(.dormant)
        }
    }
    
    public func start() {
        synchronize { (state, _) in
            if state.isDormant {
                _updateState(.pending(progress: 0))
                if let p = promiseProgressCallBack {
                    p(fulfill, reject, setProgress)
                }
                //            promiseProgressCallBack = nil //Remove callba
            }
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
    
    public func fulfill(_ value: T) {
        synchronize { (_, blocks) in
            _updateState(.fulfilled(value: value))
            blocks = .init()
            promiseProgressCallBack = nil
        }
    }
    
    public func reject(_ anError: Error) {
        synchronize { (_, blocks) in
            _updateState(.rejected(error: anError))
            // Only release callbacks if no retries a registered.
            if numberOfRetries == 0 {
                blocks = .init()
                promiseProgressCallBack = nil
            }
        }
    }
    
    private func _updateState(_ newState: PromiseState<T>) {
        if threadUnsafeState.isPendingOrDormant {
            threadUnsafeState = newState
        }
        launchCallbacksIfNeeded()
    }
    
    internal func synchronize<U>(
        _ action: (_ currentState: PromiseState<T>, _ blocks: inout PromiseBlocks<T>) -> U) -> U {
        return lockQueue.sync {
            return action(threadUnsafeState, &threadUnsafeBlocks)
        }
    }
    
    internal func updateState(_ newState: PromiseState<T>) {
        synchronize { _, _ in
            _updateState(newState)
        }
    }
    
    internal func setProgressCallBack(_ promiseProcessCallBack: ProgressCallBack) {
        lockQueue.sync {
            self.promiseProgressCallBack = promiseProgressCallBack
        }
    }
    
    private func launchCallbacksIfNeeded() {
        switch threadUnsafeState {
        case .dormant:
            break
        case .pending(let progress):
            if progress != 0 {
                for pb in threadUnsafeBlocks.progress {
                    pb(progress)
                }
            }
        case .fulfilled(let value):
            for sb in threadUnsafeBlocks.success {
                sb(value)
            }
            for fb in threadUnsafeBlocks.finally {
                fb()
            }
            initialPromiseStart = nil
        case .rejected(let anError):
            for fb in threadUnsafeBlocks.fail {
                fb(anError)
            }
            for fb in threadUnsafeBlocks.finally {
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
        synchronize { (state, blocks) in
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
}

// Helpers
extension Promise {
    
    var isStarted: Bool {
        return synchronize { state, _ in
            switch state {
            case .dormant:
                return false
            default:
                return true
            }
        }
    }
}
