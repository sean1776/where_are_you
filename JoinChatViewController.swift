/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class JoinChatViewController: UIViewController {
  let chatRoom = ChatRoom()
  let logoImageView = UIImageView()
  let shadowView = UIView() // Is thie useful? Ans: used in Layout.swift
  let nameTextField = TextField()
  var anonymousId = "XXXX"
  let anonymousIdLabel = Label()
  let confirmButton = UIButton()  
 
  
  
  @objc func confirmTapped() {
    if confirmButton.titleLabel?.text == "Try Again" {
      UIView.animate(withDuration: 0.25) {
        self.confirmButton.backgroundColor = ColorPalettes.sandYellow
      }
      UIView.animate(withDuration: 0.25) {
        self.confirmButton.backgroundColor = ColorPalettes.gardenGrass
      }
      chatRoom.stopChatSession()
      chatRoom.setupNetworkCommunication()
      chatRoom.joinChat(username: "newUser")
      
    } else {
      let chatRoomVC = ChatRoomViewController()
      chatRoomVC.chatRoom = chatRoom
      chatRoomVC.username = anonymousId
      navigationController?.pushViewController(chatRoomVC, animated: true)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("welcome to JoinChatViewController!!...1")
    anonymousIdLabel.text = "Too many people, try later."
    confirmButton.setTitle("Try Again", for: .normal)
    
    chatRoom.delegate = self
    chatRoom.setupNetworkCommunication()
    
    chatRoom.joinChat(username: "newUser")
    confirmButton.addTarget(self, action: #selector(JoinChatViewController.confirmTapped), for: .touchUpInside)
    //print("finished viewWillAppear")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("Leaving JoinChatViewController...")    
  }
}

extension JoinChatViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let chatRoomVC = ChatRoomViewController()
    if let username = nameTextField.text {
      chatRoomVC.username = username
    }
    navigationController?.pushViewController(chatRoomVC, animated: true)
    return true
  }
}

class TextField: UITextField {
  
  let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 8);
  
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }
  
  override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }
  
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }
}

extension JoinChatViewController: ChatRoomDelegate {
  func receivedMessage(message: Message) {
  }
  
  func receivedAnonymousId(anonymousId: String) {
    print("in JoinChatViewController: receivedConnectionError()")
    self.anonymousId = anonymousId
    anonymousIdLabel.text = "anonymousID: " + anonymousId
    confirmButton.setTitle("Confirm", for: .normal)
  }
  
  func receivedConnectionError() {
    print("in JoinChatViewController: receivedConnectionError()")
    anonymousIdLabel.text = "Lock the screen deactivates the App"
    chatRoom.username = ""
    confirmButton.setTitle("Try Again", for: .normal)
  }
}

