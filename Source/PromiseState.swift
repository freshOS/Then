//
//  PromiseState.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

public enum PromiseState<T> {
    case dormant
    case pending(progress: Float)
    case fulfilled(value: T)
    case rejected(error: Error)
}

extension PromiseState {
    
    var value: T? {
        if case let .fulfilled(value) = self {
            return value
        }
        return nil
    }
    
    var error: Error? {
        if case let .rejected(error) = self {
            return error
        }
        return nil
    }
    
    var isDormant: Bool {
        if case .dormant = self {
            return true
        }
        return false
    }
    
    var isPendingOrDormant: Bool {
        return !isFulfilled && !isRejected
    }
    
    var isFulfilled: Bool {
        if case .fulfilled = self {
            return true
        }
        return false
    }
    
    var isRejected: Bool {
        if case .rejected = self {
            return true
        }
        return false
    }
}
