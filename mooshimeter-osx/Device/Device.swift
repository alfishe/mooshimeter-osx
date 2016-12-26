//
// Created by Dev on 8/27/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import Foundation
import CoreBluetooth

class Device: NSObject
{
  let peripheral: CBPeripheral
  let UUID: String
  
  fileprivate var readCharacteristic: CBCharacteristic?
  fileprivate var writeCharacteristic: CBCharacteristic?
  
  fileprivate var deviceReady = false

  //MARK: -
  //MARK: Class methods
  class func isDeviceSupported(_ version: UInt32) -> Bool
  {
    var result = false

    // Only versions after ... supported
    if version >= 1454355414
    {
      result = true
    }

    return result
  }

  //MARK: -
  //MARK: Initialization and status methods

  init(peripheral: CBPeripheral)
  {
    self.peripheral = peripheral
    self.UUID = peripheral.identifier.uuidString
  }

  func isConnected() -> Bool
  {
    var result = false

    if peripheral.state == .connected
    {
      result = true
    }

    return result
  }
  
  func setCharacteristics(read: CBCharacteristic, write: CBCharacteristic)
  {
    self.readCharacteristic = read
    self.writeCharacteristic = write
    
    if self.isConnected()
    {
      self.deviceReady = true
      
      // Notify that device is fully initialized and ready
      NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_DEVICE_READY), object: self)
    }
  }

  func isStreaming() -> Bool
  {
    let result = false

    return result
  }
  
  //MARK: -
  //MARK: Helper methods
  func writeValueSync()
  {
    // Use Async wrapper to encapsulate wait for async logic. Can be implemented at least two ways using native GCD calls
    // dispatch_group_create + dispatch_group_enter + dispatch_group_leave + dispatch_group_wait
    // or dispatch_semaphore_create + dispatch_semaphore_signal + dispatch_semaphore_wait
    let group = AsyncGroup()
    
    // Execute as async block
    group.background
    {
        print("writeValueSync executed on the background queue")
    }
    
    // But wait until it completes
    group.wait()
  }
  
  func writeValueAsync(value: String)
  {
    let data = value.data(using: .utf8)!
    
    self.writeValueAsync(data: data)
  }
  
  func writeValueAsync(bytes: [UInt8])
  {
    let data: Data = Data(bytes: bytes)

    self.writeValueAsync(data: data)
  }
  
  func writeValueAsync(data: Data)
  {
    if writeCharacteristic != nil
    {
      self.peripheral.writeValue(data, for: self.writeCharacteristic!, type: .withResponse)
    }
  }

  func handleReadData(_ data: Data?)
  {
    if let unwrappedData = data
    {
      let badreadData = "BADREAD".data(using: .ascii)
      let badwriteData = "BADWRITE".data(using: .ascii)
      
      if unwrappedData.count > 0
      {
        let packetNum = unwrappedData[0]
        
        if unwrappedData.contains(badreadData)
        {
          print("Bad read data received. Packet #\(String(packetNum))")
        }
        else if unwrappedData.contains(badwriteData)
        {
          print("Bad write data received. Packet #\(String(packetNum))")
        }
        else
        {
          var text: String = "Packet #\(String(packetNum)) received"
          if let value = String(data: unwrappedData, encoding: .ascii)
          {
            text = text + ". Value: " + value
          }
            
          print(text)
        }
      }
    }
  }

  //MARK: -
  //MARK: Time methods
  func getTime() -> Double
  {
    let result: Double = 0.0

    return result
  }

  func setTime(_ time: Double)
  {

  }

  //MARK: -
  //MARK: Sample rate methods
}
