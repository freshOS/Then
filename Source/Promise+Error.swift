//
//  Promise+Error.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 20/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

public extension Promise {
    
    @discardableResult public func onError(_ block: @escaping (Error) -> Void) -> Promise<Void> {
        tryStartInitialPromiseAndStartIfneeded()
        let p = Promise<Void>()
        switch state {
        case .fulfilled:
            p.resolvePromise()
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
    
    public func bridgeError(_ block:@escaping (Error) throws -> Void) -> Promise<T> {
        return Promise<T> { resolve, reject in
            self.then { t in
                resolve(t)
            }.onError { e in
                do {
                    try block(e)
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    public func bridgeError(to myError: Error) -> Promise<T> {
        return Promise<T> { resolve, reject in
            self.then { t in
                resolve(t)
            }.onError { _ in
                reject(myError)
            }
        }
    }
}
