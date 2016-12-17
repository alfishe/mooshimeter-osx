//
// Created by Dev on 8/28/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import Foundation

class UOMHelper : NSObject
{
  static var prefixMultipliers = [MetricPrefix: Double]()
  static var prefixPrecision = [MetricPrefix: Int]()
  static var prefixShortName = [MetricPrefix: String]()

  fileprivate static var initialized = false

  override class func initialize()
  {
    super.initialize()

    // Multipliers for every metric prefix
    prefixMultipliers[.pico] = 1e-12
    prefixMultipliers[.nano] = 1e-9
    prefixMultipliers[.micro] = 1e-6
    prefixMultipliers[.milli] = 1e-3
    prefixMultipliers[.noPrefix] = 1.0
    prefixMultipliers[.kilo] = 1000.0
    prefixMultipliers[.mega] = 1000000.0
    prefixMultipliers[.giga] = 1000000000.0

    // Holds Float/Double comparison precision in a form pow(x, -1 * n)
    // x: prefixed value
    // n: precision value
    prefixPrecision[.pico] = 13
    prefixPrecision[.nano] = 10
    prefixPrecision[.micro] = 7
    prefixPrecision[.milli] = 6
    prefixPrecision[.noPrefix] = 6
    prefixPrecision[.kilo] = 6
    prefixPrecision[.mega] = 6
    prefixPrecision[.giga] = 6

    // Prefixes to be used on value display
    // Can be read from localization file
    prefixShortName[.pico] = "p"
    prefixShortName[.nano] = "n"
    prefixShortName[.micro] = "\u{00B5}"
    prefixShortName[.milli] = "m"
    prefixShortName[.noPrefix] = ""
    prefixShortName[.kilo] = "k"
    prefixShortName[.mega] = "M"
    prefixShortName[.giga] = "G"

    initialized = true
  }

  //Mark: -
  //Mark: Methods

  class func getPrefixMultiplier(_ prefix: MetricPrefix) -> Double
  {
    var result: Double = 1.0

    let value: Double? = prefixMultipliers[prefix]
    if value != nil
    {
         result = value!
    }

    return result
  }

  class func getPrefixPrecision(_ prefix: MetricPrefix) -> Int
  {
    var result: Int = 6

    let value: Int? = prefixPrecision[prefix]
    if value != nil
    {
      result = value!
    }

    return result
  }
}
