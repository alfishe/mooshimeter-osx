//
// Created by Dev on 8/28/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import Foundation

class UOMHelper : NSObject
{
  static var prefixMultipliers = [MetricPrefix: Double]()
  static var prefixPrecision = [MetricPrefix: Int]()
  static var prefixScale = [MetricPrefix: Int]()
  static var prefixShortName = [MetricPrefix: String]()
  
  static let sharedInstance = UOMHelper()
  fileprivate static var initialized = false
  
  override init()
  {
    super.init()
    
    // Multipliers for every metric prefix
    UOMHelper.prefixMultipliers[.pico] = 1e-12
    UOMHelper.prefixMultipliers[.nano] = 1e-9
    UOMHelper.prefixMultipliers[.micro] = 1e-6
    UOMHelper.prefixMultipliers[.milli] = 1e-3
    UOMHelper.prefixMultipliers[.noPrefix] = 1.0
    UOMHelper.prefixMultipliers[.kilo] = 1000.0
    UOMHelper.prefixMultipliers[.mega] = 1000000.0
    UOMHelper.prefixMultipliers[.giga] = 1000000000.0

    // Holds Float/Double comparison precision in a form pow(x, -1 * n)
    // x: prefixed value
    // n: precision value
    UOMHelper.prefixPrecision[.pico] = 13
    UOMHelper.prefixPrecision[.nano] = 10
    UOMHelper.prefixPrecision[.micro] = 7
    UOMHelper.prefixPrecision[.milli] = 6
    UOMHelper.prefixPrecision[.noPrefix] = 6
    UOMHelper.prefixPrecision[.kilo] = 6
    UOMHelper.prefixPrecision[.mega] = 6
    UOMHelper.prefixPrecision[.giga] = 6

    // Number of digits after the decimal point to display
    prefixScale[.pico] = 0
    prefixScale[.nano] = 0
    prefixScale[.micro] = 3
    prefixScale[.milli] = 5
    prefixScale[.noPrefix] = 5
    prefixScale[.kilo] = 3
    prefixScale[.mega] = 3
    prefixScale[.giga] = 0
    
    // Prefixes to be used on value display
    // Can be read from localization file
    UOMHelper.prefixShortName[.pico] = "p"
    UOMHelper.prefixShortName[.nano] = "n"
    UOMHelper.prefixShortName[.micro] = "\u{00B5}"
    UOMHelper.prefixShortName[.milli] = "m"
    UOMHelper.prefixShortName[.noPrefix] = ""
    UOMHelper.prefixShortName[.kilo] = "k"
    UOMHelper.prefixShortName[.mega] = "M"
    UOMHelper.prefixShortName[.giga] = "G"

    UOMHelper.initialized = true
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
  
  class func getPrefixScale(_ prefix: MetricPrefix) -> Int
  {
    var result: Int = 5
    
    let value: Int? = prefixScale[prefix]
    if value != nil
    {
      result = value!
    }
    
    return result
  }
}
