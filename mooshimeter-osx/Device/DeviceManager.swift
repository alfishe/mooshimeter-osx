//
// Created by Dev on 8/27/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import Foundation

class DeviceManager: NSObject
{
  static let sharedInstance = DeviceManager()

  let bleManager = BLEManager.sharedInstance

  var devices = [String: Device]()
  var devicesReverse = [Device: String]()

  override init()
  {
    super.init()

    // Subscribe for notifications about device disconnection from BLEManager
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.deviceDisconnected), name: Constants.NOTIFICATION_DEVICE_DISCONNECTED, object: nil)
  }

  deinit
  {
    // Unsubscribe from all notifications
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func count() -> Int
  {
    let result: Int = devices.count
    
    return result
  }
  
  func getDeviceForUUID(uuid: String) -> Device?
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
      // Ensure that device disconnected properly
      if device.isConnected()
      {
        // Start disconnection (device will be removed only when disconnected
        bleManager.disconnectPeripheral(device.peripheral)
      }
      else
      {
        // Safe to remove immediately
        devices.removeValueForKey(deviceUUID!)
        devicesReverse.removeValueForKey(device)
      }
    }
  }

  func removeAll()
  {
    for device in self.devices.values
    {
      removeMeter(device)
    }
  }

  //MARK: -
  //MARK: Helper methods
  @objc
  private func deviceDisconnected(notification: NSNotification)
  {
    let device: Device? = notification.object as! Device?

    if device != nil
    {
      print("-> Device \(device!.UUID) disconnected")

      self.removeMeter(device!)
    }

    if self.count() == 0
    {
      print("-> All devices disconnected")

      // All devices disconnected, notify about it
      NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_ALL_DEVICES_DISCONNECTED, object: nil)
    }
  }
}
