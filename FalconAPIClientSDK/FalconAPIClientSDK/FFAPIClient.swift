//
//  FFAPIClient.swift
//  FalconAPIClientSDK
//
//  Created by Thiago-Bernardes on 6/5/16.
//  Copyright © 2016 Falcon. All rights reserved.
//

import UIKit

class FFAPIClient: NSObject {
    
    var host = ""
    var apiKey = ""
    var serverPattern = ServerPattern.NONE
    
    /// Returns an Singleton Instance
    static var sharedClient = FFAPIClient()
    
    /**
     * Set in Singleton Instance the parametres url and apiKey
     *
     * @param url an api base url for client
     * @param key an api key of client in server
     */
    static func newAPICLient(host: String, apiKey: String, serverPattern: ServerPattern) -> FFAPIClient {
        FFAPIClient.sharedClient.host = FFAPIClient.sharedClient.normalizeNakedURL(host)
        FFAPIClient.sharedClient.apiKey = apiKey
        FFAPIClient.sharedClient.serverPattern = serverPattern
        return FFAPIClient.sharedClient
    }
    
    private func normalizeNakedURL(nakedURL: String) -> String {
        return "http://" + nakedURL
    }
    
    
}
