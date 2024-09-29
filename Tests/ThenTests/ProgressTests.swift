//
//  ProgressTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Testing
import Then

@Suite
struct ProgressTests {

    @Test
    func progress() async {
        var progress: Float = 0
        let name = await withCheckedContinuation { continuation in
            upload().progress { p in
                progress = p
            }.then {
                continuation.resume(returning: "done")
            }.onError { _ in
                Issue.record("Error called")
            }
        }
        #expect(progress == 0.8)
        #expect(name == "done")
    }
    
    @Test
    func progressFails() async {
        var progress: Float = 0
        let name = await withCheckedContinuation { continuation in
            failingUpload().progress { p in
                progress = p
            }.then {
                Issue.record("then called")
            }.onError { _ in
                continuation.resume(returning: "error")
            }
        }
        #expect(progress == 0.8)
        #expect(name == "error")
    }
}
