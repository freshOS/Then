//
//  VoidPromise.swift
//  then
//
//  Created by Sacha DSO on 27/09/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

extension Promise where T == Void {
    
    public convenience init(callback: @escaping (
        _ resolve: @escaping (() -> Void),
        _ reject: @escaping ((Error) -> Void)) -> Void) {
        self.init()
        promiseProgressCallBack = { resolve, reject, progress in
            callback({ [weak self] in
                self?.fulfill(())
                }, { [weak self ] e in
                    self?.reject(e)
            })
        }
    }
    
    public convenience init(callback2: @escaping (
        _ resolve: @escaping (() -> Void),
        _ reject: @escaping ((Error) -> Void),
        _ progress: @escaping ((Float) -> Void)) -> Void) {
        self.init()
        promiseProgressCallBack = { resolve, reject, progress in
            callback2(self.fulfill, self.reject, self.setProgress)
        }
    }
}
