//
//  Promise+Delay.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 09/08/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

extension Promise {
    
    public func delay(_ time: TimeInterval) -> Promise<T> {
        return Promise<T> { resolve, _ in
            self.then { t in
                if let callingQueue = OperationQueue.current?.underlyingQueue {
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).asyncAfter(deadline: .now() + time) {
                        callingQueue.async {
                            resolve(t)
                        }
                    }
                }
            }
        }
    }
}

extension Promises {
    public static func delay(_ time: Double) -> Promise<Void> {
        return Promise.resolve().delay(time)
    }
}


// TimeOut
extension Promise {
    
    public func timeout(_ time: TimeInterval) -> Promise<T> { 
        return Promise { resolve, reject in
            var done = false
        
            self.then { t in
                if !done {
                    done = true
                    resolve(t)
                }
            }
            
            Promises.delay(time).then {
                if !done {
                    done = true
                    reject(PromiseError.timeout)
                }
            }
        }
    }
}

