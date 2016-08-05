//
//  Promise.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 06/02/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
=======
enum PromiseState {
    case pending
    case fulfilled
    case rejected
}

>>>>>>> Migrates to swift 3
public typealias EmptyPromise = Promise<Void>

public class Promise<T> {
   
    public typealias ResolveCallBack = (T) -> Void
    public typealias ProgressCallBack = (Float) -> Void
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    public typealias RejectCallBack = (ErrorType) -> Void
    public typealias PromiseCallBack = (resolve: ResolveCallBack, reject: RejectCallBack) -> Void
    public typealias PromiseProgressCallBack =
        (resolve: ResolveCallBack,
        reject: RejectCallBack,
        progress: ProgressCallBack) -> Void
    private typealias SuccessBlock = (T) -> Void
    private typealias FailBlock = (ErrorType) -> Void
=======
    public typealias RejectCallBack = (Error) -> Void
    public typealias PromiseCallBack = (resolve:ResolveCallBack, reject:RejectCallBack) -> Void
    public typealias PromiseProgressCallBack = (resolve:ResolveCallBack, reject:RejectCallBack, progress:ProgressCallBack) -> Void
    private typealias SuccessBlock = (T) -> Void
    private var successBlocks = [SuccessBlock]()
    private typealias FailBlock = (Error) -> Void
    private var failBlocks = [FailBlock]()
>>>>>>> Migrates to swift 3
    private typealias ProgressBlock = (Float) -> Void
    
