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
    
    public typealias ResolveCallBack = (object:T) -> Void
    public typealias RejectCallBack = (err:ErrorType) -> Void
    public typealias PromiseCallBack = (resolve:ResolveCallBack, reject:RejectCallBack) -> Void
    
    private var successBlock:(object:T) -> Void = { t in }
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
    
    func start() {
        promiseStarted = true
        promiseCallBack(resolve: { (object) -> Void in
            self.state = .Fulfilled
            self.value = object
            self.successBlock(object: object)
            self.finallyBlock()
            }) { (err:ErrorType) -> Void in
                self.state = .Rejected
                self.error = err
                self.failBlock(error: self.error!)
                self.finallyBlock()
        }
    }
    
    public func then<X>(block:(result:T) -> X) -> Promise<X>{
        if !promiseStarted {
            start()
        }
        
        let p = Promise<X>(callback: { (resolve, reject) -> Void in
            if self.state == .Fulfilled {
                let x:X = block(result: self.value!)
                resolve(object:x)
            } else if self.state == .Rejected {
                reject(err:self.error!)
            }
            else {
                self.successBlock = { t in
                    resolve(object:block(result: t))
                }
            }
            self.failBlock = { err in
                reject(err:err)
            }
        })
        p.start()
        return p
    }
    
    public func then<X>(block:(result:T) -> Promise<X>) -> Promise<X>{
        if !promiseStarted {
            start()
        }
        return Promise<X>(callback: { (resolve, reject) -> Void in
            self.successBlock = { t in
                let nextPromise:Promise<X> = block(result: t)
                nextPromise.then{ x in
                    resolve(object: x)
                    }.onError(reject)
            }
            self.failBlock = reject
        })
    }
    
    public func then<X>(p:Promise<X>) -> Promise<X>{
        successBlock = { t in
            p.start()
        }
        if !promiseStarted {
            start()
        }
        return p
    }
    
    public func onError(block:(error:ErrorType) -> Void) -> Self  {
        if state == .Rejected {
            block(error: error!)
        } else {
            failBlock = { err in
                block(error: err)
            }
        }
        return self
    }
    
    public func finally(block:() -> Void) -> Self  {
        if state != .Pending {
            block()
        } else {
            finallyBlock = block
        }
        return self
    }
}