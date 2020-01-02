//
//  PromiseBlocks.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 26/10/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

struct PromiseBlocks<T> {
    
    typealias SuccessBlock = (T) -> Void
    typealias FailBlock = (Error) -> Void
    typealias ProgressBlock = (Float) -> Void
    typealias FinallyBlock = () -> Void
    
    var success = [SuccessBlock]()
    var fail = [FailBlock]()
    var progress = [ProgressBlock]()
    var finally = [FinallyBlock]()
}

extension PromiseBlocks {
    
    func updateProgress(_ progress: Float) -> () -> Void {
        let progressBlocks = self.progress
        return {
            progressBlocks.forEach { $0(progress) }
        }
    }
    
    func fulfill(value: T) -> () -> Void {
        let successBlocks = self.success
        let finallyBlocks = self.finally
        return {
            successBlocks.forEach { $0(value) }
            finallyBlocks.forEach { $0() }
        }
    }
    
    func reject(error: Error) -> () -> Void {
        let failureBlocks = self.fail
        let finallyBlocks = self.finally
        return {
            failureBlocks.forEach { $0(error) }
            finallyBlocks.forEach { $0() }
        }
    }
}
