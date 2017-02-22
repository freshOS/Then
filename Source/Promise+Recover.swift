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
        return Promise { resolve, _ in
            self.then { t in
                resolve(t)
            }.onError { _ in
                resolve(value)
            }
        }
    }
    
    public func recover(_ block:@escaping (Error) -> Promise<T>) -> Promise<T> {
        return Promise<T> { resolve, _ in
            self.then { t in
                resolve(t)
            }.onError { e in
                let p = block(e)
                p.then { t in
                    resolve(t)
                }
            }
        }
    }
}
