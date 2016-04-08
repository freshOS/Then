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
    private var isFirstPromise = true
    
    public init(callback:(resolve:ResolveCallBack, reject:RejectCallBack) -> Void) {
        promiseCallBack = callback
    }
    
    public func start() {
        promiseStarted = true
        promiseCallBack(resolve:resolvePromise, reject:rejectPromise)
    }
    
    public func then<X>(block:(T) -> X) -> Promise<X>{
        startPromiseIfNeeded()
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
        return p
    }
    
    public func then<X>(block:(T) -> Promise<X>) -> Promise<X>{
        startPromiseIfNeeded()
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
        return p
    }
    
    public func then<X>(p:Promise<X>) -> Promise<X>{
        return then { _ in p }
    }
    
    public func onError(block:(ErrorType) -> Void) -> Self  {
        startPromiseIfNeeded()
        if state == .Rejected { block(error!) }
        else { failBlock = block }
        return self
    }
    
    public func finally(block:() -> Void) -> Self  {
        startPromiseIfNeeded()
        if state != .Pending {
            block()
        }
        else { finallyBlock = block }
        return self
    }
    
    private func startPromiseIfNeeded() {
        if !promiseStarted && isFirstPromise { start() }
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