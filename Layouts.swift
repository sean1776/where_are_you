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
import GoogleMobileAds
import UIKit

extension ChatRoomViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    
    //Looks for single or multiple taps.
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatRoomViewController.dismissKeyboard))
    view.addGestureRecognizer(tap)
    
    trackTextField.addTarget(self, action: #selector(ChatRoomViewController.idTrackerHasSet), for: UIControl.Event.editingChanged)
    
    loadViews()
    
    // In this case, we instantiate the banner with desired ad size.
    // (https://developers.google.com/admob/ios/banner?hl=en-GB)
    bannerView = GADBannerView(adSize: kGADAdSizeBanner)
    addBannerViewToView(bannerView)
    bannerView.adUnitID = "ca-app-pub-3280046000807573/6546206211"
    bannerView.rootViewController = self
    bannerView.load(GADRequest())
  }
  
  @objc func idTrackerHasSet() {
    //print("idTracker: \(trackTextField.text)")
    self.trackname = trackTextField.text ?? ""
  }
  
  //Calls this function when the tap is recognized.
  @objc func dismissKeyboard() {
    //Causes the view (or one of its embedded text fields) to resign the first responder status.
    view.endEditing(true)
  }
  
  func keyboardWillChange(notification: NSNotification) {
    if let userInfo = notification.userInfo {
      let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue // phone keyboard panel frame
      let messageBarHeight = self.messageInputBar.bounds.size.height
      let point = CGPoint(x: self.messageInputBar.center.x, y: endFrame.origin.y - messageBarHeight/2.0)
      let inset = UIEdgeInsets(top: 0, left: 0, bottom: endFrame.size.height, right: 0)
      UIView.animate(withDuration: 0.25) {
        self.messageInputBar.center = point
        self.tableView.contentInset = inset
      }
    }
  }
  func loadViews() {
    navigationItem.title = "anonymousID: \(username)"
    navigationItem.backBarButtonItem?.title = "Leave"
    navigationItem.hidesBackButton = true
    
    //view.backgroundColor = UIColor(red: 24/255, green: 180/255, blue: 128/255, alpha: 1.0)
    view.backgroundColor = UIColor(red: 24/255, green: 180/255, blue: 128/255, alpha: 1.0)
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
    
    messageInputBar.delegate = self
    
    trackTextField.placeholder = "Friend's 4-digit ID"
    trackTextField.backgroundColor = .white
    trackTextField.layer.cornerRadius = 4
    trackTextField.textAlignment = .center
    trackTextField.keyboardType = .decimalPad
    
    locationCompassView.setColor(UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0))
    
    //view.addSubview(tableView)
    //view.addSubview(messageInputBar)
    view.addSubview(locationCompassView)
    view.addSubview(trackTextField)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let messageBarHeight:CGFloat = 60.0
    let textFieldHeight: CGFloat = 35.0
    let size = view.bounds.size
    
    tableView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height - messageBarHeight)
    messageInputBar.frame = CGRect(x: 0, y: size.height - messageBarHeight, width: size.width, height: messageBarHeight)
    locationCompassView.frame = CGRect(x: 0, y: 60.0, width: size.width, height: size.width)
    
    trackTextField.bounds = CGRect(x: 0, y: 0, width: size.width/2.0, height: textFieldHeight)
    trackTextField.center = CGPoint(x: size.width/2.0, y: locationCompassView.frame.height-25.0)
  }
}

