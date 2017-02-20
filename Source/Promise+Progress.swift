//
//  Promise+Progress.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 20/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

public extension Promise {
    
    @discardableResult public func progress(block: @escaping (Float) -> Void) -> Promise<Void> {
        tryStartInitialPromiseAndStartIfneeded()
        let p = Promise<Void>()
        switch state {
        case .fulfilled:
            p.resolvePromise()
        case let .rejected(error):
            p.rejectPromise(error)
        case .pending:()
        blocks.fail.append(p.rejectPromise)
        blocks.success.append({ _ in
            p.resolvePromise()
        })
        }
        blocks.progress.append({ v in
            block(v)
            p.progressPromise(v)
        })
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    internal func progressPromise(_ value: Float) {
        progress = value
        for pb in blocks.progress {
            pb(progress)
        }
    }
}
