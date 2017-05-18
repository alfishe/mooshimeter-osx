//
// Created by Dev on 8/27/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import mooshimeter_osx

class DeviceManagerTests: XCTestCase
{
  let deviceManager = DeviceManager.sharedInstance

  override func setUp()
  {
    super.setUp()

    clear()
  }

  override func tearDown()
  {
    super.tearDown()
  }

  func testAddMeter()
  {
    let peripheral = CBPeripheral()
    let testUUID1 = "1234-5678-9012"
    let testUUID2 = "2222-2222-2222"
    let device1 = Device(peripheral: peripheral)
    //device1.UUID = testUUID1
    let device2 = Device(peripheral: peripheral)
    //device2.UUID = testUUID2
    
    
    var result = deviceManager.getDeviceForUUID(testUUID1)
    XCTAssertNil(result)
    
    deviceManager.addMeter(device1)
    result = deviceManager.getDeviceForUUID(testUUID1)
    XCTAssertNotNil(result)
    
    deviceManager.addMeter(device2)
    result = deviceManager.getDeviceForUUID(testUUID2)
    XCTAssertNotNil(result)
    
    let count = deviceManager.count()
    XCTAssertEqual(count, 2)
  }
  
  func testRemoveMeter()
  {
    let testUUID1 = "1234-5678-9012"
    let testUUID2 = "2222-2222-2222"
    let device1 = Device(UUID: testUUID1)
    let device2 = Device(UUID: testUUID2)
    
    var result = deviceManager.getDeviceForUUID(testUUID1)
    XCTAssertNil(result)
    
    deviceManager.addMeter(device1)
    result = deviceManager.getDeviceForUUID(testUUID1)
    XCTAssertNotNil(result)
    
    deviceManager.addMeter(device2)
    result = deviceManager.getDeviceForUUID(testUUID2)
    XCTAssertNotNil(result)
    
    var count = deviceManager.count()
    XCTAssertEqual(count, 2)

    
    deviceManager.removeMeter(device1)
    result = deviceManager.getDeviceForUUID(testUUID1)
    XCTAssertNil(result)
    
    count = deviceManager.count()
    XCTAssertEqual(count, 1)
    
    deviceManager.removeMeter(device2)
    result = deviceManager.getDeviceForUUID(testUUID2)
    XCTAssertNil(result)
    
    count = deviceManager.count()
    XCTAssertEqual(count, 0)
  }
  
  //MARK: -
  //MARK: Helper methods
  
  fileprivate func clear()
  {
    deviceManager.devices.removeAll(keepingCapacity: false)
    deviceManager.devicesReverse.removeAll(keepingCapacity: false)
  }
}
