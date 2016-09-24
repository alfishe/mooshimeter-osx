//
//  CoreBluetoothExtensions.swift
//  mooshimeter-osx
//
//  Created by Dev on 9/9/16.
//  Copyright © 2016 alfishe. All rights reserved.
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

extension CBCharacteristic
{
  
  func isWritable() -> Bool
  {
    return (self.properties.intersection(CBCharacteristicProperties.write)) != []
  }
  
  func isReadable() -> Bool
  {
    return (self.properties.intersection(CBCharacteristicProperties.read)) != []
  }
  
  func isWritableWithoutResponse() -> Bool
  {
    return (self.properties.intersection(CBCharacteristicProperties.writeWithoutResponse)) != []
  }
  
  func isNotifable() -> Bool
  {
    return (self.properties.intersection(CBCharacteristicProperties.notify)) != []
  }
  
  
  func isIdicatable() -> Bool
  {
    return (self.properties.intersection(CBCharacteristicProperties.indicate)) != []
  }
  
  func isBroadcastable() -> Bool
  {
    return (self.properties.intersection(CBCharacteristicProperties.broadcast)) != []
  }
  
  func isExtendedProperties() -> Bool
  {
    return (self.properties.intersection(CBCharacteristicProperties.extendedProperties)) != []
  }
  
  func isAuthenticatedSignedWrites() -> Bool
  {
    return (self.properties.intersection(CBCharacteristicProperties.authenticatedSignedWrites)) != []
  }
  
  func isNotifyEncryptionRequired() -> Bool
  {
    return (self.properties.intersection(CBCharacteristicProperties.notifyEncryptionRequired)) != []
  }
  
  func isIndicateEncryptionRequired() -> Bool
  {
    return (self.properties.intersection(CBCharacteristicProperties.indicateEncryptionRequired)) != []
  }
  
  func getPropertyContent() -> String
  {
    var propContent = ""
    
    if (self.properties.intersection(CBCharacteristicProperties.broadcast)) != []
    {
      propContent += "Broadcast,"
    }
    
    if (self.properties.intersection(CBCharacteristicProperties.read)) != []
    {
      propContent += "Read,"
    }
    
    if (self.properties.intersection(CBCharacteristicProperties.writeWithoutResponse)) != []
    {
      propContent += "WriteWithoutResponse,"
    }
    
    if (self.properties.intersection(CBCharacteristicProperties.write)) != []
    {
      propContent += "Write,"
    }
    
    if (self.properties.intersection(CBCharacteristicProperties.notify)) != []
    {
      propContent += "Notify,"
    }
    
    if (self.properties.intersection(CBCharacteristicProperties.indicate)) != []
    {
      propContent += "Indicate,"
    }
    
    if (self.properties.intersection(CBCharacteristicProperties.authenticatedSignedWrites)) != []
    {
      propContent += "AuthenticatedSignedWrites,"
    }
    
    if (self.properties.intersection(CBCharacteristicProperties.extendedProperties)) != []
    {
      propContent += "ExtendedProperties,"
    }
    
    if (self.properties.intersection(CBCharacteristicProperties.notifyEncryptionRequired)) != []
    {
      propContent += "NotifyEncryptionRequired,"
    }
    
    if (self.properties.intersection(CBCharacteristicProperties.indicateEncryptionRequired)) != []
    {
      propContent += "IndicateEncryptionRequired,"
    }
    
    if !propContent.isEmpty
    {
      propContent = propContent.substring(to: propContent.characters.index(propContent.endIndex, offsetBy: -1))
    }
    
    return propContent
  }
}
