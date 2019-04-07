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
    case completed(result: Result<T, Error>)
}

extension PromiseState {

    var value: T? {
        if case .completed(let result) = self, case .success(let value) = result {
            return value
        }
        return nil
    }

    var error: Error? {
        if case .completed(let result) = self, case .failure(let error) = result {
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
        if case.completed(let result) = self, case .success = result {
            return true
        }
        return false
    }
    
    var isRejected: Bool {
        if case .completed(let result) = self, case .failure = result {
            return true
        }
        return false
    }
}
