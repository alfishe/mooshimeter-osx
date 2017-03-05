//
//  DeviceCommand.swift
//  mooshimeter-osx
//
//  Created by Dev on 9/21/16.
//  Copyright © 2016 alfishe. All rights reserved.
//

import Foundation

class DeviceCommand: NSObject
{
  class func getReadCommandCode(type: DeviceCommandType) -> UInt8
  {
    let result: UInt8 = type.rawValue & 0x7F
  
    return result
  }
  
  class func getWriteCommandCode(type: DeviceCommandType) -> UInt8
  {
    let result: UInt8 = type.rawValue | 0x80
  
    return result
  }
  
  class func getResultTypeByCommand(command: UInt8) -> ResultType
  {
    var result: ResultType = .notset
    
    switch command
    {
      case 0:
        result = .val_U32
      case 1:
        result = .val_BIN
      case 2:
        result = .val_STR
      case 3:
        result = .val_U8
      case 4:
        result = .val_STR
      case 5:
        result = .val_U32
      case 6:
        result = .val_U16
      case 7:
        result = .val_FLT
      case 9:
        result = .chooser
      case 10:
        result = .chooser
      case 11:
        result = .chooser
      case 12:
        result = .val_U8
      case 13:
        result = .val_U16
      case 14:
        result = .val_U8
      case 15:
        result = .val_U8
      case 16:
        result = .val_U16
      case 17:
        result = .val_U32
      case 18:
        result = .val_U32
      case 19:
        result = .val_U16
      case 20:
        result = .val_U32
      case 21:
        result = .val_BIN
      case 22:
        result = .chooser
      case 23:
        result = .val_U8
      case 24:
        result = .chooser
      case 25:
        result = .val_FLT
      case 26:
        result = .val_FLT
      case 27:
        result = .val_BIN
      case 28:
        result = .val_U8
      case 29:
        result = .val_FLT
      case 30:
        result = .chooser
      case 31:
        result = .val_U8
      case 32:
        result = .chooser
      case 33:
        result = .val_FLT
      case 34:
        result = .val_FLT
      case 35:
        result = .val_BIN
      case 36:
        result = .val_U8
      case 37:
        result = .val_FLT
      case 38:
        result = .chooser
      case 39:
        result = .val_FLT
      default:
        break
    }
    
    return result
  }
  
  /**
   - parameters:
   - data: Packet data bytes
   */
  class func getPacketValue(data: Data?) -> (type: ResultType, value: AnyObject?)?
  {
    var result: (type: ResultType, value: AnyObject?)? = nil
    
    if data != nil && data!.count > 2
    {
      // Strip first byte from the packet (packet number)
      let payloadData = data!.subdata(in: 1..<data!.count)
      
      // Command type is located in the first byte of packet payload
      let commandTypeByte: UInt8 = payloadData.first!
      let commandType = DeviceCommandType(rawValue: commandTypeByte)
      
      if commandType != nil
      {
        var value: AnyObject? = nil
        
        // Resolve result value type based on command type
        let valueType = DeviceCommand.getResultTypeByCommand(command: commandType!.rawValue)
        let valueData = payloadData.subdata(in: 1..<payloadData.count)
        
        // Parse the value
        switch valueType
        {
          case .val_STR:
            if valueData.count >= 2
            {
              // First two bytes are string length
              let length: UInt16 = valueData.to(type: UInt16.self)
              if length > 0
              {
                let stringData = valueData.subdata(in: 2..<2 + Int(length))
                value = String(data: stringData, encoding: String.Encoding.utf8) as AnyObject?
              }
            }
          case .chooser:
            if valueData.count >= 1
            {
              value = valueData.to(type: UInt8.self) as AnyObject?
            }
          case .val_U8:
            if valueData.count >= 1
            {
              value = valueData.to(type: UInt8.self) as AnyObject?
            }
          case .val_U16:
            if valueData.count >= 2
            {
              value = valueData.to(type: UInt16.self) as AnyObject?
            }
          case .val_U32:
            if valueData.count >= 4
            {
              value = valueData.to(type: UInt32.self) as AnyObject?
            }
          case .val_S8:
            if valueData.count >= 1
            {
              value = valueData.to(type: Int8.self) as AnyObject?
            }
          case .val_S16:
            if valueData.count >= 2
            {
              value = valueData.to(type: Int16.self) as AnyObject?
            }
          case .val_S32:
            if valueData.count >= 4
            {
              value = valueData.to(type: Int32.self) as AnyObject?
            }
          case .val_FLT:
            if valueData.count >= 4
            {
              value = valueData.to(type: Float.self) as AnyObject?
            }
            break
          default:
            print("getPacketValue - unknown type: \(String(describing: valueType))")
            break
        }
        
        result = (valueType, value)
      }
    }
    
    return result
  }
  
  class func printValue(valueTuple: (type: ResultType, value: AnyObject?)?) -> String
  {
    var result: String = ""
    
    if valueTuple != nil
    {
      let type = valueTuple!.type
      let value = valueTuple!.value
      
      switch type
      {
        case .val_STR:
          let val: String = value as! String
          result = String(val)
        case .chooser:
          let val: UInt8 = value as! UInt8
          result = String(format: "0x%02x", val)
        case .val_U8:
          let val: UInt8 = value as! UInt8
          result = String(format: "0x%02x", val)
        case .val_U16:
          let val: UInt16 = value as! UInt16
          result = String(format: "0x%04x", val)
        case .val_U32:
          let val: UInt32 = value as! UInt32
          result = String(format: "0x%08x", val)
        case .val_FLT:
          let val: Float = value as! Float
          result = String(format: "%0.6f", val)
        default:
          break
      }
    }
    
    return result
  }
  
  class func printPacketValue(data: Data?) -> String
  {
    var result: String = ""
    
    let valueTuple = getPacketValue(data: data)
    
    result = printValue(valueTuple: valueTuple)
    
    return result
  }
  
  class func printChooserValue(commandType: DeviceCommandType, value: UInt8) -> String
  {
    var result: String = ""
    
    switch commandType
    {
      case .Reboot:
        result = (RebootType(rawValue: value)?.description)!
      case .SamplingRate:
        result = (SamplingRateType(rawValue: value)?.description)!
      case .SamplingDepth:
        result = (SamplingDepthType(rawValue: value)?.description)!
      case .SamplingTrigger:
        result = (SamplingTriggerType(rawValue: value)?.description)!
      case .Channel1Mapping:
        result = (Channel1MappingType(rawValue: value)?.description)!
      case .Channel1Analysis:
        result = (Channel1AnalysisType(rawValue: value)?.description)!
      case .Channel2Mapping:
        result = (Channel2MappingType(rawValue: value)?.description)!
      case .Channel2Analysis:
        result = (Channel2AnalysisType(rawValue: value)?.description)!
      case .Shared:
        result = (SharedModeType(rawValue: value)?.description)!
      default:
        result = "Chooser not implemented for CommandType: \(String(describing: commandType))"
        break
    }
    
    return result
  }
}


