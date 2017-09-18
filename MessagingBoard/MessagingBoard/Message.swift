//
//  Message.swift
//  MessagingBoard
//
//  Created by Diego Eduardo on 9/17/17.
//  Copyright © 2017 Diego Santiago. All rights reserved.
//

import Foundation


class Message: NSObject {
    public var topic: String
    public var message: String
    public var email: String
    
    public init(topic: String, message: String, email: String) {
        self.topic = topic
        self.message = message
        self.email = email
    }
}
