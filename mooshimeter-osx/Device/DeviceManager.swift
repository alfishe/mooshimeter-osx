//
// Created by Dev on 8/27/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import Foundation

class DeviceManager
{
  static let sharedInstance = DeviceManager()

  var devices = [String: Device]()
  var devicesReverse = [Device: String]()

  func count() -> Int
  {
    let result: Int = devices.count
    
    return result
  }
  
  func getMeterForUUID(uuid: String) -> Device?
  {
    let result: Device? = self.devices[uuid]

    return result
  }

  func addMeter(device: Device)
  {
    if self.devicesReverse[device] == nil
    {
      let deviceUUID: String = device.UUID
      self.devices[deviceUUID] = device
      self.devicesReverse[device] = deviceUUID
    }
  }

  func removeMeter(device: Device)
  {
    let deviceUUID: String? = self.devicesReverse[device]

    if deviceUUID != nil
    {
      devices.removeValueForKey(deviceUUID!)
      devicesReverse.removeValueForKey(device)
    }
  }
}
