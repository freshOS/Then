//
//  Await+Operators.swift
//  then
//
//  Created by Sacha DSO on 30/05/2018.
//  Copyright © 2018 s4cha. All rights reserved.
//

import Foundation

prefix operator ..

public prefix func .. <T>(promise: Promise<T>) throws -> T {
    return try await(promise)
}

public prefix func .. <T>(promise: Promise<T>?) throws -> T {
    guard let promise = promise else { throw PromiseError.unwrappingFailed }
    return try await(promise)
}

prefix operator ..?

public prefix func ..? <T>(promise: Promise<T>) -> T? {
    do {
        return try await(promise)
    } catch {
        return nil
    }
}

public prefix func ..? <T>(promise: Promise<T>?) -> T? {
    guard let promise = promise else { return nil }
    do {
        return try await(promise)
    } catch {
        return nil
    }
}
