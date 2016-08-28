//
// Created by Dev on 8/27/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import XCTest
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
    let testUUID1 = "1234-5678-9012"
    let testUUID2 = "2222-2222-2222"
    let device1 = Device()
    device1.UUID = testUUID1
    let device2 = Device()
    device2.UUID = testUUID2
    
    
    var result = deviceManager.getMeterForUUID(testUUID1)
    XCTAssertNil(result)
    
    deviceManager.addMeter(device1)
    result = deviceManager.getMeterForUUID(testUUID1)
    XCTAssertNotNil(result)
    
    deviceManager.addMeter(device2)
    result = deviceManager.getMeterForUUID(testUUID2)
    XCTAssertNotNil(result)
    
    let count = deviceManager.count()
    XCTAssertEqual(count, 2)
  }
  
  func testRemoveMeter()
  {
    let testUUID1 = "1234-5678-9012"
    let testUUID2 = "2222-2222-2222"
    let device1 = Device()
    device1.UUID = testUUID1
    let device2 = Device()
    device2.UUID = testUUID2
    
    
    var result = deviceManager.getMeterForUUID(testUUID1)
    XCTAssertNil(result)
    
    deviceManager.addMeter(device1)
    result = deviceManager.getMeterForUUID(testUUID1)
    XCTAssertNotNil(result)
    
    deviceManager.addMeter(device2)
    result = deviceManager.getMeterForUUID(testUUID2)
    XCTAssertNotNil(result)
    
    var count = deviceManager.count()
    XCTAssertEqual(count, 2)

    
    deviceManager.removeMeter(device1)
    result = deviceManager.getMeterForUUID(testUUID1)
    XCTAssertNil(result)
    
    count = deviceManager.count()
    XCTAssertEqual(count, 1)
    
    deviceManager.removeMeter(device2)
    result = deviceManager.getMeterForUUID(testUUID2)
    XCTAssertNil(result)
    
    count = deviceManager.count()
    XCTAssertEqual(count, 0)
  }
  
  //MARK: -
  //MARK: Helper methods
  
  private func clear()
  {
    deviceManager.devices.removeAll(keepCapacity: false)
    deviceManager.devicesReverse.removeAll(keepCapacity: false)
  }
}
