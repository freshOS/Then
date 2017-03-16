//
//  Promise+NoMatterWhat.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 24/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

extension Promise {

    public func noMatterWhat(_ block: @escaping () -> Void) -> Promise<T> {
        return Promise { resolve, reject in
            self.then { result in
                block()
                resolve(result)
            }.onError { error in
                block()
                reject(error)
            }
        }
    }
}
