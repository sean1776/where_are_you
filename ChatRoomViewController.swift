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
import GoogleMobileAds


class ChatRoomViewController: UIViewController {
  var chatRoom  = ChatRoom()
  let tableView = UITableView()
  let messageInputBar = MessageInputView()
  let locationCompassView = LocationCompassView()
  let trackTextField = TextField()
  
  var messages = [Message]()
  
  var username = "" // username is set by JoinChatViewController
  var trackname = ""

  // Mobile Ads SDK(iOS) https://developers.google.com/admob/ios/banner?hl=en-GB
  var bannerView: GADBannerView!  
  func addBannerViewToView(_ bannerView: GADBannerView) {
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bannerView)
    view.addConstraints(
      [NSLayoutConstraint(item: bannerView,
                          attribute: .bottom,
                          relatedBy: .equal,
                          toItem: bottomLayoutGuide,
                          attribute: .top,
                          multiplier: 1,
                          constant: 0),
       NSLayoutConstraint(item: bannerView,
                          attribute: .centerX,
                          relatedBy: .equal,
                          toItem: view,
                          attribute: .centerX,
                          multiplier: 1,
                          constant: 0)
      ])
  }
  
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //chatRoom.setupNetworkCommunication()
    //chatRoom.joinChat(username: username)
    chatRoom.delegate = self
    
    locationCompassView.delegate = self
    locationCompassView.startBroadcasting()
    locationCompassView.startUpdating()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopOperation()
  }
  
  func stopOperation() {
    chatRoom.stopChatSession()
    locationCompassView.stopBroadcasting()
    locationCompassView.stopUpdating()
  }
}

//MARK - Message Input Bar
extension ChatRoomViewController: MessageInputDelegate {
  func sendWasTapped(message: String) {
    chatRoom.sendMessage(message: message)
  }
}

extension ChatRoomViewController: LocationCompassDelegate {
  func broadcastingLocation(gpsLocation: String) {    
    chatRoom.sendMessage(message: gpsLocation)
  }
}

extension ChatRoomViewController: ChatRoomDelegate {
  func receivedMessage(message: Message) {
    switch message.messageType {
    case .text:
      insertNewMessageCell(message)
    case .gpsLocation:
      if message.senderUsername == trackname {
        locationCompassView.receivedLocation(message)
      }      
    }
  }
  
  func receivedAnonymousId(anonymousId: String) {
    self.username = anonymousId    
  }
  
  func receivedConnectionError() {
    stopOperation()
    let alert = UIAlertController(
      title: "Did you lock the screen?",
      message: "Lock the screen deactivates Anonymous Finder.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "Reconnect & renew id", style: .default){ action in
      let joinChatVC = JoinChatViewController()
      self.navigationController?.pushViewController(joinChatVC, animated: true)
    })
    self.present(alert, animated: true)
  }
}