    private var successBlocks = [SuccessBlock]()
    private var failBlocks = [FailBlock]()
    private var progressBlocks = [ProgressBlock]()
    private var finallyBlock: () -> Void = { }
    private var promiseCallBack: PromiseCallBack!
    private var promiseProgressCallBack: PromiseProgressCallBack?
    private var promiseStarted = false
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    private var state: PromiseState<T> = .Pending
    private var progress: Float?
=======
    private var state:PromiseState = .pending
    private var value:T?
    private var progress:Float?
    private var error:Error?
>>>>>>> Migrates to swift 3
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
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    public func then<X>(block: (T) -> X) -> Promise<X> {
=======
    @discardableResult public func then<X>(_ block:(T) -> X) -> Promise<X> {
>>>>>>> Migrates to swift 3
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerThen(block)
    }
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    public func registerThen<X>(block: (T) -> X) -> Promise<X> {
        let p = Promise<X> { resolve, reject, progress in
            switch self.state {
            case let .Fulfilled(value):
                let x: X = block(value)
                resolve(x)
            case let .Rejected(error):
                reject(error)
            case .Pending:
=======
    @discardableResult public func registerThen<X>(_ block:(T) -> X) -> Promise<X>{
        let p = Promise<X>{ resolve, reject, progress in
            switch self.state {
            case .fulfilled:
                let x:X = block(self.value!)
                resolve(x)
            case .rejected:
                reject(self.error!)
            case .pending:
>>>>>>> Migrates to swift 3
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
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    public func then<X>(block: (T) -> Promise<X>) -> Promise<X> {
=======
    @discardableResult public func then<X>(_ block:(T) -> Promise<X>) -> Promise<X>{
>>>>>>> Migrates to swift 3
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerThen(block)
    }
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    public func registerThen<X>(block: (T) -> Promise<X>) -> Promise<X> {
        let p = Promise<X> { resolve, reject in
            switch self.state {
            case let .Fulfilled(value):
                self.registerNextPromise(block, result: value,
                resolve: resolve, reject: reject)
            case let .Rejected(error):
                reject(error)
            case .Pending:
=======
    @discardableResult public func registerThen<X>(_ block:(T) -> Promise<X>) -> Promise<X>{
        let p = Promise<X>{ resolve, reject in
            switch self.state {
            case .fulfilled:
                self.registerNextPromise(block, result: self.value!,resolve:resolve,reject:reject)
            case .rejected:
                reject(self.error!)
            case .pending:
>>>>>>> Migrates to swift 3
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
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    public func then<X>(promise: Promise<X>) -> Promise<X> {
        return then { _ in promise }
    }
    
    public func registerThen<X>(promise: Promise<X>) -> Promise<X> {
        return registerThen { _ in promise }
=======
    @discardableResult public func then<X>(_ p:Promise<X>) -> Promise<X>{
        return then { _ in p }
    }
    
    @discardableResult public func registerThen<X>(_ p:Promise<X>) -> Promise<X>{
        return registerThen { _ in p }
>>>>>>> Migrates to swift 3
    }
    
    //MARK: - Error
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    public func onError(block: (ErrorType) -> Void) -> Promise<Void> {
=======
    @discardableResult public func onError(_ block:(Error) -> Void) -> Promise<Void>  {
>>>>>>> Migrates to swift 3
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerOnError(block)
    }
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    public func registerOnError(block: (ErrorType) -> Void) -> Promise<Void> {
=======
    @discardableResult public func registerOnError(_ block:(Error) -> Void) -> Promise<Void>{
>>>>>>> Migrates to swift 3
        let p = Promise<Void> { resolve, reject, progress in
            switch self.state {
            case .fulfilled:
                reject(NSError(domain: "", code: 123, userInfo: nil))
            // No error so do nothing.
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
            case let .Rejected(error):
=======
            case .rejected:
>>>>>>> Migrates to swift 3
                // Already failed so call error block
                block(error)
                resolve()
            case .pending:
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
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    public func finally<X>(block: () -> X) -> Promise<X> {
=======
    @discardableResult public func finally<X>(_ block:() -> X) -> Promise<X>  {
>>>>>>> Migrates to swift 3
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerFinally(block)
    }
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    public func registerFinally<X>(block: () -> X) -> Promise<X> {
        let p = Promise<X> { resolve, reject, progress in
=======
    @discardableResult public func registerFinally<X>(_ block:() -> X) -> Promise<X>{
        let p = Promise<X>{ resolve, reject, progress in
>>>>>>> Migrates to swift 3
            switch self.state {
            case .fulfilled:
                resolve(block())
            case .rejected:
                resolve(block())
            case .pending:
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
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    public func progress(block: (Float) -> Void) -> Promise<Void> {
=======
    @discardableResult public func progress(_ block:(Float) -> Void) -> Promise<Void>  {
>>>>>>> Migrates to swift 3
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerProgress(block)
    }
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    public func registerProgress(block: (Float) -> Void) -> Promise<Void> {
=======
    @discardableResult public func registerProgress(_ block:(Float) -> Void) -> Promise<Void>{
>>>>>>> Migrates to swift 3
        let p = Promise<Void> { resolve, reject, progress in
            switch self.state {
            case .fulfilled:
                resolve()
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
            case let .Rejected(error):
                reject(error)
            case .Pending:()
=======
            case .rejected:
                reject(self.error!)
            case .pending:()
>>>>>>> Migrates to swift 3
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
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    private func passAlongFirstPromiseStartFunctionAndStateTo<X>(promise: Promise<X>) {
=======
    private func passAlongFirstPromiseStartFunctionAndStateTo<X>(_ p:Promise<X>) {
>>>>>>> Migrates to swift 3
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
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    private func registerNextPromise<X>(block: (T) -> Promise<X>, result: T, resolve: (X) -> Void,
                                     reject: RejectCallBack) {
        let nextPromise: Promise<X> = block(result)
=======
    private func registerNextPromise<X>(_ block:(T) -> Promise<X>, result:T, resolve:(X) -> Void,reject:RejectCallBack) {
        let nextPromise:Promise<X> = block(result)
>>>>>>> Migrates to swift 3
        nextPromise.then { x in
            resolve(x)
        }.onError(reject)
    }
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    private func resolvePromise(result: T) {
        state = .Fulfilled(value:result)
=======
    private func resolvePromise(_ result:T) {
        state = .fulfilled
        value = result
>>>>>>> Migrates to swift 3
        for sb in successBlocks {
            sb(result)
        }
        finallyBlock()
    }
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    private func rejectPromise(anError: ErrorType) {
        state = .Rejected(error:anError)
=======
    private func rejectPromise(_ e:Error) {
        state = .rejected
        error = e
>>>>>>> Migrates to swift 3
        for fb in failBlocks {
            fb(anError)
        }
        finallyBlock()
    }
    
<<<<<<< a2885b0e9aa7da5cdbc5b1b02fb79813da5a55d9
    private func progressPromise(value: Float) {
        progress = value
=======
    private func progressPromise(_ p:Float) {
        progress = p
>>>>>>> Migrates to swift 3
        for pb in progressBlocks {
            if let progress = progress {
                pb(progress)
            }
        }
    }
}
