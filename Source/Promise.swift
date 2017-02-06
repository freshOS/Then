//
//  Promise.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 06/02/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

public typealias EmptyPromise = Promise<Void>

public class Promise<T> {
    
    public typealias ResolveCallBack = (T) -> Void
    public typealias ProgressCallBack = (Float) -> Void
    public typealias RejectCallBack = (Error) -> Void
    public typealias PromiseProgressCallBack =
        (_ resolve: @escaping ResolveCallBack,
        _ reject: @escaping RejectCallBack,
        _ progress: @escaping ProgressCallBack) -> Void

    fileprivate var promiseProgressCallBack: PromiseProgressCallBack?
    fileprivate var state: PromiseState<T> = .pending
    fileprivate var blocks = PromiseBlocks<T>()
    fileprivate var initialPromiseStart:(() -> Void)?
    fileprivate var initialPromiseStarted = false
    fileprivate var promiseStarted = false
    fileprivate var progress: Float = 0
    
    internal convenience init() {
        self.init { _, _, _ in }
    }
    
    public convenience init(callback: @escaping (_ resolve: @escaping ResolveCallBack,
        _ reject: @escaping RejectCallBack) -> Void) {
        self.init { rs, rj, _ in
            callback(rs, rj)
        }
    }
    
    public init(callback: @escaping (_ resolve: @escaping ResolveCallBack,
        _ reject: @escaping RejectCallBack, _ progress: @escaping ProgressCallBack) -> Void) {
        promiseProgressCallBack = callback
    }
    
    public func start() {
        promiseStarted = true
        if let p = promiseProgressCallBack {
            p(resolvePromise, rejectPromise, progressPromise)
        }
    }
    
    fileprivate func passAlongFirstPromiseStartFunctionAndStateTo<X>(_ promise: Promise<X>) {
        // Pass along First promise start block
        if let startBlock = self.initialPromiseStart {
            promise.initialPromiseStart = startBlock
        } else {
            promise.initialPromiseStart = self.start
        }
        // Pass along initil promise start state.
        promise.initialPromiseStarted = self.initialPromiseStarted
    }

    fileprivate func tryStartInitialPromiseAndStartIfneeded() {
        if !initialPromiseStarted {
            initialPromiseStart?()
            initialPromiseStarted = true
        }
        if !promiseStarted {
            start()
        }
    }
    
    fileprivate func registerNextPromise<X>(_ block: (T) -> Promise<X>,
                                     result: T,
                                     resolve: @escaping (X) -> Void,
                                     reject: @escaping RejectCallBack) {
        let nextPromise: Promise<X> = block(result)
        nextPromise.then { x in
            resolve(x)
        }.onError(reject)
    }
}

// MARK: - Then

public extension Promise {
    
    @discardableResult public func then<X>(_ block: @escaping (T) -> X) -> Promise<X> {
        tryStartInitialPromiseAndStartIfneeded()
        return registerThen(block)
    }
    
    @discardableResult public func registerThen<X>(_ block: @escaping (T) -> X) -> Promise<X> {
        let p = Promise<X>()
        switch state {
        case let .fulfilled(value):
            let x: X = block(value)
            p.resolvePromise(x)
        case let .rejected(error):
            p.rejectPromise(error)
        case .pending:
            blocks.success.append({ t in
                p.resolvePromise(block(t))
            })
            blocks.fail.append(p.rejectPromise)
            blocks.progress.append(p.progressPromise)
        }
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    @discardableResult public func then<X>(_ block: @escaping (T) -> Promise<X>) -> Promise<X> {
        tryStartInitialPromiseAndStartIfneeded()
        return registerThen(block)
    }
    
    @discardableResult  public func registerThen<X>(_ block: @escaping (T) -> Promise<X>)
        -> Promise<X> {
            let p = Promise<X>()
            switch state {
            case let .fulfilled(value):
                registerNextPromise(block, result: value,
                                    resolve: p.resolvePromise, reject: p.rejectPromise)
            case let .rejected(error):
                p.rejectPromise(error)
            case .pending:
                blocks.success.append({ t in
                    self.registerNextPromise(block, result: t, resolve: p.resolvePromise,
                                             reject: p.rejectPromise)
                })
                blocks.fail.append(p.rejectPromise)
            }
            p.start()
            passAlongFirstPromiseStartFunctionAndStateTo(p)
            return p
    }
    
    @discardableResult public func then<X>(_ promise: Promise<X>) -> Promise<X> {
        return then { _ in promise }
    }
    
    @discardableResult public func registerThen<X>(_ promise: Promise<X>) -> Promise<X> {
        return registerThen { _ in promise }
    }
    
    internal func resolvePromise(_ result: T) {
        state = .fulfilled(value:result)
        for sb in blocks.success {
            sb(result)
        }
        blocks.finally()
        initialPromiseStart = nil
    }
}

// MARK: - Error

public extension Promise {

    @discardableResult public func onError(_ block: @escaping (Error) -> Void) -> Promise<Void> {
        tryStartInitialPromiseAndStartIfneeded()
        let p = Promise<Void>()
        switch state {
        case .fulfilled:
            p.rejectPromise(NSError(domain: "", code: 123, userInfo: nil))
        // No error so do nothing.
        case let .rejected(error):
            // Already failed so call error block
            block(error)
            p.resolvePromise()
        case .pending:
            // if promise fails, resolve error promise
            blocks.fail.append({ e in
                block(e)
                p.resolvePromise()
            })
            blocks.success.append({ _ in
                p.resolvePromise()
            })
        }
        blocks.progress.append(p.progressPromise)
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
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

// MARK: - Progress

public extension Promise {
    
    @discardableResult public func progress(block: @escaping (Float) -> Void) -> Promise<Void> {
        tryStartInitialPromiseAndStartIfneeded()
        let p = Promise<Void>()
        switch state {
        case .fulfilled:
            p.resolvePromise()
        case let .rejected(error):
            p.rejectPromise(error)
        case .pending:()
        blocks.fail.append(p.rejectPromise)
        blocks.success.append({ _ in
            p.resolvePromise()
        })
        }
        blocks.progress.append({ v in
            block(v)
            p.progressPromise(v)
        })
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    fileprivate func progressPromise(_ value: Float) {
        progress = value
        for pb in blocks.progress {
            pb(progress)
        }
    }
}

// MARK: - Finally

public extension Promise {
    
    @discardableResult public func finally<X>(_ block: @escaping () -> X) -> Promise<X> {
        tryStartInitialPromiseAndStartIfneeded()
        let p = Promise<X>()
        switch state {
        case .fulfilled:
            p.resolvePromise(block())
        case .rejected:
            p.resolvePromise(block())
        case .pending:
            blocks.fail.append({ _ in
                p.resolvePromise(block())
            })
            blocks.success.append({ _ in
                p.resolvePromise(block())
            })
        }
        blocks.progress.append(p.progressPromise)
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
}

public extension Promise {    
    public class func reject(error: Error) -> Promise<T> {
        return Promise { _, reject in reject(error) }
    }
}
