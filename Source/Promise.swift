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
    public typealias RejectCallBack = (ErrorType) -> Void
    public typealias PromiseCallBack = (resolve: ResolveCallBack, reject: RejectCallBack) -> Void
    public typealias PromiseProgressCallBack =
        (resolve: ResolveCallBack,
        reject: RejectCallBack,
        progress: ProgressCallBack) -> Void
    private typealias SuccessBlock = (T) -> Void
    private typealias FailBlock = (ErrorType) -> Void
    private typealias ProgressBlock = (Float) -> Void
    
    private var successBlocks = [SuccessBlock]()
    private var failBlocks = [FailBlock]()
    private var progressBlocks = [ProgressBlock]()
    private var finallyBlock: () -> Void = { }
    private var promiseCallBack: PromiseCallBack!
    private var promiseProgressCallBack: PromiseProgressCallBack?
    private var promiseStarted = false
    private var state: PromiseState<T> = .Pending
    private var progress: Float?
    var initialPromiseStart:(() -> Void)?
    var initialPromiseStarted = false
    
    public init(callback: (resolve: ResolveCallBack, reject: RejectCallBack) -> Void) {
        promiseCallBack = callback
    }
    
    public init(callback:
        (resolve: ResolveCallBack, reject: RejectCallBack, progress: ProgressCallBack) -> Void) {
        promiseProgressCallBack = callback
    }
    
    public func start() {
        promiseStarted = true
        if let p = promiseProgressCallBack {
            p(resolve:resolvePromise, reject:rejectPromise, progress:progressPromise)
        } else {
            promiseCallBack(resolve:resolvePromise, reject:rejectPromise)
        }
    }
    
    //MARK: - then((T)-> X)
    
    public func then<X>(block: (T) -> X) -> Promise<X> {
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerThen(block)
    }
    
    public func registerThen<X>(block: (T) -> X) -> Promise<X> {
        let p = Promise<X> { resolve, reject, progress in
            switch self.state {
            case let .Fulfilled(value):
                let x: X = block(value)
                resolve(x)
            case let .Rejected(error):
                reject(error)
            case .Pending:
                self.successBlocks.append({ t in
                    resolve(block(t))
                })
                self.failBlocks.append(reject)
            }
            self.progressBlocks.append({ p in
                progress(p)
            })
        }
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    //MARK: - then((T)->Promise<X>)
    
    public func then<X>(block: (T) -> Promise<X>) -> Promise<X> {
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerThen(block)
    }
    
    public func registerThen<X>(block: (T) -> Promise<X>) -> Promise<X> {
        let p = Promise<X> { resolve, reject in
            switch self.state {
            case let .Fulfilled(value):
                self.registerNextPromise(block, result: value,
                resolve: resolve, reject: reject)
            case let .Rejected(error):
                reject(error)
            case .Pending:
                self.successBlocks.append({ t in
                    self.registerNextPromise(block, result: t, resolve: resolve, reject: reject)
                })
                self.failBlocks.append(reject)
            }
        }
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    //MARK: - then(Promise<X>)
    
    public func then<X>(promise: Promise<X>) -> Promise<X> {
        return then { _ in promise }
    }
    
    public func registerThen<X>(promise: Promise<X>) -> Promise<X> {
        return registerThen { _ in promise }
    }
    
    //MARK: - Error
    
    public func onError(block: (ErrorType) -> Void) -> Promise<Void> {
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerOnError(block)
    }
    
    public func registerOnError(block: (ErrorType) -> Void) -> Promise<Void> {
        let p = Promise<Void> { resolve, reject, progress in
            switch self.state {
            case .Fulfilled:
                reject(NSError(domain: "", code: 123, userInfo: nil))
            // No error so do nothing.
            case let .Rejected(error):
                // Already failed so call error block
                block(error)
                resolve()
            case .Pending:
                // if promise fails, resolve error promise
                self.failBlocks.append({ e in
                    block(e)
                    resolve()
                })
                self.successBlocks.append({ t in
                    resolve()
                })
            }
            self.progressBlocks.append({ p in
                progress(p)
            })
        }
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    //MARK: - Finally
    
    public func finally<X>(block: () -> X) -> Promise<X> {
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerFinally(block)
    }
    
    public func registerFinally<X>(block: () -> X) -> Promise<X> {
        let p = Promise<X> { resolve, reject, progress in
            switch self.state {
            case .Fulfilled:
                resolve(block())
            case .Rejected:
                resolve(block())
            case .Pending:
                self.failBlocks.append({ e in
                    resolve(block())
                })
                self.successBlocks.append({ t in
                    resolve(block())
                })
            }
            self.progressBlocks.append({ p in
                progress(p)
            })
        }
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    //MARK: - Progress
    
    public func progress(block: (Float) -> Void) -> Promise<Void> {
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerProgress(block)
    }
    
    public func registerProgress(block: (Float) -> Void) -> Promise<Void> {
        let p = Promise<Void> { resolve, reject, progress in
            switch self.state {
            case .Fulfilled:
                resolve()
            case let .Rejected(error):
                reject(error)
            case .Pending:()
                self.failBlocks.append(reject)
                self.successBlocks.append({ _ in
                    resolve()
                })
            }
            self.progressBlocks.append({ p in
                block(p)
                progress(p)
            })
        }
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    
    //MARK: - Helpers
    
    private func passAlongFirstPromiseStartFunctionAndStateTo<X>(promise: Promise<X>) {
        // Pass along First promise start block
        if let startBlock = self.initialPromiseStart {
            promise.initialPromiseStart = startBlock
        } else {
            promise.initialPromiseStart = self.start
        }
        // Pass along initil promise start state.
        promise.initialPromiseStarted = self.initialPromiseStarted
    }
    
    private func tryStartInitialPromise() {
        if !initialPromiseStarted {
            initialPromiseStart?()
            initialPromiseStarted = true
        }
    }
    
    private func startPromiseIfNeeded() {
        if !promiseStarted { start() }
    }
    
    private func registerNextPromise<X>(block: (T) -> Promise<X>, result: T, resolve: (X) -> Void,
                                     reject: RejectCallBack) {
        let nextPromise: Promise<X> = block(result)
        nextPromise.then { x in
            resolve(x)
        }.onError(reject)
    }
    
    private func resolvePromise(result: T) {
        state = .Fulfilled(value:result)
        for sb in successBlocks {
            sb(result)
        }
        finallyBlock()
    }
    
    private func rejectPromise(anError: ErrorType) {
        state = .Rejected(error:anError)
        for fb in failBlocks {
            fb(anError)
        }
        finallyBlock()
    }
    
    private func progressPromise(value: Float) {
        progress = value
        for pb in progressBlocks {
            if let progress = progress {
                pb(progress)
            }
        }
    }
}
