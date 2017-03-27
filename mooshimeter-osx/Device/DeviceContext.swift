//
//  DeviceContext.swift
//  mooshimeter-osx
//
//  Created by Dev on 3/26/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Foundation

class DeviceStateChange
{
  let UUID: String
  let commandType: DeviceCommandType
  let valueType: ResultType
  let value: AnyObject?
  
  init(UUID: String, commandType: DeviceCommandType, valueType: ResultType, value: AnyObject?)
  {
    self.UUID = UUID
    self.commandType = commandType
    self.valueType = valueType
    self.value = value
  }
}

class DeviceContext
{
  private let device: Device
  
  private var calculatedCRC32: UInt32 = 0
  private var commandStates: [DeviceCommandType: AnyObject?] = [:]
  
  var adminTree:[UInt8]?
  
  init(device: Device)
  {
    self.device = device
  }
  
  func getValue(_ command: DeviceCommandType) -> AnyObject?
  {
    let result = commandStates[command]
    
    return result!
  }
  
  func setValue(_ command: DeviceCommandType, value: AnyObject?) -> Void
  {
    commandStates[command] = value
    
    // Notify about state value changed
    let valueTuple = value as! (valueType: ResultType, value: AnyObject)
    let changeObject = DeviceStateChange(
      UUID: self.device.UUID,
      commandType: command,
      valueType: valueTuple.valueType,
      value: valueTuple.value)
    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_DEVICE_STATE_VALUE_CHANGED), object: changeObject)
  }
  
  func getCalculatedCRC32() -> UInt32
  {
    let result = self.calculatedCRC32
    
    return result
  }
  
  func setCalculatedCRC32(value: UInt32)
  {
    self.calculatedCRC32 = value
  }
  
  
}
