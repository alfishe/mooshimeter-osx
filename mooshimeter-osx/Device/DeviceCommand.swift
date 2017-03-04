//
//  DeviceCommand.swift
//  mooshimeter-osx
//
//  Created by Dev on 9/21/16.
//  Copyright © 2016 alfishe. All rights reserved.
//

import Foundation

enum DeviceCommandType: UInt8
{
  case CRC32 = 0
  case Tree = 1
  case Diagnostic = 2
  case PCBVersion = 3
  case Name = 4
  case TimeUTC = 5
  case TimeUTCms = 6
  case Battery = 7
  case Reboot = 8
  case SamplingRate = 9
  case SamplingDepth = 10
  case SamplingTrigger = 11
  case LoggingOn = 12
  case LoggingInterval = 13
  case LoggingStatus = 14
  case LoggingPollDir = 15
  case LoggingInfoIndex = 16
  case LoggingInfoEndTime = 17
  case LoggingInfoBytesNum = 18
  case LoggingStreamIndex = 19
  case LoggingStreamOffset = 20
  case LoggingStreamData = 21
  case Channel1Mapping = 22
  case Channel1Range = 23
  case Channel1Analysis = 24
  case Channel1Value = 25
  case Channel1Offset = 26
  case Channel1Buf = 27
  case Channel1BufBPS = 28
  case Channel1BufLSBNative = 29
  case Channel2Mapping = 30
  case Channel2Range = 31
  case Channel2Analysis = 32
  case Channel2Value = 33
  case Channel2Offset = 34
  case Channel2Buf = 35
  case Channel2BufBPS = 36
  case Channel2BufLSBNative = 37
  case Shared = 38
  case RealPwr = 39
  
  
  var description : String
  {
    get
    {
      var result = ""
      
      switch self.rawValue
      {
        case 0:
          result = "ADMIN:CRC32"
        case 1:
          result = "ADMIN:TREE"
        case 2:
          result = "ADMIN:DIAGNOSTICS"
        case 3:
          result = "PCB_VERSION"
        case 4:
          result = "NAME"
        case 5:
          result = "TIME_UTC"
        case 6:
          result = "TIME_UTC_MS"
        case 7:
          result = "BAT_V"
        case 8:
          result = "REBOOT"
        case 9:
          result = "SAMPLING:RATE"
        case 10:
          result = "SAMPLING:DEPTH"
        case 11:
          result = "SAMPLING:TRIGGER"
        case 12:
          result = "LOG:ON"
        case 13:
          result = "LOG:INTERVAL"
        case 14:
          result = "LOG:STATUS"
        case 15:
          result = "LOG:POLLDIR"
        case 16:
          result = "LOG:INFO:INDEX"
        case 17:
          result = "LOG:INFO:END_TIME"
        case 18:
          result = "LOG:INFO:N_BYTES"
        case 19:
          result = "LOG:STREAM:INDEX"
        case 20:
          result = "LOG:STREAM:OFFSET"
        case 21:
          result = "LOG:STREAM:DATA"
        case 22:
          result = "CH1:MAPPING"
        case 23:
          result = "CH1:RANGE_I"
        case 24:
          result = "CH1:ANALYSIS"
        case 25:
          result = "CH1:VALUE"
        case 26:
          result = "CH1:OFFSET"
        case 27:
          result = "CH1:BUF"
        case 28:
          result = "CH1:BUF_BPS"
        case 29:
          result = "CH1:BUF_LSB2NATIVE"
        case 30:
          result = "CH2:MAPPING"
        case 31:
          result = "CH2:RANGE_I"
        case 32:
          result = "CH2:ANALYSIS"
        case 33:
          result = "CH2:VALUE"
        case 34:
          result = "CH2:OFFSET"
        case 35:
          result = "CH2:BUF"
        case 36:
          result = "CH2:BUF_BPS"
        case 37:
          result = "CH2:BUF_LSB2NATIVE"
        case 38:
          result = "SHARED"
        case 39:
          result = "REAL_PWR"
        default:
          break
      }
      
      return result
    }
  }

  var code : UInt8
  {
    get
    {
      return self.rawValue
    }
  }
}

enum ResultType: Int
{
  case plain    = 0   // May be an informational node, or a choice in a chooser
  case link     = 1   // A link to somewhere else in the tree
  case chooser  = 2   // The children of a CHOOSER can only be selected by one CHOOSER, and a CHOOSER can only select one child
  case val_U8   = 3   // These nodes have readable and writable values of the type specified
  case val_U16  = 4   // These nodes have readable and writable values of the type specified
  case val_U32  = 5   // These nodes have readable and writable values of the type specified
  case val_S8   = 6   // These nodes have readable and writable values of the type specified
  case val_S16  = 7   // These nodes have readable and writable values of the type specified
  case val_S32  = 8   // These nodes have readable and writable values of the type specified
  case val_STR  = 9   // These nodes have readable and writable values of the type specified
  case val_BIN  = 10  // These nodes have readable and writable values of the type specified
  case val_FLT  = 11  // These nodes have readable and writable values of the type specified
  case notset   = -1  // May be an informational node, or a choice in a chooser
}

class DeviceCommand: NSObject
{
  class func getReadCommandCode(type: DeviceCommandType) -> UInt8
  {
    let result: UInt8 = type.code & 0x7F
  
    return result
  }
  
  class func getWriteCommandCode(type: DeviceCommandType) -> UInt8
  {
    let result: UInt8 = type.code | 0x80
  
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
}


