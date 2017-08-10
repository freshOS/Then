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
