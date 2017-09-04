//
// Created by Dev on 8/27/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import Foundation

class MeterReading
{
  var value: Float
  var digits: UInt16
  var maxValue: Float
  var prefix: MetricPrefix
  var prefixMultiplier: Float
  var prefixScale: Int
  var uom: UnitsOfMeasure
  var formattedValue: Float

  init(value: Float, uom: UnitsOfMeasure)
  {
    self.value = value
    self.digits = 100
    self.maxValue = 0
    self.uom = uom
    self.prefix = .noPrefix
    self.prefixMultiplier = Float(UOMHelper.prefixMultipliers[self.prefix]!)
    self.prefixScale = UOMHelper.prefixScale[self.prefix]!
    self.formattedValue = 0
    
    self.determineValueRange(value)
  }

  init(value: Float, digits: UInt16, maxValue: Float, uom: UnitsOfMeasure)
  {
    self.value = value
    self.digits = digits
    self.maxValue = maxValue
    self.uom = uom
    self.prefix = .noPrefix
    self.prefixMultiplier = Float(UOMHelper.prefixMultipliers[self.prefix]!)
    self.prefixScale = UOMHelper.prefixScale[self.prefix]!
    self.formattedValue = 0
    
    self.determineValueRange(value)
  }

  func toString() -> String
  {
    let result = String.init(format: "%f %@%@", self.formattedValue, UOMHelper.prefixShortName[self.prefix]!, self.uom.description)
    
    return result
  }
  
  func toStringUOM() -> String
  {
    let result = self.uom.description
    
    return result
  }

  func isInRange() -> Bool
  {
    var result = false

    if self.value < self.maxValue
    {
      result = false
    }

    return result
  }

  func multiplyReadings(_ reading1: MeterReading, reading2: MeterReading) -> MeterReading
  {
    let resultValue = reading1.value * reading2.value
    let resultDigits = (reading1.digits + reading2.digits) / 2
    let resultMaxValue = reading1.maxValue * reading2.maxValue

    var resultUOM: UnitsOfMeasure = .undefined
    if (reading1.uom == .ampers && reading2.uom == .volts) || (reading1.uom == .volts && reading2.uom == .ampers)
    {
      resultUOM = .watts
    }

    let result = MeterReading(
            value: resultValue,
            digits: resultDigits,
            maxValue: resultMaxValue,
            uom: resultUOM
            )

    return result
  }

  //MARK: -
  //MARK: Helper methods
  func determineValueRange(_ value: Float)
  {
    let absValue = Double(abs(value))
    let sign: Double = value > 0 ? 1 : -1
    
    for prefix in UOMHelper.prefixMultipliers
    {
      let multiplier = prefix.value
      let prefixedValue = absValue / multiplier
      
      if prefixedValue > 0 && prefixedValue < 1000
      {
        let prefixScale = UOMHelper.prefixScale[self.prefix]!
        let formattedValue = Float(sign * prefixedValue.round(to: prefixScale))
        
        self.formattedValue = formattedValue
        self.prefix = prefix.key;
        self.prefixMultiplier = Float(UOMHelper.prefixMultipliers[self.prefix]!)
        self.prefixScale = prefixScale
        break
      }
    }
  }
}
