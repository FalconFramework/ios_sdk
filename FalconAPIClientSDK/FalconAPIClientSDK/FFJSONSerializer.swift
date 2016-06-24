//
//  FFJSONSerializer.swift
//  FalconAPIClientSDK
//
//  Created by Luís Resende on 24/06/16.
//  Copyright © 2016 Falcon. All rights reserved.
//

import Foundation

class FFJSONSerializer: NSObject {
    
    internal var resourceName:String?
    
    init(resourceName:String) {
        self.resourceName = resourceName
    }
    
//    func serializePayload(payload: JSONObject) -> Array<AnyObject> {
//        ArrayList<T> serializedPayload = new ArrayList<T>();
//        
//        
//        if (payload.has(this.pluralizedResourceName())) {
//            JSONArray payloadArray = null;
//            try {
//                payloadArray = payload.getJSONArray(this.pluralizedResourceName());
//            } catch (JSONException e) {
//                e.printStackTrace();
//            }
//            Iterator<T> jsonArrayIterator  = new FFJSONSerializerIterator<>(this.resourceName, payloadArray);
//            while (jsonArrayIterator.hasNext()) {
//                T object = jsonArrayIterator.next();
//                serializedPayload.add(object);
//            }
//            
//        } else {
//            try {
//                serializedPayload.add(this.serialize(payload.getJSONObject(this.resourceName)));
//            } catch (JSONException e) {
//                e.printStackTrace();
//            }
//        }
//        
//        return serializedPayload;
//    }
    
//    internal func serialize(payload: JSONObject) -> AnyObject {
//        T newResource = this.newResourceInstance();
//        
//        Iterator<?> keys = payload.keys();
//        
//        while(keys.hasNext()) {
//            String key = (String)keys.next();
//            try {
//                if (!payload.isNull(key)) {
//                    Object value = payload.get(key);
//                    this.setFildToInstace(value, key, newResource);
//                }
//            } catch (JSONException e) {
//                e.printStackTrace();
//            }
//        }
//        
//        return  newResource;
//    }
    
    private func getResourceClass() -> AnyClass {
//        Class<T> resourceClass = null;
//        try {
//            String className = "Models." + this.capitalizedResourceName();
//            //                String className = "Models." + this.capitalizedResourceName();
//            resourceClass = (Class<T>)Class.forName(className);
//        } catch (ClassNotFoundException e) {
//            e.printStackTrace();
//        }
//        
//        return resourceClass;
        return self.classForCoder
    }
    
    private func newResourceInstance() -> AnyObject{
//    Class<T> resourceClass = this.getResourceClass();
//    T newResourceInstace = null;
//    
//    try {
//    newResourceInstace = resourceClass.newInstance();
//    } catch (InstantiationException e) {
//    e.printStackTrace();
//    } catch (IllegalAccessException e) {
//    e.printStackTrace();
//    }
//    
//    return newResourceInstace;
        return self
    }
    
    private func capitalizedResourceName() -> String {
        //return this.resourceName.substring(0, 1).toUpperCase() + this.resourceName.substring(1);
        return ""
    }
    
    private func pluralizedResourceName() -> String{
        //return English.plural(this.resourceName);
        return ""
    }
    
    private func setFildToInstace(fieldValue:AnyObject, fieldName:String, instance:AnyObject) {
//    Field field = null;
//    
//    try {
//    field = instance.getClass().getField(fieldName);
//    field.setAccessible(true);
//    try {
//    field.set(instance, fieldValue);
//    } catch (IllegalAccessException e) {
//    e.printStackTrace();
//    }
//    } catch (NoSuchFieldException e) {
//    e.printStackTrace();
//    }
    }
    
//    func deserialize(model:AnyObject) -> RequestParams {
//    Field[] fields = this.getResourceClass().getFields();
//    
//    RequestParams params = new RequestParams();
//    
//    
//    for (Field field : fields ) {
//    try {
//    if (field.get(model) != null && field.getName().contentEquals("currentRequester")==false
//    && field.getName().contentEquals("requestResponse")==false)
//    params.put(field.getName(), "" + field.get(model));
//    } catch (IllegalAccessException e) {
//    e.printStackTrace();
//    }
//    }
//    
//    
//    return params;
//    }

}
