//
//  NetworkManager.swift
//  MessagingBoard
//
//  Created by Diego Eduardo on 9/17/17.
//  Copyright © 2017 Diego Santiago. All rights reserved.
//

import Foundation

protocol NetworgMangerDelegate: class {
    func didGetInfo(_ message:[Message])
    func postMessage(_ message: Message)
}

class NetworkManager: NSObject {
    
    public static let instance = NetworkManager()
    weak var delegate: NetworgMangerDelegate?
    lazy var messageDao = MessageDao.instance
    
    public func getMessageForTopic(_ topic: String) {
        let stringUrl = "http://diegosantiago.site.swiftengine.net/messages.ssp/\(topic)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: stringUrl) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any] {
                        //ParseInfo
                        //self.charDao.parseCharacers(jsonObject)
                        if let result = jsonObject["result"] as? [[String:String]]{
                            DispatchQueue.main.async {
                                let message = self.messageDao.parseMessage(result)
                                self.delegate?.didGetInfo(message)
                            }
                        }
                    }
                } catch {
                    
                }
            }
        }
        task.resume()
    }
    
    public func addMessage(_ message: Message) {
        let Url = String(format: "http://diegosantiago.site.swiftengine.net/messages.ssp")
        guard let serviceUrl = URL(string: Url) else { return }
        //        let loginParams = String(format: LOGIN_PARAMETERS1, "test", "Hi World")
        let parameterDictionary = ["topic" : message.topic, "message" : message.message, "email": message.email]
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                if let res = response as? HTTPURLResponse {
                    if res.statusCode == 200 {
                        self.delegate?.postMessage(message)
                    }
                }
            }
        }
        task.resume()
    }
}
