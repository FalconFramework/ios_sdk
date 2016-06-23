//
//  FFError.swift
//  FalconAPIClientSDK
//
//  Created by Luís Resende on 23/06/16.
//  Copyright © 2016 Falcon. All rights reserved.
//

import UIKit

class FFError: NSObject {
    
    var cod = 0
    var message = ""
    
    func FFErrorDescriptionMessage() -> String {
        return "Falcon Error \(self.cod): " + self.message
    }

}
