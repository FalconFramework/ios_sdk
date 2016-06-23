//
//  FFErrorTest.swift
//  FalconAPIClientSDK
//
//  Created by Luís Resende on 23/06/16.
//  Copyright © 2016 Falcon. All rights reserved.
//

import XCTest

class FFErrorTest: XCTestCase {
    
    var error = FFError()
    
    override func setUp() {
        super.setUp()
        error.cod = 10
        error.message = "Server Internal"
    }
    
    func testShouldGetErrorDescriptionMessage() {
        XCTAssertEqual("Falcon Error 10: Server Internal", error.FFErrorDescriptionMessage())
    }
    
}
