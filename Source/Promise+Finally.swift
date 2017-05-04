//
//  Promise+Finally.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 20/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

public extension Promise {
    
    @discardableResult public func finally<X>(_ block: @escaping () -> X) -> Promise<X> {
        tryStartInitialPromiseAndStartIfneeded()
        return registerFinally(block)
    }
    
    @discardableResult public func registerFinally<X>(_ block: @escaping () -> X) -> Promise<X> {
        let p = Promise<X>()
        switch state {
        case .fulfilled:
            p.resolvePromise(block())
        case .rejected:
            p.resolvePromise(block())
        case .pending:
            blocks.fail.append({ _ in
                p.resolvePromise(block())
            })
            blocks.success.append({ _ in
                p.resolvePromise(block())
            })
            blocks.progress.append(p.progressPromise)
        }
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
}
