//
//  PromiseType.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 20/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

public protocol AsyncType {
    associatedtype AType
    
    var state: PromiseState<AType> { get }
    
    init(callback: @escaping (
         _ resolve: @escaping ((AType) -> Void),
         _ reject: @escaping ((Error) -> Void),
         _ progress: @escaping ((Float) -> Void)) -> Void)
    
}
