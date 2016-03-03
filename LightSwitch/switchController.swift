//
//  switchController.swift
//  LightSwitch
//
//  Created by Lukas Bisdorf on 02.12.15.
//  Copyright © 2015 Lukas Bisdorf. All rights reserved.
//

import Foundation
import Alamofire
import AppKit

class switchController {
    
    let FILE_NAME_OF_SWITCH_ON_DOCUMENT: String = "switchOn"
    let FILE_NAME_OF_SWITCH_OFF_DOCUMENT: String = "switchOff"
    let FILE_NAME_OF_SWITCH_STATUS_DOCUMENT: String = "switchStatus"
    
    let events = EventManager()
    
    let username: String
    let password: String
    let host: String
    
    
    init(username: String, password: String, host: String) {
        self.username = username
        self.password = password
        self.host = host
        
        
    }
    
    private func createBase64String(input: String) -> String {
        let utf8str = input.dataUsingEncoding(NSUTF8StringEncoding)
        return utf8str!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
    

    
    private func uploadXmlToHost(xml: NSURL) {
        let headers = [
            "Authorization": "Basic " + createBase64String(username + ":" + password)
        ]
        
        Alamofire.upload(
            .POST,
            "http://" + host + ":10000/smartplug.cgi",
            headers: headers,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(fileURL: xml, name: "file")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseData{ response in
                        if let value: NSData = response.result.value {
                            // Decode the Base64 Value.
                            let post = NSString(data: value, encoding: NSUTF8StringEncoding)
                            
                            if (post?.rangeOfString(">OFF<").length != 0) {
                                self.events.trigger("off", information: "off")
                                
                            }
                            
                            if (post?.rangeOfString(">ON<").length != 0)  {
                                self.events.trigger("on", information: "on")
                            }
                            if (post?.rangeOfString(">OK<").length != 0)  {
                                self.getStatus()
                            }
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
            
        )
    }
    
    
    func turnOn() {
        let document = NSBundle.mainBundle().URLForResource(FILE_NAME_OF_SWITCH_ON_DOCUMENT, withExtension: "xml")
        uploadXmlToHost(document!)
    }
    
    func turnOff() {
        let document = NSBundle.mainBundle().URLForResource(FILE_NAME_OF_SWITCH_OFF_DOCUMENT, withExtension: "xml")
        uploadXmlToHost(document!)
    }
    func getStatus() -> Bool {
        let document = NSBundle.mainBundle().URLForResource(FILE_NAME_OF_SWITCH_STATUS_DOCUMENT, withExtension: "xml")
        uploadXmlToHost(document!)
        return false
    }
    
    
    
    
}
