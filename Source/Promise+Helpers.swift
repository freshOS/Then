//
//  Promise+Helpers.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 20/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

public extension Promise {
    public class func reject(error: Error) -> Promise<T> {
        return Promise { _, reject in reject(error) }
    }
}
