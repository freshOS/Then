//
//  Promise+Error.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 20/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

public extension Promise {
    
    @discardableResult public func onError(_ block: @escaping (Error) -> Void) -> Promise<Void> {
        tryStartInitialPromiseAndStartIfneeded()
        return registerOnError(block)
    }
    
    @discardableResult public func registerOnError(_ block: @escaping (Error) -> Void) -> Promise<Void> {
        let p = Promise<Void>()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        syncStateWithCallBacks(
            success: { [weak p] _ in
                p?.fulfill()
            },
            failure: { [weak p] e in
                block(e)
                p?.fulfill()
            },
            progress: p.setProgress
        )
        p.start()
        return p
    }
}
