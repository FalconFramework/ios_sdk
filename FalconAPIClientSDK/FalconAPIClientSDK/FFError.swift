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
    
    /**
     * Returns an Error Description Message that can then be show
     * on the screen.
     * This method construct an error description message with
     * his actual propertys
     *
     * @return      the error description message
     */
    func FFErrorDescriptionMessage() -> String {
        return "Falcon Error \(self.cod): " + self.message
    }

}
