//
//  StatisticsManager.swift
//  mooshimeter-osx
//
//  Created by Dev on 5/17/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Foundation

class StatisticsManager: NSObject
{
  static let sharedInstance = StatisticsManager()
  
  

  override init()
  {
    super.init()
    
    // Subscribe for notifications about device disconnection from BLEManager
    //NotificationCenter.default.addObserver(self, selector: #selector(self.deviceDisconnected), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_DEVICE_DISCONNECTED), object: nil)
  }
  
  deinit
  {
    // Unsubscribe from all notifications
    NotificationCenter.default.removeObserver(self)
  }
}

