//
//  FFURLBuilder.swift
//  FalconAPIClientSDK
//
//  Created by Luís Resende on 23/06/16.
//  Copyright © 2016 Falcon. All rights reserved.
//

import Foundation

protocol FFURLBuilder: class {
    
    var apiSettings:FFAPIClient? {get set}
    var host:String? {get set}
    var apiKey:String? {get set}
    
    func buildURL(requestType:String, modelName:String) -> String
    func buildURL(requestType:String, modelName:String, id:String) -> String
}
