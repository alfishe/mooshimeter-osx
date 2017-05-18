//
//  DeviceCommandStreamTests.swift
//  mooshimeter-osx
//
//  Created by Dev on 5/18/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import XCTest
import Foundation
@testable import mooshimeter_osx

class DeviceCommandStreamTests: XCTestCase
{
  let deviceManager = DeviceManager.sharedInstance
  var device: Device? = nil
  
  override func setUp()
  {
    super.setUp()
    
    clear()
    
    let UUID = "1234567890"
    let device = Device(UUID: UUID)
    deviceManager.addMeter(device)
    self.device = deviceManager.getDeviceForUUID(UUID)
    XCTAssertNotNil(self.device, "Unable to create Device object")
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  func testSingleCommand()
  {
    let commandStream = self.device?.deviceCommandStream!
    
    //commandStream.
  }
  
  func testFullParsingCycle()
  {
    let packets = getTestBLEPackets()
    
    // Traverse all packets available
    for packet in packets
    {
      // Call Device's data entry point each time
      let packetData: Data? = Data(bytes: packet)
      self.device!.handleReadData(packetData)
    }
  }
  
  //MARK: -
  //MARK: Helper methods
  
  fileprivate func clear()
  {
    deviceManager.devices.removeAll(keepingCapacity: false)
    deviceManager.devicesReverse.removeAll(keepingCapacity: false)
  }
  
  fileprivate func getTestBLEPackets() -> [[UInt8]]
  {
    var result = [[UInt8]]()
    result.append([0xf9, 0x05, 0xc6, 0xd9, 0x1c, 0x59, 0x06, 0x49, 0x00, 0x19, 0x80, 0x24, 0x0c, 0x3d, 0x21, 0x4e, 0x88, 0xc7, 0x41, 0x27])
    result.append([0xfa, 0x5c, 0x7a, 0x5a, 0x3f])
    result.append([0xfb, 0x19, 0x80, 0x24, 0x0c, 0x3d])
    
    return result
  }
}
