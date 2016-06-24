//
//  FFRequestListener.swift
//  FalconAPIClientSDK
//
//  Created by Luís Resende on 23/06/16.
//  Copyright © 2016 Falcon. All rights reserved.
//

import Foundation

protocol FFRequestListener: class {
    
    /**
     * This method is for running a code after operation
     * find become success
     *
     * @param objects list of return objects if find success
     */
    func afterFindSuccess(objects: Array<AnyObject>);
    
    /**
     * This method is for running a code after operation
     * save become success
     *
     * @param object a return object if save success
     */
    func afterSaveSuccess(object: AnyObject);
    
    /**
     * This method is for running a code after operation
     * delete become success
     *
     * @param status an actual status if delete success
     */
    func afterDeleteSuccess(status: String);
    
    /**
     * This method is for running a code after operation
     * find return an error.
     *
     * @param error an error that causes find operation fail
     */
    func afterFindError(error:FFError);
    
    /**
     * This method is for running a code after operation
     * save return an error.
     *
     * @param error an error that causes save operation fail
     */
    func afterSaveError(error:FFError);
    
    /**
     * This method is for running a code after operation
     * delete return an error.
     *
     * @param error an error that causes delete operation fail
     */
    func afterDeleteError(error:FFError);
    
}