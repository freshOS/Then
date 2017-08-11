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
        let p = registerThen(block)
        tryStartInitialPromiseAndStartIfneeded()
        return p
    }
    
    @discardableResult public func registerThen<X>(_ block: @escaping (T) -> X) -> Promise<X> {
        let p = Promise<X>()
        switch state {
        case let .fulfilled(value):
            let x: X = block(value)
            p.fulfill(x)
        case let .rejected(error):
            p.reject(error)
        case .dormant, .pending:
            blocks.success.append({ t in
                p.fulfill(block(t))
            })
            blocks.fail.append({ e in
                p.reject(e)
            })
            blocks.progress.append({ f in
                p.setProgress(f)
            })
        }
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
                                    resolve: p.fulfill, reject: p.reject)
            case let .rejected(error):
                p.reject(error)
            case .dormant, .pending:
                blocks.success.append({ [weak self] t in
                    self?.registerNextPromise(block, result: t, resolve: p.fulfill,
                                             reject: p.reject)
                })
                blocks.fail.append(p.reject)
                blocks.progress.append(p.setProgress)
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
