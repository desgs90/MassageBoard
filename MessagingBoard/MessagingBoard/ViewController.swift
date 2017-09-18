//
//  ViewController.swift
//  MessagingBoard
//
//  Created by Diego Eduardo on 9/17/17.
//  Copyright © 2017 Diego Santiago. All rights reserved.
//

import UIKit
import Messages
import MessageUI

class ViewController: UIViewController {

    //MARK:- IBOUtlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputController: UIView!
    
    var tableData = [Int: Any]()
    var index = 1
    
    var initY: CGFloat = 0.0
    
    lazy var networkManager = NetworkManager.instance
    
    //var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textField.delegate = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        tableView.tableFooterView = UIView()
        
        networkManager.delegate = self
        
        //Register Cells
        let sendCell = UINib(nibName: "RequestMessage", bundle: nil)
        tableView.register(sendCell, forCellReuseIdentifier: "RequestMessage")
        
        let sresponseCell = UINib(nibName: "ResponseMessage", bundle: nil)
        tableView.register(sresponseCell, forCellReuseIdentifier: "ResponseMessage")
        
        sendButton.isEnabled = false
        
        configNotifications()
        //UserDefaults.standard.set(dict, forKey: "dict")
        //let result = UserDefaults.standard.value(forKey: "dict")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initY = self.view.frame.origin.y
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Button Actions
    @IBAction func sendAction(_ sender: UIButton) {
        textField.resignFirstResponder()
        let index = getNextIndex()
        tableData[index] = textField.text
        if let text = textField.text {
            if !text.isEmpty {
                networkManager.getMessageForTopic(text)
                textField.text = ""
            }
        }
        //updateTable()
    }
    
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        let window = UIApplication.shared.keyWindow!
        var view = AddMessageView.instanceFromNib()
        view.delegate = self
        view.frame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)
        window.addSubview(view)
        self.textField.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
    }
    //MARK:- Private methods
    fileprivate func getNextIndex() -> Int {
        if tableData.count > 0 {
            let keys = Array(tableData.keys)
            var sortedKeys = keys.sorted()
            
            return sortedKeys.popLast()! + 1
        }
        return 1
    }
    fileprivate func updateTable() {
        tableView.reloadData()
    }
    
    fileprivate func configNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

//MARK:- TextField Delegates
extension ViewController: UITextFieldDelegate {
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
            sendButton.isEnabled = true
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y += keyboardSize.height
            sendButton.isEnabled = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() 
        return true
    }
}

//MARK:- Table view delegate and datasource
extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        let rowPlusOne = row + 1

        let message = tableData[rowPlusOne]
        
        let sendCell: RequestMessage = tableView.dequeueReusableCell(withIdentifier: "RequestMessage") as! RequestMessage
       
        let responseCell: ResponseMessage = tableView.dequeueReusableCell(withIdentifier: "ResponseMessage") as! ResponseMessage
        responseCell.message.numberOfLines = 0

        //Response cell
        
        
        if let fullMessage = message as? Message {
            responseCell.topic.text = fullMessage.topic
            responseCell.message.text = "\n\(fullMessage.message)\n"
            responseCell.email.text = fullMessage.email
            return responseCell
        }
        sendCell.topicRequested.text = message as? String
        return sendCell
    }
}

extension ViewController: NetworgMangerDelegate {
    func didGetInfo(_ messages: [Message]) {
        
        for message in messages {
            let index = getNextIndex()
            tableData[index] = message
        }
        updateTable()
    }
    
    func postMessage(_ message: Message) {
        tableData = [:]
        index = 1
        updateTable()
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients([message.email])
        composeVC.setSubject("This is a Notification Message")
        composeVC.setMessageBody(message.message, isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
}

extension ViewController: AddMessageViewDelegate {
    func didFinishView() {
        configNotifications()
    }
}

extension ViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}

