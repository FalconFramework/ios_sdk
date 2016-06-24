//
//  FFJSONApiURLBuilder.swift
//  FalconAPIClientSDK
//
//  Created by Luís Resende on 23/06/16.
//  Copyright © 2016 Falcon. All rights reserved.
//

import Foundation

class FFJSONApiURLBuilder: FFURLBuilder {
    
    var apiSettings:FFAPIClient?
    var host:String?
    var apiKey:String?
    
    init(){
        self.apiSettings = FFAPIClient.sharedClient
        self.host = self.apiSettings?.host
        self.apiKey = self.apiSettings?.apiKey
    }
    
    func pathForType(modelName: String) -> String {
        return modelName.lowercaseStringWithLocale(NSLocale(localeIdentifier: "en_US")) + "s"
    }
    
    func _buildURL(modelName: String) -> String {
        let path = self.pathForType(modelName)
        let host = self.host
        
        return host! + "/" + path
    }
    
    func _buildURL(modelName: String, id: String) -> String {
        
        let encodedID = id.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        
        return self._buildURL(modelName) + "/" + encodedID!;
    }
    
    /**
     * Builds a URL for a given type and optional ID.
     * By default, it pluralizes the type's name (for example, 'post' becomes 'posts' and 'person' becomes 'people').
     * If an ID is specified, it adds the ID to the path generated for the type, separated by a /.
     */
    func buildURL(requestType: String, modelName: String) -> String {
        switch (requestType) {
        case "findAll":
            return self._buildURL(modelName);
        case "query":
            return self._buildURL(modelName);
        case "createRecord":
            return self._buildURL(modelName);
        default:
            return self._buildURL(modelName);
        }
    }
    
    func buildURL(requestType: String, modelName: String, id: String) -> String {
        switch (requestType) {
        case "findRecord":
            return self._buildURL(modelName, id: id);
        case "updateRecord":
            return self._buildURL(modelName, id: id);
        case "deleteRecord":
            return self._buildURL(modelName, id: id);
        default:
            return self._buildURL(modelName,id: id);
        }
    }

}
