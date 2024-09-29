//
//  ValidateTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 22/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
struct ValidateTests {
    
    @Test
    func validateSucceeds() async {
        _ = await confirmation { done in
            Promise<Int>.resolve(24)
                .validate { $0 > 18 }
                .then { _ in
                    done()
                }
        }
    }
    
    @Test
    func validateFails() async {
        _ = await confirmation { done in
            Promise<Int>.resolve(16)
                .validate { ($0 > 18) }
                .onError { error in
                    if let pe = error as? PromiseError {
                        #expect(pe == .validationFailed)
                    } else {
                        Issue.record("testValidateFails failed")
                    }
                    done()
                }
        }
    }
    
    @Test
    func validateWithCustomError() async {
        _ = await confirmation { done in
            Promise<Int>.resolve(16)
                .validate(withError: MyError.defaultError, { $0 > 18 })
                .onError { error in
                    if let pe = error as? MyError {
                        #expect(pe == MyError.defaultError)
                    } else {
                        Issue.record("testValidateWithCustomError failed")
                    }
                    done()
                }
        }
    }
    
    @Test
    func validateNotCalledOnError() async {
        _ = await confirmation { done in
            Promise.reject().validate {
                Issue.record("testValidateNotCalledOnError failed")
                return true
            }.finally {
                done()
            }
        }
    }
}
