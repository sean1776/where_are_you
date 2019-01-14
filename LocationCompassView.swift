//
//  LocationCompassView.swift
//  DogeChat
//
//  Created by tsousean on 2018/9/13.
//  Copyright © 2018 Luke Parham. All rights reserved.
//

import UIKit
import MapKit

protocol LocationCompassDelegate {
  func broadcastingLocation(gpsLocation: String)
}

class LocationCompassView: UIView, CLLocationManagerDelegate {
  var delegate: LocationCompassDelegate?
  
  let compassView = CompassView()
  let distanceLabel = Label()

  var broadcastingTimer: Timer?
  var updatingTimer: Timer?
  var lastLocation = CLLocation()
  var destLocation = CLLocation()
  var destDirection = CGFloat()
  let managerHolder = ManagerHolder()
  var locationManager: CLLocationManager {
    return self.managerHolder.locman
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    //backgroundColor = ColorPalettes.blueberryBlue
    compassView.setColor(UIColor.white)
    
    distanceLabel.text = "distance"
    distanceLabel.textAlignment = .center
    distanceLabel.textColor = UIColor.white
    //distanceLabel.font = UIFont(name: "Inconsolata-Regular", size: bounds.size.width/4.0)
    
    locationManager.delegate = self
    managerHolder.checkForLocationAccess(always: false) {
      self.locationManager.startUpdatingHeading()
      self.locationManager.startUpdatingLocation()
      self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    addSubview(compassView)
    addSubview(distanceLabel)
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      self.managerHolder.doThisWhenAuthorized?()
      self.managerHolder.doThisWhenAuthorized = nil
    default: break
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let size = bounds.size
    compassView.bounds = CGRect(x: 0, y: 0, width: size.width/2.0, height: size.width/2.0)
    distanceLabel.bounds = CGRect(x: 0, y: 0, width: size.width/2.0, height: size.width/4.0)
    
    compassView.center = CGPoint(x: size.width/2.0, y: size.height/3.0)
    distanceLabel.center = CGPoint(x: size.width/2.0, y: size.height*5.0/8.0)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setColor(_ color: UIColor) {
    compassView.setColor(color)
    distanceLabel.textColor = color
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let currentLocation = locations.last else { return }
    lastLocation = currentLocation
    self.rotateCompassView()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    let lastestHeading = CGFloat(newHeading.trueHeading).toRadians // convert from degrees to radians
    let lastestBearing = lastLocation.bearingToLocationRadian(destLocation)
    destDirection = lastestBearing - lastestHeading
    self.rotateCompassView()
  }
  
  func startBroadcasting() {
    if let delegate = delegate {
      broadcastingTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {_ in
        delegate.broadcastingLocation(gpsLocation: "locationMessage`|\(self.lastLocation.coordinate.latitude),\(self.lastLocation.coordinate.longitude)")
      }
    }
  }
  
  func stopBroadcasting() {
    broadcastingTimer?.invalidate()
  }
  
  func startUpdating() {
    updatingTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {_ in
      self.rotateCompassView()
    }
  }
  
  func stopUpdating() {
    locationManager.stopUpdatingHeading()
    locationManager.stopUpdatingLocation()
    updatingTimer?.invalidate()
  }
  
  func receivedLocation(_ message: Message) {
    switch message.messageSender {
    case .someoneElse:
      guard let latitude = Double(message.message.components(separatedBy: ",").first!) else { break }
      guard let longitude = Double(message.message.components(separatedBy: ",").last!) else { break }
      destLocation = CLLocation(latitude: latitude, longitude: longitude)      
    case .ourself:
      break
    }
  }
  
  private func rotateCompassView() {
    UIView.animate(withDuration: 0.5) {
      self.compassView.transform = CGAffineTransform(rotationAngle: self.destDirection); //print("destDirection: \(self.destDirection)")
      var distance = Double(Int(self.lastLocation.distance(from: self.destLocation))); //print("distance: \(distance)")
      var unit = "m"
      if distance > 1000 {
        distance /= 1000
        distance = Double(round(10 * distance) / 10) //get precision of one decimal
        unit = "km"
      }
      
      self.distanceLabel.text = (distance > 1000) ? "" : "\(distance)\(unit)"
    }
  }
}

extension CGFloat {
  var toRadians: CGFloat { return self * .pi / 180 }
  var toDegrees: CGFloat { return self * 180 / .pi }
}

extension CLLocationDegrees {
  var toRadians: CLLocationDegrees { return self * .pi / 180 }
}

public extension CLLocation {
  func bearingToLocationRadian(_ destinationLocation: CLLocation) -> CGFloat {
    
    let lat1 = self.coordinate.latitude.toRadians
    let lon1 = self.coordinate.longitude.toRadians
    
    let lat2 = destinationLocation.coordinate.latitude.toRadians
    let lon2 = destinationLocation.coordinate.longitude.toRadians
    
    let dLon = lon2 - lon1
    
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    let radiansBearing = atan2(y, x)
    
    return CGFloat(radiansBearing)
  }
  
  func bearingToLocationDegrees(destinationLocation: CLLocation) -> CGFloat {
    return bearingToLocationRadian(destinationLocation).toDegrees
  }
}
