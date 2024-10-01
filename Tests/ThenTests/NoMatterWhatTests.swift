//
//  NoMatterWhatTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 24/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
struct NoMatterWhatTests {
    
    @Test
    func noMatterWhatCalledOnSuccess() async {
        var isLoading = true
        #expect(isLoading)
        let name = await withCheckedContinuation { continuation in
            Promise
                .resolve("Cool")
                .noMatterWhat {
                    isLoading = false
                }
                .finally {
                    continuation.resume(returning: "finally")
                }
        }
        #expect(name == "finally")
        #expect(!isLoading)
    }
    
    @Test
    func testNoMatterWhatCalledOnError() async {
        var isLoading = true
        let name = await withCheckedContinuation { continuation in
            #expect(isLoading)
            Promise<String>.reject()
                .noMatterWhat {
                    isLoading = false
                }
                .finally {
                    continuation.resume(returning: "finally")
                }
        }
        #expect(name == "finally")
        #expect(!isLoading)
    }
}
