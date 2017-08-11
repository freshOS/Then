//
//  Promise+BridgeError.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 24/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

public extension Promise {
    
    public func bridgeError(to myError: Error) -> Promise<T> {
        let p = newLinkedPromise()
        syncStateWithCallBacks(
            success: p.fulfill,
            failure: { _ in
                p.reject(myError)
            },
            progress: p.setProgress)
        return p
    }
    
    public func bridgeError(_ errorType: Error, to myError: Error) -> Promise<T> {
        let p = newLinkedPromise()
        syncStateWithCallBacks(
            success: p.fulfill,
            failure: { e in
                if e._code == errorType._code && e._domain == errorType._domain {
                    p.reject(myError)
                } else {
                    p.reject(e)
                }
            },
            progress: p.setProgress)
        return p
    }
    
    public func bridgeError(_ block:@escaping (Error) throws -> Void) -> Promise<T> {
        let p = newLinkedPromise()
        syncStateWithCallBacks(
            success: p.fulfill,
            failure: { e in
                do {
                    try block(e)
                } catch {
                    p.reject(error)
                }
            },
            progress: p.setProgress)
        return p
    }
}
