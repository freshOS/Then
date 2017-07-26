//
//  Promise+Validate.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 22/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

extension Promise {
    
    @discardableResult
    public func validate(withError: Error = PromiseError.validationFailed,
                         _ assertionBlock:@escaping ((T) -> Bool)) -> Promise<T> {
        return self.then { s in
            if assertionBlock(s) {
                return Promise.resolve(s)
            }
            return Promise.reject(withError)
        }
    }
}
