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

typealias EmptyPromise = Promise<Void>

public class Promise<T> {
    
    public typealias ResolveCallBack = (result:T) -> Void
    public typealias RejectCallBack = (error:ErrorType) -> Void
    public typealias PromiseCallBack = (resolve:ResolveCallBack, reject:RejectCallBack) -> Void
    
    private var successBlock:(result:T) -> Void = { t in }
    private var failBlock:((error:ErrorType) -> Void) = { err in }
    private var finallyBlock:() -> Void = { t in }
    private var promiseCallBack:PromiseCallBack = { resolve, reject in    }
    private var promiseStarted = false
    private var state:PromiseState = .Pending
    private var value:T?
    private var error:ErrorType?
    
    public init(callback:(resolve:ResolveCallBack, reject:RejectCallBack) -> Void) {
        promiseCallBack = callback
    }
    
    public func start() {
        promiseStarted = true
        promiseCallBack(resolve:resolvePromise, reject:rejectPromise)
    }
    
    private func resolvePromise(result:T) {
        state = .Fulfilled
        value = result
        successBlock(result: result)
        finallyBlock()
    }
    
    private func rejectPromise(e:ErrorType) {
        state = .Rejected
        error = e
        failBlock(error: error!)
        finallyBlock()
    }
    
    public func then<X>(block:(result:T) -> X) -> Promise<X>{
        startPromiseIfNeeded()
        let p = Promise<X>(callback: { (resolve, reject) -> Void in
            if self.state == .Fulfilled {
                let x:X = block(result: self.value!)
                resolve(result:x)
            } else if self.state == .Rejected {
                reject(error:self.error!)
            }
            else {
                self.successBlock = { t in
                    resolve(result:block(result: t))
                }
            }
            self.failBlock = reject
        })
        p.start()
        return p
    }
    
    public func then<X>(block:(result:T) -> Promise<X>) -> Promise<X>{
        startPromiseIfNeeded()
        return Promise<X>(callback: { (resolve, reject) -> Void in
            self.successBlock = { t in
                let nextPromise:Promise<X> = block(result: t)
                nextPromise.then{ x in
                    resolve(result: x)
                }.onError(reject)
            }
            self.failBlock = reject
        })
    }
    
    public func then<X>(p:Promise<X>) -> Promise<X>{
        successBlock = { t in p.start() }
        startPromiseIfNeeded()
        return p
    }
    
    public func onError(block:(error:ErrorType) -> Void) -> Self  {
        if state == .Rejected { block(error: error!) }
        else { failBlock = block }
        return self
    }
    
    public func finally(block:() -> Void) -> Self  {
        if state != .Pending { block() }
        else { finallyBlock = block }
        return self
    }
    
    private func startPromiseIfNeeded() {
        if !promiseStarted { start() }
    }
}