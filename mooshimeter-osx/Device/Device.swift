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
  class func isBLEDeviceSupported() -> Bool
  {
    let result = false

    return result
  }

  //MARK: -
  //MARK: Initialization and status methods

  init(peripheral: CBPeripheral)
  {
    self.peripheral = peripheral
    self.UUID = peripheral.identifier.UUIDString
  }

  func isConnected() -> Bool
  {
    var result = false

    if peripheral.state == .Connected
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

  func setTime(time: Double)
  {

  }

  //MARK: -
  //MARK: Sample rate methods
}
