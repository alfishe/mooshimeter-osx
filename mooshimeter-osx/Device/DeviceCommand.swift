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
  
  /*
   * Return max limit allowed for current command type value. For enums - max enumeration index value
   */
  class func getCommandPayloadLimit(commandType: DeviceCommandType) -> UInt8?
  {
    var result: UInt8? = nil
    
    switch commandType
    {
      case .CRC32:
        break
      case .Tree:
        break
      case .Diagnostic:
        break
      case .PCBVersion:
        break
      case .Name:
        break
      case .TimeUTC:
        break
      case .TimeUTCms:
        break
      case .Battery:
        break
      case .Reboot:
        result = RebootType.Shipping.rawValue
        break
      case .SamplingRate:
        result = SamplingRateType.Freq8000Hz.rawValue
      break
      case .SamplingDepth:
        result = SamplingDepthType.Depth256.rawValue
        break
      case .SamplingTrigger:
        result = SamplingTriggerType.Continuous.rawValue
      break
      case .LoggingOn:
        break
      case .LoggingInterval:
        break
      case .LoggingStatus:
        break
      case .LoggingPollDir:
        break
      case .LoggingInfoIndex:
        break
      case .LoggingInfoEndTime:
        break
      case .LoggingInfoBytesNum:
        break
      case .LoggingStreamIndex:
        break
      case .LoggingStreamOffset:
        break
      case .LoggingStreamData:
        break
      case .Channel1Mapping:
        result = Channel1MappingType.Shared.rawValue
        break
      case .Channel1Range:
        break
      case .Channel1Analysis:
        result = Channel1AnalysisType.Buffer.rawValue
        break
      case .Channel1Value:
        break
      case .Channel1Offset:
        break
      case .Channel1Buf:
        break
      case .Channel1BufBPS:
        break
      case .Channel1BufLSBNative:
        break
      case .Channel2Mapping:
        result = Channel2MappingType.Shared.rawValue
        break
      case .Channel2Range:
        break
      case .Channel2Analysis:
        result = Channel2AnalysisType.Buffer.rawValue
        break
      case .Channel2Value:
        break
      case .Channel2Offset:
        break
      case .Channel2Buf:
        break
      case .Channel2BufBPS:
        break
      case .Channel2BufLSBNative:
        break
      case .Shared:
        result = SharedModeType.Diode.rawValue
        break
      case .RealPwr:
        break
    }
    
    return result
  }
  
  class func getCommandPayload(commandType: DeviceCommandType, value: AnyObject) -> [UInt8]
  {
    var result = [UInt8]()
    
    let resultType = getResultTypeByCommand(command: commandType.rawValue)
    
    switch resultType
    {
      case .chooser:
        if (value as? DeviceChooser) != nil
        {
          let chooserValue: UInt8? = getChooserValueForCommand(commandType: commandType, value: value as! DeviceChooser)
          if chooserValue != nil
          {
            result.append(chooserValue!)
          }
          else
          {
            print("Unable to serialize chooser")
          }
        }
        break
      case .val_U8:
        print("Not implemented")
        break
      case .val_U16:
        print("Not implemented")
        break
      case .val_U32:
        print("Not implemented")
        break
      case .val_S8:
        print("Not implemented")
        break
      case .val_S16:
        print("Not implemented")
        break
      case .val_S32:
        print("Not implemented")
        break
      case .val_STR:
        print("Not implemented")
        break
      case .val_BIN:
        print("Not implemented")
        break
      case .val_FLT:
        print("Not implemented")
        break
      default:
        break
    }
    
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
        result = .val_BIN
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
        print("Unknown command code %d", command)
        break
    }
    
    return result
  }
  
  class func getResultSizeType(_ resultType: ResultType) -> Int
  {
    var result: Int = 0
    
    switch resultType
    {
      case .plain:
        result = 0
      case .link:
        result = 0
      case .chooser:
        result = 1
      case .val_U8:
        result = 1
      case .val_U16:
        result = 2
      case .val_U32:
        result = 4
      case .val_S8:
        result = 1
      case .val_S16:
        result = 2
      case .val_S32:
        result = 4
      case .val_STR:
        result = Constants.DEVICE_COMMAND_PAYLOAD_VARIABLE_LEN
      case .val_BIN:
        result = Constants.DEVICE_COMMAND_PAYLOAD_VARIABLE_LEN
      case .val_FLT:
        result = 4
      default:
        break
    }
    
    return result
  }
  
  class func getPacketCommandType(data: Data?) -> DeviceCommandType?
  {
    var result: DeviceCommandType? = nil
    
    if data != nil && data!.count >= 2
    {
      // Strip first byte from the packet (packet number)
      let payloadData = data!.subdata(in: 1..<data!.count)
      
      // Command type is located in the first byte of packet payload
      let commandTypeByte: UInt8 = payloadData.first!
      result = DeviceCommandType(rawValue: commandTypeByte)
    }
    
    return result
  }
  
  /**
   - parameters:
   - data: Packet data bytes
   */
  class func getPacketValue(data: Data?) -> (type: ResultType, value: AnyObject)?
  {
    var result: (type: ResultType, value: AnyObject)? = nil
    
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
        
        if value != nil
        {
          result = (valueType, value!)
        }
        else
        {
          print("Unable to parse value for %@", valueType)
        }
      }
    }
    
    return result
  }
  
  class func printValue(commandType: DeviceCommandType, valueTuple: (type: ResultType, value: AnyObject)?) -> String
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
          result = result + " " + printChooserValue(commandType: commandType, value: val)
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
    
    let commandType = getPacketCommandType(data: data)
    let valueTuple = getPacketValue(data: data)
    
    result = printValue(commandType: commandType!, valueTuple: valueTuple)
    
    return result
  }
  
  class func printChooserValue(commandType: DeviceCommandType, value: UInt8) -> String
  {
    var result: String = ""
    
    let limit = getCommandPayloadLimit(commandType: commandType)
    if limit != nil
    {
      if value > limit!
      {
        print("CommandType: \(commandType.description) has value: \(value), which is bigger than allowed limit: \(limit!)")
        return result
      }
    }
    
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
  
  //MARK: -
  //MARK: Send oriented commands
  class func getChooserValueForCommand(commandType: DeviceCommandType, value: DeviceChooser) -> UInt8?
  {
    var result: UInt8? = nil
    
    switch commandType
    {
      case .Reboot:
        result = (value as! RebootType).rawValue
      case .SamplingRate:
        result = (value as! SamplingRateType).rawValue
      case .SamplingDepth:
        result = (value as! SamplingDepthType).rawValue
      case .SamplingTrigger:
        result = (value as! SamplingTriggerType).rawValue
      case .Channel1Mapping:
        result = (value as! Channel1MappingType).rawValue
      case .Channel1Analysis:
        result = (value as! Channel1AnalysisType).rawValue
      case .Channel2Mapping:
        result = (value as! Channel2MappingType).rawValue
      case .Channel2Analysis:
        result = (value as! Channel2AnalysisType).rawValue
      case .Shared:
        result = (value as! SharedModeType).rawValue
      default:
        break
    }
    
    return result
  }
}



