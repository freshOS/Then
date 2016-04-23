//
//  Promise.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 06/02/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

enum PromiseState {
    case Pending
    case Fulfilled
    case Rejected
}

public typealias EmptyPromise = Promise<Void>

public class Promise<T> {
    
    public typealias ResolveCallBack = (T) -> Void
    public typealias RejectCallBack = (ErrorType) -> Void
    public typealias PromiseCallBack = (resolve:ResolveCallBack, reject:RejectCallBack) -> Void
    
    private var successBlock:(T) -> Void = { t in }
    private var failBlock:((ErrorType) -> Void) = { _ in }
    private var finallyBlock:() -> Void = { t in }
    private var promiseCallBack:PromiseCallBack!
    private var promiseStarted = false
    private var state:PromiseState = .Pending
    private var value:T?
    private var error:ErrorType?
    var initialPromiseStart:(() -> Void)?
    var initialPromiseStarted = false
    
    public init(callback:(resolve:ResolveCallBack, reject:RejectCallBack) -> Void) {
        promiseCallBack = callback
    }
    
    public func start() {
        promiseStarted = true
        promiseCallBack(resolve:resolvePromise, reject:rejectPromise)
    }
    
    //MARK: - then((T)-> X)
    
    public func then<X>(block:(T) -> X) -> Promise<X>{
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerThen(block)
    }
    
    public func registerThen<X>(block:(T) -> X) -> Promise<X>{
        let p = Promise<X>{ resolve, reject in
            switch self.state {
            case .Fulfilled:
                let x:X = block(self.value!)
                resolve(x)
            case .Rejected:
                reject(self.error!)
            case .Pending:
                self.registerSuccess(resolve, block: block)
                self.failBlock = reject
            }
        }
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    //MARK: - then((T)->Promise<X>)
    
    public func then<X>(block:(T) -> Promise<X>) -> Promise<X>{
        tryStartInitialPromise()
        startPromiseIfNeeded()
        return registerThen(block)
    }
    
    public func registerThen<X>(block:(T) -> Promise<X>) -> Promise<X>{
        let p = Promise<X>{ resolve, reject in
            switch self.state {
            case .Fulfilled:
                self.registerNextPromise(block, result: self.value!,resolve:resolve,reject:reject)
            case .Rejected:
                reject(self.error!)
            case .Pending:
                self.successBlock = { t in
                    self.registerNextPromise(block, result: t,resolve:resolve,reject:reject)
                }
                self.failBlock = reject
            }
        }
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    //MARK: - then(Promise<X>)
    
    public func then<X>(p:Promise<X>) -> Promise<X>{
        return then { _ in p }
    }
    
    public func registerThen<X>(p:Promise<X>) -> Promise<X>{
        return registerThen { _ in p }
    }
    
    
    //MARK: - Error
    
    public func onError(block:(ErrorType) -> Void) -> Self  {
        startPromiseIfNeeded()
        if state == .Rejected { block(error!) }
        else { failBlock = block }
        return self
    }
    
    //MARK: - Finally
    
    public func finally(block:() -> Void) -> Self  {
        startPromiseIfNeeded()
        if state != .Pending {
            block()
        }
        else { finallyBlock = block }
        return self
    }
    
    //MARK: - Helpers
    
    private func passAlongFirstPromiseStartFunctionAndStateTo<X>(p:Promise<X>) {
        // Pass along First promise start block
        if let startBlock = self.initialPromiseStart {
            p.initialPromiseStart = startBlock
        } else {
            p.initialPromiseStart = self.start
        }
        // Pass along initil promise start state.
        p.initialPromiseStarted = self.initialPromiseStarted
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
    
    private func registerSuccess<X>(resolve:(X) -> Void, block:(T) -> X) {
        successBlock = { t in
            resolve(block(t))
        }
    }
    
    private func registerNextPromise<X>(block:(T) -> Promise<X>, result:T, resolve:(X) -> Void,reject:RejectCallBack) {
        let nextPromise:Promise<X> = block(result)
        nextPromise.then { x in
            resolve(x)
        }.onError(reject)
    }
    
    private func resolvePromise(result:T) {
        state = .Fulfilled
        value = result
        successBlock(result)
        finallyBlock()
    }
    
    private func rejectPromise(e:ErrorType) {
        state = .Rejected
        error = e
        failBlock(error!)
        finallyBlock()
    }
}