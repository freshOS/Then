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
            p.fulfill()
        case let .rejected(error):
            p.reject(error)
        case .dormant, .pending:
        blocks.fail.append(p.reject)
        blocks.success.append({ _ in
            p.fulfill()
        })
        }
        blocks.progress.append({ v in
            block(v)
            p.setProgress(v)
        })
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
    
    internal func setProgress(_ value: Float) {
        updateState(PromiseState<T>.pending(progress: value))
    }
}
