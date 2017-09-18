//
//  AddMessageView.swift
//  MessagingBoard
//
//  Created by Diego Eduardo on 9/17/17.
//  Copyright © 2017 Diego Santiago. All rights reserved.
//

import Foundation
import UIKit

protocol AddMessageViewDelegate: class {
    func didFinishView()
}
class AddMessageView: UIView {
    
    //MARK:- IBOUtlets
    @IBOutlet weak var topic: UITextField!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var clear: UIButton!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var close: UIButton!
    
    weak var delegate: AddMessageViewDelegate?
    
    lazy var netInstance = NetworkManager.instance
    var messageCreated: Message?
    
    class func instanceFromNib() -> AddMessageView {
        
        
        return UINib(nibName: "AddMessageView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AddMessageView
    }
    
    //MARK:- Actions
    
    @IBAction func clearAction(_ sender: UIButton) {
           }
    
    @IBAction func addAction(_ sender: UIButton) {
        if validateFields() {
            if let existMessage = messageCreated {
                netInstance.addMessage(existMessage)
            }
            clearFields()
            removeView()
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
       removeView()
    }
    
    //MARK:-Private methods
    
    fileprivate func validateFields() -> Bool {
        var result = false
        let topicText = topic.text ?? ""
        let messageText = message.text ?? ""
        let emailText = email.text ?? ""
        
        if topicText.isEmpty || messageText.isEmpty || emailText.isEmpty {
            return false
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        result =  emailTest.evaluate(with: emailText)
        
        messageCreated = Message(topic: topicText, message: messageText, email: emailText)
        return result
    }
    
    fileprivate func clearFields() {
        topic.text = ""
        message.text = ""
        email.text = ""
    }
    
    fileprivate func removeView() {
        self.removeFromSuperview()
        self.endEditing(true)
        self.delegate?.didFinishView()
        
    }
}
