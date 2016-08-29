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

  private static var initialized = false

  override class func initialize()
  {
    super.initialize()

    // Multipliers for every metric prefix
    prefixMultipliers[.Pico] = 1e-12
    prefixMultipliers[.Nano] = 1e-9
    prefixMultipliers[.Micro] = 1e-6
    prefixMultipliers[.Milli] = 1e-3
    prefixMultipliers[.NoPrefix] = 1.0
    prefixMultipliers[.Kilo] = 1000.0
    prefixMultipliers[.Mega] = 1000000.0
    prefixMultipliers[.Giga] = 1000000000.0

    // Holds Float/Double comparison precision in a form pow(x, -1 * n)
    // x: prefixed value
    // n: precision value
    prefixPrecision[.Pico] = 13
    prefixPrecision[.Nano] = 10
    prefixPrecision[.Micro] = 7
    prefixPrecision[.Milli] = 6
    prefixPrecision[.NoPrefix] = 6
    prefixPrecision[.Kilo] = 6
    prefixPrecision[.Mega] = 6
    prefixPrecision[.Giga] = 6

    // Prefixes to be used on value display
    // Can be read from localization file
    prefixShortName[.Pico] = "p"
    prefixShortName[.Nano] = "n"
    prefixShortName[.Micro] = "\u{00B5}"
    prefixShortName[.Milli] = "m"
    prefixShortName[.NoPrefix] = ""
    prefixShortName[.Kilo] = "k"
    prefixShortName[.Mega] = "M"
    prefixShortName[.Giga] = "G"

    initialized = true
  }

  //Mark: -
  //Mark: Methods

  class func getPrefixMultiplier(prefix: MetricPrefix) -> Double
  {
    var result: Double = 1.0

    let value: Double? = prefixMultipliers[prefix]
    if value != nil
    {
         result = value!
    }

    return result
  }

  class func getPrefixPrecision(prefix: MetricPrefix) -> Int
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
