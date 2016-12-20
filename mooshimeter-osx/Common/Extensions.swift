//
//  Extensions.swift
//  Mooshimeter
//
//  Created by Dev on 6/20/16.
//  Copyright © 2016 moosh. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBUUID
{
    class func expandToMooshimUUID(_ sourceUUID: UInt16) -> CBUUID
    {
        let expandedUUIDBytes: [UInt8] =
        [
                0x1b, 0xc5, sourceUUID.hiByte(), sourceUUID.loByte(),
                0x02, 0x00, 0x62, 0xab,
                0xe4, 0x11, 0xf2, 0x54,
                0xe0, 0x05, 0xdb, 0xd4
        ]

        let data = NSMutableData(bytes: expandedUUIDBytes, length: expandedUUIDBytes.count)
        let result = CBUUID(data: data as Data)

        return result
    }

    class func expandToUUID(_ sourceUUID: UInt16) -> CBUUID
    {
        let result: CBUUID = CBUUID(string: String(format:"%2X", sourceUUID))

        return result
    }
}

extension UInt16
{
    @inline(__always)
    static func loByte(_ word: UInt16) -> UInt8
    {
        let result = (UInt8)(word & 0xFF)

        return result
    }

    @inline(__always)
    static func hiByte(_ word: UInt16) -> UInt8
    {
        let result = (UInt8)(word >> 8)

        return result
    }

    @inline(__always)
    func hiByte() -> UInt8
    {
        return UInt16.hiByte(self)
    }

    @inline(__always)
    func loByte() -> UInt8
    {
        return UInt16.loByte(self)
    }
}

extension Float
{
  static func isEqualWithPrecision(_ arg1: Float, arg2: Float, precision: Int) -> Bool
  {
    var result: Bool = false

    if Float.compareWithPrecision(arg1, arg2: arg2, precision: precision) == 0
    {
      result = true
    }

    return result
  }

  func isEqualWithPrecision(_ arg2: Float, precision: Int) -> Bool
  {
    let result = Float.isEqualWithPrecision(self, arg2: arg2, precision: precision)

    return result
  }

  static func compareWithPrecision(_ arg1: Float, arg2: Float, precision: Int) -> Int
  {
      var result: Int = 0

      if fabs(arg1 - arg2) < pow (1, Float(-1 * precision))
      {
        // Floats are equal with required precision
      }
      else if arg1 > arg2
      {
        result = 1
      }
      else
      {
        result = -1
      }

    return result
  }

  func compareWithPrecision(_ arg2: Float, precision: Int) -> Int
  {
    let result = Float.compareWithPrecision(self, arg2: arg2, precision: precision)

    return result
  }
}

extension Double
{
  static func isEqualWithPrecision(_ arg1: Double, arg2: Double, precision: Int) -> Bool
  {
    var result: Bool = false

    if Double.compareWithPrecision(arg1, arg2: arg2, precision: precision) == 0
    {
      result = true
    }

    return result
  }

  func isEqualWithPrecision(_ arg2: Double, precision: Int) -> Bool
  {
    let result = Double.isEqualWithPrecision(self, arg2: arg2, precision: precision)

    return result
  }

  static func compareWithPrecision(_ arg1: Double, arg2: Double, precision: Int) -> Int
  {
    var result: Int = 0

    if fabs(arg1 - arg2) < pow(1, Double(-1 * precision))
    {
      // Doubles are equal with required precision
    }
    else if arg1 > arg2
    {
      result = 1
    }
    else
    {
      result = -1
    }

    return result
  }

  func compareWithPrecision(_ arg2: Double, precision: Int) -> Int
  {
    let result = Double.compareWithPrecision(self, arg2: arg2, precision: precision)

    return result
  }
}
