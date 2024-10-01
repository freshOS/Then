//
//  Async.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 13/03/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation
import Dispatch

@discardableResult
public func asyncBlock<T :Sendable>(block:@escaping @Sendable () throws -> T) -> Async<T> {
    let p = Promise<T> { resolve, reject in
        DispatchQueue(label: "then.async.queue", attributes: .concurrent).async {
            do {
                let t = try block()
                resolve(t)
            } catch {
                reject(error)
            }
        }
    }
    p.start()
    return p
}
