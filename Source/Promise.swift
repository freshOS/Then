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
    public typealias PromiseCallBack = (_ resolve: @escaping ResolveCallBack,
        _ reject: @escaping RejectCallBack) -> Void
    public typealias PromiseProgressCallBack =
        (_ resolve: @escaping ResolveCallBack,
        _ reject: @escaping RejectCallBack,
        _ progress: @escaping ProgressCallBack) -> Void
    private typealias SuccessBlock = (T) -> Void
    private typealias FailBlock = (Error) -> Void
    private typealias ProgressBlock = (Float) -> Void
    
    private var successBlocks = [SuccessBlock]()
    private var failBlocks = [FailBlock]()
    private var progressBlocks = [ProgressBlock]()
    private var finallyBlock: () -> Void = { }
    private var promiseCallBack: PromiseCallBack!
    private var promiseProgressCallBack: PromiseProgressCallBack?
    private var promiseStarted = false
    private var state: PromiseState<T> = .pending
    private var progress: Float?
    var initialPromiseStart:(() -> Void)?
    var initialPromiseStarted = false
    
    public init(callback: @escaping (_ resolve: @escaping ResolveCallBack,
        _ reject: @escaping RejectCallBack) -> Void) {
        promiseCallBack = callback
    }
    
    public init(callback: @escaping (_ resolve: @escaping ResolveCallBack,
        _ reject: @escaping RejectCallBack, _ progress: @escaping ProgressCallBack) -> Void) {
        promiseProgressCallBack = callback
    }
    
    public func start() {
        promiseStarted = true
        if let p = promiseProgressCallBack {
            p(resolvePromise, rejectPromise, progressPromise)
        } else {
            promiseCallBack(resolvePromise, rejectPromise)
        }
    }
    
    //MARK: - then((T)-> X)
    
    @discardableResult public func then<X>(_ block: @escaping (T) -> X) -> Promise<X> {
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerThen(block)
    }
    
    @discardableResult public func registerThen<X>(_ block: @escaping (T) -> X) -> Promise<X> {
        let p = Promise<X> { [weak self] resolve, reject, progress in
            if let state = self?.state {
                switch state {
                case let .fulfilled(value):
                    let x: X = block(value)
                    resolve(x)
                case let .rejected(error):
                    reject(error)
                case .pending:
                    self?.successBlocks.append({ t in
                        resolve(block(t))
                    })
                    self?.failBlocks.append(reject)
                    self?.progressBlocks.append(progress)
                }
            }
        }
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    //MARK: - then((T)->Promise<X>)
    
    @discardableResult public func then<X>(_ block: @escaping (T) -> Promise<X>) -> Promise<X> {
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerThen(block)
    }
    
    @discardableResult  public func registerThen<X>(_ block: @escaping (T) -> Promise<X>)
        -> Promise<X> {
            let p = Promise<X> { [weak self] resolve, reject in
                if let state = self?.state {
                    switch state {
                    case let .fulfilled(value):
                        self?.registerNextPromise(block, result: value,
                                                  resolve: resolve, reject: reject)
                    case let .rejected(error):
                        reject(error)
                    case .pending:
                        self?.successBlocks.append({ t in
                            self?.registerNextPromise(block, result: t, resolve: resolve, reject: reject)
                        })
                        self?.failBlocks.append(reject)
                    }
                }
            }
            p.start()
            passAlongFirstPromiseStartFunctionAndStateTo(p)
            return p
    }
    
    //MARK: - then(Promise<X>)
    
    
    @discardableResult public func then<X>(_ promise: Promise<X>) -> Promise<X> {
        return then { _ in promise }
    }
    
    @discardableResult public func registerThen<X>(_ promise: Promise<X>) -> Promise<X> {
        return registerThen { _ in promise }
    }
    
    //MARK: - Error
    
    @discardableResult public func onError(_ block: @escaping (Error) -> Void) -> Promise<Void> {
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerOnError(block)
    }
    
    
    @discardableResult public func registerOnError(_ block:
        @escaping (Error) -> Void) -> Promise<Void> {
        let p = Promise<Void> { [weak self] resolve, reject, progress in
            if let state = self?.state {
                switch state {
                case .fulfilled:
                    reject(NSError(domain: "", code: 123, userInfo: nil))
                // No error so do nothing.
                case let .rejected(error):
                    // Already failed so call error block
                    block(error)
                    resolve()
                case .pending:
                    // if promise fails, resolve error promise
                    self?.failBlocks.append({ e in
                        block(e)
                        resolve()
                    })
                    self?.successBlocks.append({ t in
                        resolve()
                    })
                }
            }
            self?.progressBlocks.append(progress)
        }
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    //MARK: - Finally
    
    
    @discardableResult public func finally<X>(block: @escaping () -> X) -> Promise<X> {
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerFinally(block: block)
    }
    
    @discardableResult public func registerFinally<X>(block: @escaping () -> X) -> Promise<X> {
        let p = Promise<X> { [weak self] resolve, reject, progress in
            if let state = self?.state {
                switch state {
                case .fulfilled:
                    resolve(block())
                case .rejected:
                    resolve(block())
                case .pending:
                    self?.failBlocks.append({ e in
                        resolve(block())
                    })
                    self?.successBlocks.append({ t in
                        resolve(block())
                    })
                }
            }
            self?.progressBlocks.append(progress)
        }
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    //MARK: - Progress
    
    @discardableResult public func progress(block: @escaping (Float) -> Void) -> Promise<Void> {
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerProgress(block)
    }
    
    public func registerProgress(_ block: @escaping (Float) -> Void) -> Promise<Void> {
        let p = Promise<Void> { [weak self] resolve, reject, progress in
            if let state = self?.state {
                switch state {
                case .fulfilled:
                    resolve()
                case let .rejected(error):
                    reject(error)
                case .pending:()
                self?.failBlocks.append(reject)
                self?.successBlocks.append({ _ in
                    resolve()
                })
                }
            }
            self?.progressBlocks.append({ p in
                block(p)
                progress(p)
            })
        }
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    
    //MARK: - Helpers
    
    private func passAlongFirstPromiseStartFunctionAndStateTo<X>(_ promise: Promise<X>) {
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
    
    private func registerNextPromise<X>(_ block: (T) -> Promise<X>,
                                     result: T,
                                     resolve: @escaping (X) -> Void,
                                     reject: @escaping RejectCallBack) {
        let nextPromise: Promise<X> = block(result)
        nextPromise.then { x in
            resolve(x)
            }.onError(reject)
    }
    
    private func resolvePromise(_ result: T) {
        state = .fulfilled(value:result)
        for sb in successBlocks {
            sb(result)
        }
        finallyBlock()
        initialPromiseStart = nil
    }
    
    private func rejectPromise(_ anError: Error) {
        state = .rejected(error:anError)
        for fb in failBlocks {
            fb(anError)
        }
        finallyBlock()
        initialPromiseStart = nil
    }
    
    private func progressPromise(_ value: Float) {
        progress = value
        for pb in progressBlocks {
            if let progress = progress {
                pb(progress)
            }
        }
    }
}
