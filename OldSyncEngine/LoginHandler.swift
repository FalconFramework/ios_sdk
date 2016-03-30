//
//  LoginHandler.swift
//  OnFit
//
//  Created by Thiago-Bernardes on 9/11/15.
//  Copyright (c) 2015 OnfFit. All rights reserved.
//

import UIKit

class LoginHandler: NSObject {
    
    class func loginUserInViewController(vc: UIViewController!, username: String!, password: String!){

        ParseLogin.loginUserInViewController(vc, username: username, password: password)
        
    }
    
    class func recoverUserPasswordInViewController(vc: UIViewController!, email: String!){
        
        ParseLogin.recoverUserPasswordInViewController(vc, email: email)
    }
    
    class func facebookLoginInViewController(vc: UIViewController!){
     
        ParseLogin.parseFacebookLoginInViewController(vc)
        
    }

    class func performActionIfUserIsLogged(ifLoggedBlock: () -> Void, andIfIsNotLoggedBlock : (() -> Void)?){
        
       ParseLogin.performActionIfUserIsLogged(ifLoggedBlock,andIfIsNotLoggedBlock: andIfIsNotLoggedBlock)
    
    }
    
    class func logoutInBackground(){
        
        ParseLogin.logoutInBackground()
    }
    
    class func signupUserInViewController(vc: UIViewController!, userEmail: String!, userPassword: String!){
        
        ParseLogin.parseSignupUserInViewController(vc, userEmail: userEmail, userPassword: userPassword)
        
    }
    
   
}
