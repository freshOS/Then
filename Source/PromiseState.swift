//
//  PromiseState.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

public enum PromiseState<T> {
    case pending
    case fulfilled(value:T)
    case rejected(error:Error)
}
