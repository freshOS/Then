//
//  Promise+Recover.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 22/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

extension Promise {
    
    public func recover(with value: T) -> Promise<T> {
        let p = newLinkedPromise()
        syncStateWithCallBacks(
            success: p.fulfill,
            failure: { _ in
                p.fulfill(value)
        }, progress: p.setProgress)
        return p
    }

    public func recover<E: Error>(_ errorType: E, with value: T) -> Promise<T> {
        let p = newLinkedPromise()
        syncStateWithCallBacks(
            success: p.fulfill,
            failure: { e in
                if errorMatchesExpectedError(e, expectedError:errorType) {
                    p.fulfill(value)
                } else {
                    p.reject(e)
                }
            },
            progress: p.setProgress)
        return p
    }
    
    public func recover<E: Error>(_ errorType: E, with value: T) -> Promise<T> where E: Equatable {
        let p = newLinkedPromise()
        syncStateWithCallBacks(
            success: p.fulfill,
            failure: { e in
                if errorMatchesExpectedError(e, expectedError:errorType) {
                    p.fulfill(value)
                } else {
                    p.reject(e)
                }
            },
            progress: p.setProgress)
        
        return p
    }
    
    public func recover(with promise: Promise<T>) -> Promise<T> {
        let p = newLinkedPromise()
        syncStateWithCallBacks(
            success: p.fulfill,
            failure: { _ in
                promise.then { t in
                    p.fulfill(t)
                }.onError { error in
                    p.reject(error)
                }
            },
            progress: p.setProgress)
        return p
    }
    
    public func recover(_ block:@escaping (Error) throws -> T) -> Promise<T> {
        let p = newLinkedPromise()
        syncStateWithCallBacks(
            success: p.fulfill,
            failure: { e in
                do {
                    let v = try block(e)
                    p.fulfill(v)
                } catch {
                    p.reject(error)
                }
        }, progress: p.setProgress)
        return p
    }
}

// Credits to Quick/Nimble for how to compare Errors
// https://github.com/Quick/Nimble/blob/db706fc1d7130f6ac96c56aaf0e635fa3217fe57/Sources/
// Nimble/Utils/Errors.swift#L37-L53
private func errorMatchesExpectedError<T: Error>(_ error: Error, expectedError: T) -> Bool {
    return error._domain == expectedError._domain && error._code   == expectedError._code
}

private func errorMatchesExpectedError<T: Error>(_ error: Error,
                                                 expectedError: T) -> Bool where T: Equatable {
    if let error = error as? T {
        return error == expectedError
    }
    return false
}
