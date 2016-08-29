//
// Created by Dev on 8/27/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import Foundation

class MeterReading
{
  private var value: Float
  private var digits: UInt16
  private var maxValue: Float
  private var uom: UnitsOfMeasure


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

  func multiplyReadings(reading1: MeterReading, reading2: MeterReading) -> MeterReading
  {
    let resultValue = reading1.value * reading2.value
    let resultDigits = (reading1.digits + reading2.digits) / 2
    let resultMaxValue = reading1.maxValue * reading2.maxValue

    var resultUOM: UnitsOfMeasure = .Undefined
    if (reading1.uom == .Ampers && reading2.uom == .Volts) || (reading1.uom == .Volts && reading2.uom == .Ampers)
    {
      resultUOM = .Watts
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
