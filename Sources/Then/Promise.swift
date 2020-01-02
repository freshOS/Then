//
//  Promise.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 06/02/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation
import Dispatch

private class Locker {
    let lockQueueSpecificKey: DispatchSpecificKey<Void>
    let lockQueue: DispatchQueue
    init() {
        lockQueueSpecificKey = DispatchSpecificKey<Void>()
        lockQueue = DispatchQueue(label: "com.freshOS.then.lockQueue", qos: .userInitiated)
        lockQueue.setSpecific(key: lockQueueSpecificKey, value: ())
    }
  
    var isOnLockQueue: Bool {
        return DispatchQueue.getSpecific(key: lockQueueSpecificKey) != nil
    }
}

public class Promise<T> {
    
    // MARK: - Protected properties
    
    internal var numberOfRetries: UInt = 0

    private var threadUnsafeState: PromiseState<T>
    
    private var threadUnsafeBlocks: PromiseBlocks<T> = PromiseBlocks<T>()

    private var initialPromiseStart:(() -> Void)?
    private var initialPromiseStarted = false
    
    internal typealias ProgressCallBack = (_ resolve: @escaping ((T) -> Void),
        _ reject: @escaping ((Error) -> Void),
        _ progress: @escaping ((Float) -> Void)) -> Void
    
    private var promiseProgressCallBack: ProgressCallBack?
    
    // MARK: - Lock
  
    private let locker = Locker()
    private var lockQueue: DispatchQueue {
        return locker.lockQueue
    }
    private func _synchronize<U>(_ action: () -> U) -> U {
        if locker.isOnLockQueue {
            return action()
        } else {
            return lockQueue.sync(execute: action)
        }
    }
    
    private func _asynchronize(_ action: @escaping () -> Void) {
        lockQueue.async(execute: action)
    }
    
    // MARK: - Intializers
    
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
            callback(resolve, reject)
        }
    }
    
    public convenience init(callback: @escaping (
                            _ resolve: @escaping ((T) -> Void),
                            _ reject: @escaping ((Error) -> Void),
                            _ progress: @escaping ((Float) -> Void)) -> Void) {
        self.init()
        promiseProgressCallBack = { resolve, reject, progress in
            callback(resolve, reject, progress)
        }
    }
    
    // MARK: - Private atomic operations
    
    private func _updateFirstPromiseStartFunctionAndState(from startBody: @escaping () -> Void, isStarted: Bool) {
        _synchronize {
            initialPromiseStart = startBody
            initialPromiseStarted = isStarted
        }
    }
    
    // MARK: - Public interfaces
    
    public func start() {
        _synchronize({ return _start() })?()
    }

    public func fulfill(_ value: T) {
        _synchronize({ () -> (() -> Void)? in 
            let action = _updateState(.fulfilled(value: value))
            threadUnsafeBlocks = .init()
            promiseProgressCallBack = nil
            return action
        })?()
    }
    
    public func reject(_ anError: Error) {
        _synchronize({ () -> (() -> Void)? in
            let action = _updateState(.rejected(error: anError))
            // Only release callbacks if no retries a registered.
            if numberOfRetries == 0 {
                threadUnsafeBlocks = .init()
                promiseProgressCallBack = nil
            }
            return action
        })?()
    }
    
    // MARK: - Internal interfaces
    
    internal func synchronize<U>(
        _ action: (_ currentState: PromiseState<T>, _ blocks: inout PromiseBlocks<T>) -> U) -> U {
        return _synchronize {
            return action(threadUnsafeState, &threadUnsafeBlocks)
        }
    }
    
    internal func resetState() {
        _synchronize {
            threadUnsafeState = .dormant
        }
    }
    
    internal func passAlongFirstPromiseStartFunctionAndStateTo<X>(_ promise: Promise<X>) {
        let (startBlock, isStarted) = _synchronize {
            return (self.initialPromiseStart ?? self.start, self.initialPromiseStarted)
        }
        promise._updateFirstPromiseStartFunctionAndState(from: startBlock, isStarted: isStarted)
    }
    
    internal func tryStartInitialPromiseAndStartIfneeded() {
        var actions: [(() -> Void)?] = []
        _synchronize {
            actions = [
                _startInitialPromiseIfNeeded(),
                _start()
            ]
        }
        actions.forEach { $0?() }
    }
    
    internal func updateState(_ newState: PromiseState<T>) {
        _synchronize({ return _updateState(newState) })?()
    }
    
    internal func setProgressCallBack(_ promiseProgressCallBack: @escaping ProgressCallBack) {
        _synchronize {
            self.promiseProgressCallBack = promiseProgressCallBack
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
        _synchronize {
            switch threadUnsafeState {
            case let .fulfilled(value):
                success(value)
            case let .rejected(error):
                failure(error)
            case .dormant, .pending:
                threadUnsafeBlocks.success.append(success)
                threadUnsafeBlocks.fail.append(failure)
                threadUnsafeBlocks.progress.append(progress)
            }
        }
    }
    
    // MARK: - Private non-atomic operations
    
    private func _startInitialPromiseIfNeeded() -> (() -> Void)? {
        guard !initialPromiseStarted else { return nil }
        initialPromiseStarted = true
        let body = self.initialPromiseStart
        return body
    }
    
    private func _start() -> (() -> Void)? {
        guard threadUnsafeState.isDormant else { return nil }
        
        let updateAction = _updateState(.pending(progress: 0))
        guard let p = promiseProgressCallBack else { return updateAction }
        return {
            updateAction?()
            p(self.fulfill, self.reject, self.setProgress)
        }
//            promiseProgressCallBack = nil //Remove callba
    }
    
    private func _updateState(_ newState: PromiseState<T>) -> (() -> Void)? {
        if threadUnsafeState.isPendingOrDormant {
            threadUnsafeState = newState
        }
        return launchCallbacksIfNeeded()
    }
    
    private func launchCallbacksIfNeeded() -> (() -> Void)? {
        switch threadUnsafeState {
        case .dormant:
            return nil
        case .pending(let progress):
            if progress != 0 {
                return threadUnsafeBlocks.updateProgress(progress)
            } else {
                return nil
            }
        case .fulfilled(let value):
            initialPromiseStart = nil
            return threadUnsafeBlocks.fulfill(value: value)
        case .rejected(let anError):
            initialPromiseStart = nil
            return threadUnsafeBlocks.reject(error: anError)
        }
    }
}

// MARK: - Helpers
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
