//
//  DeviceEnumerations.swift
//  mooshimeter-osx
//
//  Created by Dev on 3/5/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Foundation

// Marks enumeration as chooser type
protocol DeviceChooser
{
}

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

enum RebootType: UInt8, DeviceChooser
{
  case Normal = 0
  case Shipping = 1
  
  var description : String
  {
    get
    {
      var result = ""
      
      switch self
      {
        case .Normal:
          result = "Normal"
        case .Shipping:
          result = "Shipping Mode"
      }
      
      return result
    }
  }
}

enum SamplingRateType: UInt8, DeviceChooser
{
  case Freq125Hz = 0
  case Freq250Hz = 1
  case Freq500Hz = 2
  case Freq1000Hz = 3
  case Freq2000Hz = 4
  case Freq4000Hz = 5
  case Freq8000Hz = 6
  
  var description : String
  {
    get
    {
      var result = ""
      
      switch self
      {
        case .Freq125Hz:
          result = "125"
        case .Freq250Hz:
          result = "250"
        case .Freq500Hz:
          result = "500"
        case .Freq1000Hz:
          result = "1000"
        case .Freq2000Hz:
          result = "2000"
        case .Freq4000Hz:
          result = "4000"
        case .Freq8000Hz:
          result = "8000"
      }
      
      return result
    }
  }
}

enum SamplingDepthType: UInt8, DeviceChooser
{
  case Depth32 = 0
  case Depth64 = 1
  case Depth128 = 2
  case Depth256 = 3
  
  var description : String
  {
    get
    {
      var result = ""
      
      switch self
      {
        case .Depth32:
          result = "32"
        case .Depth64:
          result = "64"
        case .Depth128:
          result = "128"
        case .Depth256:
          result = "256"
      }
      
      return result
    }
  }
}

enum SamplingTriggerType: UInt8, DeviceChooser
{
  case Off = 0
  case Single = 1
  case Continuous = 2
  
  var description : String
  {
    get
    {
      var result = ""
      
      switch self
      {
        case .Off:
          result = "Off"
        case .Single:
          result = "Single"
        case .Continuous:
          result = "Continuous"
      }
      
      return result
    }
  }
}

enum Channel1MappingType: UInt8, DeviceChooser
{
  case Current = 0
  case Temperature = 1
  case Shared = 2
  
  var description : String
  {
    get
    {
      var result = ""
      
      switch self
      {
        case .Current:
          result = "Current"
        case .Temperature:
          result = "Temperature"
        case .Shared:
          result = "Shared"
      }
      
      return result
    }
  }
}

enum Channel2MappingType: UInt8, DeviceChooser
{
  case Voltage = 0
  case Temperature = 1
  case Shared = 2
  
  var description : String
  {
    get
    {
      var result = ""
      
      switch self
      {
        case .Voltage:
          result = "Voltage"
        case .Temperature:
          result = "Temperature"
        case .Shared:
          result = "Shared"
      }
      
      return result
    }
  }
}

enum Channel1AnalysisType: UInt8, DeviceChooser
{
  case Mean = 0
  case RMS = 1
  case Buffer = 2
  
  var description : String
  {
    get
    {
      var result = ""
      
      switch self
      {
        case .Mean:
          result = "Mean"
        case .RMS:
          result = "RMS"
        case .Buffer:
          result = "Buffer"
      }
      
      return result
    }
  }
}

enum Channel2AnalysisType: UInt8, DeviceChooser
{
  case Mean = 0
  case RMS = 1
  case Buffer = 2
  
  var description : String
  {
    get
    {
      var result = ""
      
      switch self
      {
        case .Mean:
          result = "Mean"
        case .RMS:
          result = "RMS"
        case .Buffer:
          result = "Buffer"
      }
      
      return result
    }
  }
}

enum SharedModeType: UInt8, DeviceChooser
{
  case AuxVoltage = 0
  case Resistance = 1
  case Diode = 2
  
  var description : String
  {
    get
    {
      var result = ""
      
      switch self
      {
        case .AuxVoltage:
          result = "AUX Voltage"
        case .Resistance:
          result = "Resistance"
        case .Diode:
          result = "Diode"
      }
      
      return result
    }
  }
}

enum AuxVoltageRangeType: UInt8, DeviceChooser
{
  case AuxRange0_1 = 0
  case AuxRange0_3 = 1
  case AuxRange1_2 = 2
  
  var description : String
  {
    get
    {
      var result = ""
      
      switch self
      {
        case .AuxRange0_1:
          result = "0.1"
        case .AuxRange0_3:
          result = "0.3"
        case .AuxRange1_2:
          result = "1.2"
      }
      
      return result
    }
  }
}

enum ResistanceRangeType: UInt8, DeviceChooser
{
  case ResistanceRange1k = 0
  case ResistanceRange10k = 1
  case ResistanceRange100k = 2
  case ResistanceRange1m = 3
  case ResistanceRange10m = 4
  
  var description : String
  {
    get
    {
      var result = ""
      
      switch self
      {
        case .ResistanceRange1k:
          result = "1k"
        case .ResistanceRange10k:
          result = "10k"
        case .ResistanceRange100k:
          result = "100k"
        case .ResistanceRange1m:
          result = "1M"
        case .ResistanceRange10m:
          result = "10M"
      }
      
      return result
    }
  }
}

enum DiodeRangeType: UInt8, DeviceChooser
{
  case DiodeRange1_2 = 0
  
  var description : String
  {
    get
    {
      var result = ""
      
      switch self
      {
        case .DiodeRange1_2:
          result = "1.2"
      }
      
      return result
    }
  }
}

