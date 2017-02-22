//
//  Promise+Retry.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 22/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

extension Promise {
    public func retry(_ nbOfTimes: UInt) -> Promise<T> {
        guard nbOfTimes > 0 else {
            return Promise.reject(PromiseDefaultError())
        }
        return Promise { resolve, reject in
            var numberOfRetriesLeft = nbOfTimes
            while numberOfRetriesLeft > 0 {
                numberOfRetriesLeft -= 1
                self.resetState()
                self.then { t in
                    numberOfRetriesLeft = 0
                    resolve(t)
                }.onError { e in
                    if numberOfRetriesLeft == 0 {
                        reject(e)
                    }
                }
            }
        }
    }
}
