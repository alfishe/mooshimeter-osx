//
//  DeviceContext.swift
//  mooshimeter-osx
//
//  Created by Dev on 3/26/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Foundation

class DeviceEvent
{
  let UUID: String
  let payload: AnyObject?
  
  init(UUID: String, payload: AnyObject?)
  {
    self.UUID = UUID
    self.payload = payload
  }
}


class DeviceStateChangeEvent
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

struct DeviceValueChange
{
  let commandType: DeviceCommandType
  let resultType: ResultType
  let value: AnyObject?
}

class DeviceContext
{
  weak var device: Device?
  var commandStates: [DeviceCommandType: AnyObject?] = [:]
  
  // State variables
  var calculatedCRC32: UInt32 = 0
  var inStreamingMode: Bool = false
  
  
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
    if value == nil
    {
        print("Unable to set empty value for " + command.description)
        return
    }
    
    commandStates[command] = value
    
    // Notify about state value changed
    let valueTuple = value as! (type: ResultType, value: AnyObject)
    let changeObject = DeviceStateChangeEvent(
      UUID: (self.device?.UUID)!,
      commandType: command,
      valueType: valueTuple.type,
      value: valueTuple.value)
    
    // Broadcast generic KVO notification
    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_DEVICE_STATE_VALUE_CHANGED), object: changeObject)
    
    // Generate specific events (if conditions detected)
    routeEvent(changeObject)
  }
  
  /*
   * Generates more specific events based on generic KVO changes
   */
  func routeEvent(_ changeObject: DeviceStateChangeEvent)
  {
    let commandType = changeObject.commandType
    let valueType = changeObject.valueType
    let value = changeObject.value
    let deviceEvent = DeviceEvent(UUID: changeObject.UUID, payload: changeObject)
    
    switch commandType
    {
      case .Tree:
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_ADMINTREE_RECEIVED), object: deviceEvent)
      case .CRC32:
        let crc32Value = changeObject.value as! UInt32
        if crc32Value == self.calculatedCRC32
        {
          NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_DEVICE_HANDSHAKE_PASSED), object: deviceEvent)
        }
      case .SamplingTrigger:
        let samplingTriggerModeByte = changeObject.value as! UInt8
        let samplingTriggerMode = SamplingTriggerType(rawValue: samplingTriggerModeByte)
      
        if samplingTriggerMode == SamplingTriggerType.Continuous
        {
          self.inStreamingMode = true
        }
        else
        {
            self.inStreamingMode = false
        }
      case .Channel1Value:
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_CHANNEL1_VALUE_CHANGED), object: deviceEvent)
      case .Channel2Value:
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_CHANNEL2_VALUE_CHANGED), object: deviceEvent)
      case .Channel1Mapping:
        break
      case .Channel2Mapping:
        break
      case .Channel1Buf:
        break
      case .Channel2Buf:
        break
      default:
        break
    }
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
