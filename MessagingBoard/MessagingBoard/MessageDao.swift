//
//  MessageDao.swift
//  MessagingBoard
//
//  Created by Diego Eduardo on 9/17/17.
//  Copyright © 2017 Diego Santiago. All rights reserved.
//

import Foundation

class MessageDao: NSObject {
    
    public static let instance = MessageDao()
    
    public func parseMessage(_ data:[[String:String]]) -> [Message] {

        var result = [Message]()
        
        for index in data {
            let topic: String = index["topic"] ?? ""
            let message: String = index["message"] ?? ""
            let email: String = index["email"] ?? ""
            
            let messObj = Message(topic: topic, message: message, email: email)
            result.append(messObj)
        }
        if result.isEmpty {
            let topic = ""
            let message = "No results"
            let email = ""
            let messObj = Message(topic: topic, message: message, email: email)
            result.append(messObj)
            
        }
        return result
    }
}
