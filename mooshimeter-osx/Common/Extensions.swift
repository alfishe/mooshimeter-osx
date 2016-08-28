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
    class func expandToMooshimUUID(sourceUUID: UInt16) -> CBUUID
    {
        let expandedUUIDBytes: [UInt8] =
        [
                0x1b, 0xc5, sourceUUID.hiByte(), sourceUUID.loByte(),
                0x02, 0x00, 0x62, 0xab,
                0xe4, 0x11, 0xf2, 0x54,
                0xe0, 0x05, 0xdb, 0xd4
        ]

        let data = NSMutableData(bytes: expandedUUIDBytes, length: expandedUUIDBytes.count)
        let result = CBUUID(data: data)

        return result
    }

    class func expandToUUID(sourceUUID: UInt16) -> CBUUID
    {
        let result: CBUUID = CBUUID(string: String(format:"%2X", sourceUUID))

        return result
    }
}

extension UInt16
{
    @inline(__always)
    static func loByte(word: UInt16) -> UInt8
    {
        let result = (UInt8)(word & 0xFF)

        return result
    }

    @inline(__always)
    static func hiByte(word: UInt16) -> UInt8
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
