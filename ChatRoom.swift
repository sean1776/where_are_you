//
//  ChatRoom.swift
//  DogeChat
//
//  Created by tsousean on 2018/9/9.
//  Copyright © 2018 Luke Parham. All rights reserved.
//

import UIKit

protocol ChatRoomDelegate: class {
    func receivedMessage(message: Message)
    func receivedAnonymousId(anonymousId: String)
    func receivedConnectionError()    
}


class ChatRoom: NSObject {
    weak var delegate: ChatRoomDelegate?

    var inputStream: InputStream!
    var outputStream: OutputStream!
    var username = ""
    let maxReadLength = 4096
    
    func setupNetworkCommunication() {
      var readStream: Unmanaged<CFReadStream>?
      var writeStream: Unmanaged<CFWriteStream>?
      
    

      print("connecting...2")
      // mac mini server IP: 122.116.157.21,
      // aws server EIP: 18.188.97.220
      CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                         "18.188.97.220" as CFString,
                                         5000,
                                         &readStream,
                                         &writeStream)
    
      print("building input output stream...3")
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: RunLoop.Mode.common)
        outputStream.schedule(in: .current, forMode: RunLoop.Mode.common)

        inputStream.open()
        outputStream.open()
      print("finished building input output stream...4")
    }
  
    func reOpenInputOutputStream() {
      inputStream.open()
      outputStream.open()
    }
  
    func joinChat(username: String) {
      print("joining ChatRoom... 5")
      let data = "iam:\(username)".data(using: .ascii)!
      //self.username = username
      _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
    }
  
    func getAnonymousId() -> String {
      if self.username == "" {
        return "XXXX"
      } else {
        return self.username
      }
    }
}

extension ChatRoom: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("new message received (hasBytesAvailable)")
            readAvailableBytes(stream: aStream as! InputStream)

        case Stream.Event.endEncountered:
            print("new message received (server closed itself)")
            stopChatSession()

        case Stream.Event.errorOccurred:
            print("error occurred, socket disconnect......")
            delegate?.receivedConnectionError()
          
        case Stream.Event.hasSpaceAvailable:
            print("has space available")
          
        case Stream.Event.openCompleted:
            print("open completed..6")
            
          
        default:
            print("some other event...")
            break
        }
    }

    private func readAvailableBytes(stream: InputStream) {
        //print("readAvailableBytes(")
      print("readAvailableBytes: //1")
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        
      print("readAvailableBytes: //2")
        while stream.hasBytesAvailable {
            //3
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            
            //4
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError {
                    break
                }
            }
            
          print("readAvailableBytes: Construct the Message object")
            if let message = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
              print("readAvailableBytes: Notify interested parties")
                delegate?.receivedMessage(message: message)

            }
        }
    }
    
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> Message? {
      print("processedMessageString")
      //1
      guard let stringArray = String(bytesNoCopy: buffer,
                                     length: length,
                                     encoding: .ascii,
                                     freeWhenDone: true)?.components(separatedBy: ":"),
          let name = stringArray.first,
          var message = stringArray.last else {
              return nil
      }
      print("across guard")
      // Right after the chatRoom.setupNetworkCommunication(), server reply the first message: "3678 has joined"
      // We use this message to set as the anonymousId(username), and only set it once
      print("name: \(name), message: \(message)")
      let words = name.components(separatedBy: " ")
      if words.count >= 2 && words[words.count - 2] == "has" && words[words.count - 1] == "joined\n" {
        print("in first time condition")
        if self.username == "" {
          self.username = words[0]
          print("self.username == \(self.username) has set the first time")
          delegate?.receivedAnonymousId(anonymousId: self.username)
        } else {
          print("self.username == \(self.username) has set in advance")
        }
      }
      //2
      let messageSender:MessageSender = (name == self.username) ? .ourself : .someoneElse // better if its logic based on a unique token
    
      //3
      let messageType:MessageType = (message.components(separatedBy: "`|").first! == "locationMessage") ? .gpsLocation : .text
      if messageType == .gpsLocation { message =  message.components(separatedBy: "`|").last! }
    
      return Message(message: message, messageSender: messageSender, username: name, messageType: messageType)
    }

    func sendMessage(message: String) {
        let data = "msg:\(message)".data(using: .ascii)!
        print("sending message...")
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
    }

    func stopChatSession() {
        inputStream.close()
        outputStream.close()
    }

}
