//
// Created by Dev on 8/27/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

enum ChannelType
{
  case channel1
  case channel2
  case math
}

enum MetricPrefix
{
  case pico
  case nano
  case micro
  case milli
  case noPrefix
  case kilo
  case mega
  case giga
}

enum UnitsOfMeasure
{
  case undefined
  case none
  case degreesC
  case degreesK
  case degreesF
  case volts
  case ampers
  case ohms
  case watts
  case decibels
  case hertz
  
  var description : String
  {
    get
    {
      var result = ""
      
      switch self
      {
        case .degreesC:
          result = "C"
        case .degreesK:
          result = "K"
        case .degreesF:
          result = "F"
        case .volts:
          result = "V"
        case .ampers:
          result = "A"
        case .ohms:
          result = "Ohms"
        case .watts:
          result = "W"
        case .decibels:
          result = "dB"
        case .hertz:
          result = "Hz"
        default:
          break
      }
      
      return result
    }
  }
}

enum DeviceState
{
  case Idle
  case Scanning
  case SingleDeviceConnected
  case MultipleDevicesConnected
}

enum MeasurementType
{
  case current
  case voltage
  case resistance
  case temperature
}
