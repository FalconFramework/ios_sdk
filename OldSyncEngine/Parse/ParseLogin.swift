//
//  ParseLogin.swift
//  OnFit
//
//  Created by Thiago-Bernardes on 9/11/15.
//  Copyright (c) 2015 OnfFit. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4


class ParseLogin: NSObject {
    
    
    class func loginUserInViewController(vc: UIViewController!, username: String!, password: String!){
        
        let loginBlock = { () -> Void in
            
            let activityIndicator = ActivityIndicatorView(frame: vc.view.frame, indicatorText:NSLocalizedString("Connecting",comment: ""))
            vc.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            PFUser.logInWithUsernameInBackground(username, password: password){ (user: PFUser?, error: NSError?) -> Void in
                
                if (user != nil) {
                    // Do stuff after successful login.
                    activityIndicator.stopAnimating()
                    vc.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    // The login failed. Check error to see why.
                    activityIndicator.stopAnimating()
                    
                    let alert = UIAlertController(title: NSLocalizedString("invalid_email_password",comment: ""), message: NSLocalizedString("verify_login_info",comment:""), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    vc.presentViewController(alert, animated: true, completion: nil)
                }
            }
            
        }
        
        InternetConnection.checkConnectionAndPeformBlock(loginBlock)
        
    }
    
    class func recoverUserPasswordInViewController(vc: UIViewController!, email: String!){
        
        let recoverPasswordBlock = { () -> Void in
            
            let recoverConfirmationBlock = { (userEmail : String!) -> Void in
                PFUser.requestPasswordResetForEmailInBackground(userEmail)
                
                let alertTitle = String.localizableForKey("recover_link")
                let alertMessage = String.localizableForKey("recover_link")
                let recoverSuccess = UIAlertController(title: "\(alertTitle) \(userEmail)", message: " \(alertMessage) \"no-reply@parseapps.com\" ", preferredStyle: UIAlertControllerStyle.Alert)
                recoverSuccess.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                vc.presentViewController(recoverSuccess, animated: true, completion: nil)
            }
            
            
            if email.characters.count > 0{
                
                recoverConfirmationBlock(email)
                
                
            }else{
                
                let alertTitle = String.localizableForKey("input_registered_email")
                let alertMessage = String.localizableForKey("new_password_by_email")
                
                let alertRecover = UIAlertController(title: "\(alertTitle)", message: "\(alertMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                
                alertRecover.addTextFieldWithConfigurationHandler { (textField) in
                    textField.placeholder = "E-Mail"
                }
                
                let actionTitle = String.localizableForKey("Recover")
                alertRecover.addAction(UIAlertAction(title: actionTitle , style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction) -> Void in
                    //Handle action here.
                    if (alertRecover.textFields?.first)!.text!.characters.count > 0{
                        let userEmail = ((alertRecover.textFields?.first)!.text)
                        recoverConfirmationBlock(userEmail)
                        
                    }else{
                        
                        let alertTitle = String.localizableForKey("valid_email")
                        alertRecover.title = alertTitle
                        vc.presentViewController(alertRecover, animated: true, completion: nil)
                        
                    }
                }))
                let actionCancelTitle = String.localizableForKey("cancel")
                alertRecover.addAction(UIAlertAction(title: actionCancelTitle, style: UIAlertActionStyle.Cancel, handler: nil))
                vc.presentViewController(alertRecover, animated: true, completion: nil)
                
            }
        }
        
        InternetConnection.checkConnectionAndPeformBlock(recoverPasswordBlock)
        
        
    }
    
