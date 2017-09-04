//
//  Extensions.swift
//  Mooshimeter
//
//  Created by Dev on 6/20/16.
//  Copyright © 2016 moosh. All rights reserved.
//

import Foundation
import Cocoa
import CoreBluetooth
import QuartzCore

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

// Allow to throw message exceptions
extension String: Error
{
}

extension Data
{
  // To/from generic conversions
  init<T>(from value: T)
  {
    var value = value
    self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
  }
  
  func to<T>(type: T.Type) -> T
  {
    return self.withUnsafeBytes { $0.pointee }
  }
  // End of From/to generic conversions
  
  // Allows to get subdata using ClosedRange<>
  func subdata(in range: ClosedRange<Index>) -> Data
  {
    return subdata(in: range.lowerBound ..< range.upperBound + 1)
  }
  
  func contains(_ data: Data?) -> Bool
  {
    var result: Bool = false
    
    if self.count > 0 && data != nil && data!.count > 0 && self.count >= data!.count
    {
      result = (self.range(of: data!) != nil)
    }
    
    return result
  }
  
  // Calculate CRC32 checksum for the whole data
  func getCrc32() -> UInt32
  {
    var result: UInt32 = crc32(0, buffer: nil, length: 0)
    result = crc32(result, data: self)
    
    return result
  }
  
  // Dumps data content bytes to hex String
  func hexEncodedString() -> String
  {
    let result = map
    {
      String(format: "%02hhx", $0)
    }.joined()
    
    return result
  }
  
  // Dumps data content bytes as groups of two hex symbols to String
  func hexBytesEncodedString() -> String
  {
    let result = map
      {
        String(format: "%02hhx ", $0)
      }.joined()
    
    return result
  }
}

extension UInt32
{
  func byteArray() -> [UInt8]
  {
    var result: [UInt8] = [UInt8](repeating: UInt8(), count: 4)
    
    if false
    {
      // BigEndian
      result[0] = (UInt8)(self >> 24 & 0xFF)
      result[1] = (UInt8)(self >> 16 & 0xFF)
      result[2] = (UInt8)(self >> 8 & 0xFF)
      result[3] = (UInt8)(self & 0xFF)
    }
    else
    {
      // LittleEndian
      result[0] = (UInt8)(self & 0xFF)
      result[1] = (UInt8)(self >> 8 & 0xFF)
      result[2] = (UInt8)(self >> 16 & 0xFF)
      result[3] = (UInt8)(self >> 24 & 0xFF)
    }
    
    // Pure Swift version
    /*
    var asByteArray: [UInt8]
    {
      let result = [0, 8, 16, 24].map { UInt8(self >> $0 & 0x000000FF) }
     
      return result
    }
     */
    
    return result
  }
}

extension UInt16
{
  func byteArray() -> [UInt8]
  {
    var result: [UInt8] = [UInt8](repeating: UInt8(), count: 2)
    
    // LittleEndian
    result[0] = (UInt8)(self & 0xFF)
    result[1] = (UInt8)(self >> 8 & 0xFF)
    
    return result
  }
  
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
  
  func round(to places: Int) -> Float
  {
    let result = Float(Double(self).round(to: places))
    
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
  
  func round(to places: Int) -> Double
  {
    let divisor = pow(10.0, Double(places))
    return Darwin.round(self * divisor) / divisor
  }
}

extension NSView
{
  func setBackgroundColor(_ color: NSColor)
  {
    wantsLayer = true
    layer?.backgroundColor = color.cgColor
  }
}

extension CALayer
{
  class func performWithoutAnimation(_ actionsWithoutAnimation: () -> Void)
  {
    CATransaction.begin()
    CATransaction.setValue(true, forKey: kCATransactionDisableActions)
    actionsWithoutAnimation()
    CATransaction.commit()
  }
}
