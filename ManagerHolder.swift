//
//  ManagerHolder.swift
//  DogeChat
//
//  Created by tsousean on 2018/10/15.
//

import Foundation
import MapKit
import UIKit

class ManagerHolder {
  let locman = CLLocationManager()
  var doThisWhenAuthorized : (() -> ())?
  func checkForLocationAccess(always:Bool = false, andThen f: (()->())? = nil) {
    // no services? try to get alert
    guard CLLocationManager.locationServicesEnabled() else {
      self.locman.startUpdatingHeading()
      self.locman.startUpdatingLocation()
      self.locman.desiredAccuracy = kCLLocationAccuracyBestForNavigation
      return
    }
    let status = CLLocationManager.authorizationStatus()
    switch status {
    case .authorizedWhenInUse:
      if always { // try to step up
        self.doThisWhenAuthorized = f
        self.locman.requestAlwaysAuthorization()
      } else {
        f?()
      }
    case .authorizedAlways:
      f?()
    case .notDetermined:
      self.doThisWhenAuthorized = f
      always ? self.locman.requestAlwaysAuthorization() : self.locman.requestWhenInUseAuthorization()
    case .restricted:
      // do nothing
      break
    case .denied:
      // do nothing, or beg the user to authorize us in Settings
      break
    }
  }
}
