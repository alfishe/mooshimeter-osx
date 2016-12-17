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
