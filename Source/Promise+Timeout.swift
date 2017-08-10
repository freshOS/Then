//
//  Promise+Timeout.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 10/08/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

extension Promise {
    
    public func timeout(_ time: TimeInterval) -> Promise<T> {
        return Promise { resolve, reject in
            var done = false
            self.then { t in
                if !done {
                    done = true
                    resolve(t)
                }
            }
            Promises.delay(time).then {
                if !done {
                    done = true
                    reject(PromiseError.timeout)
                }
            }
        }
    }
}
