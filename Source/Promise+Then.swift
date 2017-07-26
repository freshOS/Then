//
//  Promise+Then.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 20/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

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
                blocks.success.append({ [weak self] t in
                    self?.registerNextPromise(block, result: t, resolve: p.resolvePromise,
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
    
    fileprivate func registerNextPromise<X>(_ block: (T) -> Promise<X>,
                                            result: T,
                                            resolve: @escaping (X) -> Void,
                                            reject: @escaping ((Error) -> Void)) {
        let nextPromise: Promise<X> = block(result)
        nextPromise.then { x in
            resolve(x)
            }.onError(reject)
    }
}
