//
//  Promise+Helpers.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 20/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

public struct PromiseDefaultError: Error {
    
}

public extension Promise {
    public class func reject(_ error: Error = PromiseDefaultError()) -> Promise<T> {
        return Promise { _, reject in reject(error) }
    }
}

public extension Promise {
    public class func resolve(_ value: T) -> Promise<T> {
        return Promise { resolve, _ in resolve(value) }
    }
}