    class func parseSignupUserInViewController(vc: UIViewController!, userEmail: String!, userPassword: String!){
        
        
        let signupUserBlock = { () -> Void in
            
            let signupConfirmationBlock = { (user: PFUser!) -> Void in
                user.signUpInBackgroundWithBlock({
                    (succeeded: Bool, error: NSError?) -> Void in
                    if error == nil {
                        // Hooray! Let them use the app now.
                        vc.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        
                        var alertTitle : String!
                        var alertMessage: String!
                        switch(error!.code){
                        case 203:
                            alertTitle = String.localizableForKey("email_being_taken")
                            break
                        case 202:
							alertTitle = String.localizableForKey("email_being_taken")
							break
                        case 204:
                            alertTitle = String.localizableForKey("invalid_email")
                            break
                        case 125:
                            alertTitle = String.localizableForKey("invalid_email")
                            break
                        default:
                            alertTitle = "\(error!.code)"
                            break
                        }
                        alertMessage = String.localizableForKey("valid_email")
                        
                        
                        let recoverSuccess = UIAlertController(title: "\(alertTitle)", message: " \(alertMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                        recoverSuccess.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                        vc.presentViewController(recoverSuccess, animated: true, completion: nil)
                        
                    }
                })
                
            }
            
            
            
            if userEmail != "" {
                
                if userPassword != "" {
                    
                    let newUser = PFUser()
                    newUser.password = userPassword
                    newUser.email = userEmail
                    newUser.username = newUser.email
                    
                    
                    signupConfirmationBlock(newUser)
                    
                    
                }else{
                    
                    let alertTitle = String.localizableForKey("invalid_password")
                    let alertMessage = String.localizableForKey("input_valid_password")
                    
                    let alertSignUp = UIAlertController(title: "\(alertTitle)", message: "\(alertMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                    alertSignUp.addAction(UIAlertAction(title: "OK" , style: UIAlertActionStyle.Default, handler: nil))
                    
                    vc.presentViewController(alertSignUp, animated: true, completion: nil)
                    
                }
                
                
                
            }else{
                
                let alertTitle = String.localizableForKey("invalid_email")
                let alertMessage = String.localizableForKey("input_valid_email")
                
                let alertSignUp = UIAlertController(title: "\(alertTitle)", message: "\(alertMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                alertSignUp.addAction(UIAlertAction(title: "OK" , style: UIAlertActionStyle.Default, handler: nil))
                
                vc.presentViewController(alertSignUp, animated: true, completion: nil)
                
            }
            
        }
        
        InternetConnection.checkConnectionAndPeformBlock(signupUserBlock)
        
    }
    
    class func parseFacebookLoginInViewController(vc: UIViewController!){
        
        let permissionsArray = [ "user_about_me", "user_relationships", "user_birthday", "user_location","public_profile","email"]
        
        
        
        // Login PFUser using Facebook
        let activityIndicator = ActivityIndicatorView(frame: vc.view.frame, indicatorText:NSLocalizedString("Connecting",comment: ""))
        vc.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        
        let loginSucessBlock = {(user: PFUser?) -> Void in
            
            if (user!.isNew) {
                
                if((FBSDKAccessToken.currentAccessToken()) != nil){
                    FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                        if (error == nil){
                            let email = result.objectForKey("email") as! String
                            user?.setObject(email, forKey: "email")
                            user?.setObject(email, forKey: "username")
                            user?.saveInBackground()
                            
                        }
                    })
                }
                NSLog("User signed up and logged in through Facebook!")
            } else {
                NSLog("User logged in through Facebook!")
            }
            
            activityIndicator.stopAnimating()
            vc.dismissViewControllerAnimated(true, completion: nil)
            
            
            
        }
        
        
        let facebookLoginWebBlock = {() -> Void in
            PFFacebookUtils.facebookLoginManager().loginBehavior = FBSDKLoginBehavior.Web
            PFFacebookUtils.logInInBackgroundWithReadPermissions(permissionsArray, block: { (user: PFUser?, error: NSError?) -> Void in
                if (user == nil) {
                    if (error == nil) {
                        NSLog("The user cancelled the Facebook login.")
                    } else {
                        
                        NSLog("An error occurred: %@", error!.localizedDescription)
                    }
                    activityIndicator.stopAnimating()
                    
                    
                } else {
                    
                    loginSucessBlock(user)
                }
                
            })
            
        }
        
        
        let facebookLoginSystemBlock = {() -> Void in
            PFFacebookUtils.facebookLoginManager().loginBehavior = FBSDKLoginBehavior.SystemAccount
            PFFacebookUtils.logInInBackgroundWithReadPermissions(permissionsArray, block: { (user: PFUser?, error: NSError?) -> Void in
                if (user == nil) {
                    if (error == nil) {
                        activityIndicator.stopAnimating()
                        NSLog("The user cancelled the Facebook login.")
                    } else {
                        
                        if error?.code == 306{
                            InternetConnection.checkConnectionAndPeformBlock(facebookLoginWebBlock)
                        }else{
                            activityIndicator.stopAnimating()
                        }
                        NSLog("An error occurred: %@", error!.localizedDescription)
                    }
                    
                    
                } else {
                    loginSucessBlock(user)
                }
                
            })
            
        }
        
        //        let errorBlock = {(user: PFUser?, error: NSError?) -> Void in
        //            if (user == nil) {
        //                if (error == nil) {
        //                    NSLog("The user cancelled the Facebook login.")
        //                } else {
        //                    
        //                    if error?.code == 3{
        //                        PFFacebookUtils.facebookLoginManager().loginBehavior = FBSDKLoginBehavior.Web
        //                        InternetConnection.checkConnectionAndPeformBlock(facebookLoginBlock)
        //                    }
        //                    NSLog("An error occurred: %@", error!.localizedDescription)
        //                }
        //                
        //                
        //                
        //            }
        
        InternetConnection.checkConnectionAndPeformBlock(facebookLoginSystemBlock)
    }
    
    class func performActionIfUserIsLogged(ifLoggedBlock: () -> Void, andIfIsNotLoggedBlock : (() -> Void)?){
        
        
        if PFUser.currentUser() != nil{
            ifLoggedBlock()
            SessionControlSingleton.sharedData().currentUser!.cloudObjectId = PFUser.currentUser()?.objectId
        }else{
            
            andIfIsNotLoggedBlock?()
        }
    }
    
    class func logoutInBackground(){
        
        SyncEngine.sharedEngine().executeSyncServerLogoutOperations(PFUser.currentUser()?.objectId)
        PFUser.logOutInBackground()
        
    }
    
    
}
