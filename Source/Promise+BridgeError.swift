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
        return Promise<T> { resolve, reject in
            self.then { t in
                resolve(t)
            }.onError { _ in
                reject(myError)
            }
        }
    }
    
    public func bridgeError(_ errorType: Error, to myError: Error) -> Promise<T> {
        return Promise<T> { resolve, reject in
            self.then { t in
                resolve(t)
            }.onError { e in
                if e._code == errorType._code && e._domain == errorType._domain {
                    reject(myError)
                } else {
                    reject(e)
                }
            }
        }
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
}