extension JoinChatViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadViews()
    
    view.addSubview(shadowView)
    view.addSubview(logoImageView)
    //view.addSubview(nameTextField)
    view.addSubview(anonymousIdLabel)
    view.addSubview(confirmButton)
  }

  func loadViews() {  // set Views' size, color, corner, title, image
    view.backgroundColor = UIColor(red: 24/255, green: 180/255, blue: 128/255, alpha: 1.0)
    navigationItem.title = "Anonymous Finder"
    
    logoImageView.image = UIImage(named: "compass")
    logoImageView.layer.cornerRadius = 4
    logoImageView.clipsToBounds = true
    
    /*
    shadowView.layer.shadowColor = UIColor.black.cgColor
    shadowView.layer.shadowRadius = 5
    shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
    shadowView.layer.shadowOpacity = 0.5
    shadowView.backgroundColor = UIColor(red: 24/255, green: 180/255, blue: 128/255, alpha: 1.0)
    */
    
    nameTextField.placeholder = "What's your friend's 4-digit ID?"
    nameTextField.backgroundColor = .white
    nameTextField.layer.cornerRadius = 4
    nameTextField.delegate = self
        
    anonymousIdLabel.textAlignment = .center
    anonymousIdLabel.textColor = .white
        
    confirmButton.layer.cornerRadius = 4
    confirmButton.backgroundColor = ColorPalettes.gardenGrass    
    
    
    let backItem = UIBarButtonItem()
    backItem.title = "Leave"
    navigationItem.backBarButtonItem = backItem
    navigationItem.hidesBackButton = true
  }
  
  override func viewDidLayoutSubviews() { // set layout (viewss bounds & center)
    super.viewDidLayoutSubviews()
    
    logoImageView.bounds = CGRect(x: 0, y: 0, width: 180, height: 180)
    logoImageView.center = CGPoint(x: view.bounds.size.width/2.0, y: logoImageView.bounds.size.height/2.0 + view.bounds.size.height/4)
    
    shadowView.frame = logoImageView.frame
    
    nameTextField.bounds = CGRect(x: 0, y: 0, width: view.bounds.size.width - 40, height: 44)
    nameTextField.center = CGPoint(x: view.bounds.size.width/2.0, y: logoImageView.center.y + logoImageView.bounds.size.height/2.0 + 20 + 22)
    
    anonymousIdLabel.bounds = CGRect(x: 0, y: 0, width: view.bounds.size.width - 40, height: 44)
    anonymousIdLabel.center = CGPoint(x: view.bounds.size.width/2.0, y: logoImageView.center.y + logoImageView.bounds.size.height/2.0 + 20 + 22)
    
    confirmButton.bounds = CGRect(x: 0, y: 0, width: logoImageView.bounds.width, height: 44)
    confirmButton.center = CGPoint(x: view.bounds.size.width/2.0, y: anonymousIdLabel.center.y + anonymousIdLabel.bounds.size.height/2.0 + 20 + 22)
  }
}

extension MessageTableViewCell {
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if isJoinMessage() {
      layoutForJoinMessage()
    } else {
      messageLabel.font = UIFont(name: "Helvetica", size: 17) //UIFont.systemFont(ofSize: 17)
      messageLabel.textColor = .white
      
      let size = messageLabel.sizeThatFits(CGSize(width: 2*(bounds.size.width/3), height: CGFloat.greatestFiniteMagnitude))
      messageLabel.frame = CGRect(x: 0, y: 0, width: size.width + 32, height: size.height + 16)
      
      if messageSender == .ourself {
        nameLabel.isHidden = true
        
        messageLabel.center = CGPoint(x: bounds.size.width - messageLabel.bounds.size.width/2.0 - 16, y: bounds.size.height/2.0)
        messageLabel.backgroundColor = UIColor(red: 24/255, green: 180/255, blue: 128/255, alpha: 1.0)
      } else {
        nameLabel.isHidden = false
        nameLabel.sizeToFit()
        nameLabel.center = CGPoint(x: nameLabel.bounds.size.width/2.0 + 16 + 4, y: nameLabel.bounds.size.height/2.0 + 4)
        
        messageLabel.center = CGPoint(x: messageLabel.bounds.size.width/2.0 + 16, y: messageLabel.bounds.size.height/2.0 + nameLabel.bounds.size.height + 8)
        messageLabel.backgroundColor = .lightGray
      }
    }
    
    messageLabel.layer.cornerRadius = min(messageLabel.bounds.size.height/2.0, 20)
  }
  
  func layoutForJoinMessage() {
    messageLabel.font = UIFont.systemFont(ofSize: 10)
    messageLabel.textColor = .lightGray
    messageLabel.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
    
    let size = messageLabel.sizeThatFits(CGSize(width: 2*(bounds.size.width/3), height: CGFloat.greatestFiniteMagnitude))
    messageLabel.frame = CGRect(x: 0, y: 0, width: size.width + 32, height: size.height + 16)
    messageLabel.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2.0)
  }
  
  func isJoinMessage() -> Bool {
    if let words = messageLabel.text?.components(separatedBy: " ") {
      if words.count >= 2 && words[words.count - 2] == "has" && words[words.count - 1] == "joined" {
        return true
      }
    }
    
    
    return false
  }
}
