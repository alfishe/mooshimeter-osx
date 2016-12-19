//
// Created by Dev on 8/27/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import Foundation
import CoreBluetooth

class Device: NSObject
{
  let peripheral: CBPeripheral
  let UUID: String
  
  var readCharacteristic: CBCharacteristic?
  var writeCharacteristic: CBCharacteristic?
  
  var deviceReady = false

  //MARK: -
  //MARK: Class methods
  class func isDeviceSupported(_ version: UInt32) -> Bool
  {
    var result = false

    // Only versions after ... supported
    if version >= 1454355414
    {
      result = true
    }

    return result
  }

  //MARK: -
  //MARK: Initialization and status methods

  init(peripheral: CBPeripheral)
  {
    self.peripheral = peripheral
    self.UUID = peripheral.identifier.uuidString
  }

  func isConnected() -> Bool
  {
    var result = false

    if peripheral.state == .connected
    {
      result = true
    }

    return result
  }
  
  func setCharacteristics(read: CBCharacteristic, write: CBCharacteristic)
  {
    self.readCharacteristic = read
    self.writeCharacteristic = write
    
    if self.isConnected()
    {
      self.deviceReady = true
      
      // Notify that device is fully initialized and ready
      NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_DEVICE_READY), object: self)
    }
  }

  func isStreaming() -> Bool
  {
    let result = false

    return result
  }

  //MARK: -
  //MARK: Time methods
  func getTime() -> Double
  {
    let result: Double = 0.0

    return result
  }

  func setTime(_ time: Double)
  {

  }

  //MARK: -
  //MARK: Sample rate methods
}
