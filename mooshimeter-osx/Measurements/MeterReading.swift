//
// Created by Dev on 8/27/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import Foundation

class MeterReading
{
  fileprivate var value: Float
  fileprivate var digits: UInt16
  fileprivate var maxValue: Float
  fileprivate var uom: UnitsOfMeasure


  init(value: Float, digits: UInt16, maxValue: Float, uom: UnitsOfMeasure)
  {
    self.value = value
    self.digits = digits
    self.maxValue = maxValue
    self.uom = uom
  }

  func toString()
  {

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

}
