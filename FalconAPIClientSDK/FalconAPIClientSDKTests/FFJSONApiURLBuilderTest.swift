//
//  FFJSONApiURLBuilderTest.swift
//  FalconAPIClientSDK
//
//  Created by Luís Resende on 24/06/16.
//  Copyright © 2016 Falcon. All rights reserved.
//

import XCTest

class FFJSONApiURLBuilderTest: XCTestCase {
    
    var ffapiClient:FFAPIClient?
    var ffjsonApiURLBuilder:FFJSONApiURLBuilder?

    override func setUp() {
        super.setUp()
        ffapiClient = FFAPIClient.newAPICLient("www.falcon.com", apiKey: "keyapifalcon", serverPattern: ServerPattern.JSONAPI)
        ffjsonApiURLBuilder = FFJSONApiURLBuilder.init()
    }

    func testShouldGetNewInstance(){
        XCTAssertNotNil(ffjsonApiURLBuilder)
    }
    
    func testBuildUrlFindAll(){
        let url = ffjsonApiURLBuilder!.buildURL("findAll",modelName: "user")
        XCTAssertEqual(url, "http://www.falcon.com/users")
    }
    
    func testBuildUrlQuery(){
        let url = ffjsonApiURLBuilder!.buildURL("query",modelName: "user")
        XCTAssertEqual(url, "http://www.falcon.com/users")
    }
    
    func testBuildUrlCreateRecord(){
        let url = ffjsonApiURLBuilder!.buildURL("createRecord",modelName: "user")
        XCTAssertEqual(url, "http://www.falcon.com/users")
    }
    
    func testBuildUrlDefault(){
        let url = ffjsonApiURLBuilder!.buildURL("",modelName: "user")
        XCTAssertEqual(url, "http://www.falcon.com/users")
    }
    
    func testBuildUrlWithIDFindRecord(){
        let url = ffjsonApiURLBuilder!.buildURL("findRecord",modelName: "user",id: "1")
        XCTAssertEqual(url, "http://www.falcon.com/users/1")
    }
    
    func testBuildUrlWithIDUpdateRecord(){
        let url = ffjsonApiURLBuilder!.buildURL("updateRecord",modelName: "user",id: "1")
        XCTAssertEqual(url, "http://www.falcon.com/users/1")
    }
    
    func testBuildUrlWithIDDeleteRecord(){
        let url = ffjsonApiURLBuilder!.buildURL("deleteRecord",modelName: "user",id: "1")
        XCTAssertEqual(url, "http://www.falcon.com/users/1")
    }
    
    func testBuildUrlWithIDDefault(){
        let url = ffjsonApiURLBuilder!.buildURL("",modelName: "user",id: "1")
        XCTAssertEqual(url, "http://www.falcon.com/users/1")
    }

}
