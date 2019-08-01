//
//  Promise+Progress.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 20/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

public extension Promise {
    
    @discardableResult public func progress(_ block: @escaping (Float) -> Void) -> Promise<T> {
        let p = newLinkedPromise()
        syncStateWithCallBacks(
            success: p.fulfill,
            failure: p.reject,
            progress: { f in
                block(f)
                p.setProgress(f)
            }
        )
        p.start()
        return p
    }
    
    internal func setProgress(_ value: Float) {
        updateState(PromiseState<T>.pending(progress: value))
    }
}
