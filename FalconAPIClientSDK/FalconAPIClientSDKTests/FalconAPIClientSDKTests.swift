//
//  FalconAPIClientSDKTests.swift
//  FalconAPIClientSDKTests
//
//  Created by Thiago-Bernardes on 6/5/16.
//  Copyright © 2016 Falcon. All rights reserved.
//

import XCTest
//import FalconAPIClientSDK

class FalconAPIClientSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func testShouldGetNewINstanceWithBaseUrlAndKeyAndPattern() {
        var client: FFAPIClient
        client = FFAPIClient.newAPICLient("www.myserver.com", apiKey: "1234", serverPattern: .NONE)
        XCTAssertNotNil(client)
    }
    
    func testShouldGetSharedClient() {
        var client: FFAPIClient
        client = FFAPIClient.sharedClient
        XCTAssertNotNil(client)
    }
    
    func testShouldGetApiKeyHostUrlAndServerPattern() {
        var client: FFAPIClient
        client = FFAPIClient.newAPICLient("www.myserver.com", apiKey: "1234", serverPattern: .JSONAPI)
        XCTAssertEqual("http://www.myserver.com", client.host)
        XCTAssertEqual("1234", client.apiKey)
        XCTAssertEqual(ServerPattern.JSONAPI, client.serverPattern)
    }
}
