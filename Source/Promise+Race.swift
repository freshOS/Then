//
//  Promise+Race.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 22/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

extension Promises {
    public static func race<T>(_ promises: Promise<T>...) -> Promise<T> {
        return Promise { resolve, reject in
            var done = false
            var errorCount = 0
            for p in promises {
                p.then { t in
                    if !done {
                        resolve(t)
                        done = true
                    }
                }.onError { e in
                    errorCount += 1
                    if errorCount == promises.count {
                        reject(PromiseError.raceAllFailed(lastError: e))
                    }
                }
            }
        }
    }
}
