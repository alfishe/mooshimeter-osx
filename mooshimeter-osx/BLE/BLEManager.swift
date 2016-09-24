//
//  BLEManager.swift
//  mooshimeter-osx
//
//  Created by Dev on 8/27/16.
//  Copyright © 2016 alfishe. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEManager : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate
{
  static let sharedInstance = BLEManager()

  var centralManager: CBCentralManager!
  var peripherals = [String: CBPeripheral]()
  var peripheralDescriptors = [String: BLEDeviceInformation]()

  private var isStarted = false

  override init()
  {
    super.init()

    self.centralManager = CBCentralManager(delegate: self, queue: DispatchLevel.Utility.dispatchQueue)
  }

  func start()
  {
    if !isStarted
    {
      isStarted = true

      if self.centralManager.state == .PoweredOn
      {
        self.scanForPeripherals()
      }
    }
  }

  func stop()
  {
    isStarted = false
    self.centralManager.stopScan()
  }
  
  func scanForPeripherals()
  {
    print("scanForPeripherals")

    let serviceUUIDs:[CBUUID] = [ CBUUID(string: Constants.METER_SERVICE_UUID) ]
    self.centralManager.scanForPeripheralsWithServices(serviceUUIDs, options: nil)
  }

  func disconnectPeripheral(peripheral: CBPeripheral)
  {
    print("disconnectPeripheral")
    
    centralManager.cancelPeripheralConnection(peripheral)
  }

  func getPeripheralDescriptor(uuid: String) -> BLEDeviceInformation?
  {
    var result: BLEDeviceInformation? = nil

    if self.peripheralDescriptors[uuid] != nil
    {
      result = self.peripheralDescriptors[uuid]
    }

    return result
  }

  //MARK: -
  //MARK: - Private methods


  //MARK: -
  //MARK: CBCentralManagerDelegate
  
  func centralManagerDidUpdateState(central: CBCentralManager)
  {
    switch central.state
    {
      case .PoweredOn:
        print("Central State PoweredOn")
        if isStarted
        {
          self.scanForPeripherals()
        }
      case .PoweredOff:
        print("Central State PoweredOFF")
      case .Resetting:
        print("Central State Resetting")
      case .Unauthorized:
        print("Central State Unauthorized")
      case .Unknown:
        print("Central State Unknown")
      case .Unsupported:
        print("Central State Unsupported")
    }
  }

  func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String:AnyObject], RSSI: NSNumber)
  {
    let name = peripheral.name!
    let uuid = peripheral.identifier.UUIDString

    print("-> Peripheral '\(name)' \(uuid) discovered")

    var isConnectable: Bool = false
    var isSupported: Bool = false
    var dataServiceUUID: String!
    var manufacturerData: UInt32 = 0xFFFFFFFF

    if let value = advertisementData["kCBAdvDataIsConnectable"]
    {
      isConnectable = value as! Bool
    }

    // Extract UUID for data service (to distinct normal and OAD modes mostly)
    if let value = advertisementData["kCBAdvDataServiceUUIDs"]
    {
      if value is NSArray
      {
        let array = value as! NSArray

        if array.count > 0  && array[0] is CBUUID
        {
          dataServiceUUID = (array[0] as! CBUUID).UUIDString
        }
      }
    }

    // Extract manufacturer data (Firmware build timestamp for now)
    if let value = advertisementData["kCBAdvDataManufacturerData"]
    {
      if value is NSData
      {
        let data = value as! NSData
        data.getBytes(&manufacturerData, length: sizeof(UInt32))

        // Verify if the device supported in current application
        isSupported = Device.isDeviceSupported(manufacturerData)
      }
    }

    if isConnectable && isSupported
    {
      print("Peripheral is connectable (kCBAdvDataIsConnectable: 1)")

      // Check whether peripheral already known
      if self.peripherals[uuid] != nil
      {
        // Free reference for the peripheral known with same UUID
        self.peripherals.removeValueForKey(uuid)
      }

      // Register peripheral in collection to keep reference (otherwise will be freed after leaving current method)
      peripheral.delegate = self
      peripherals[uuid] = peripheral

      // Put associated advertisement data
      let descriptor = BLEDeviceInformation()
      descriptor.isSupported = isSupported
      descriptor.dataServiceUUID = dataServiceUUID
      descriptor.manufacturerData = manufacturerData
      self.peripheralDescriptors[uuid] = descriptor

      self.centralManager.connectPeripheral(peripheral, options: nil)

      // TODO: adapt for multiple devices (i.e. stop scan on timeout, not on first device connected)
      self.centralManager.stopScan()
    }
    else
    {
      print("Peripheral is not connectable")
    }
  }
  
  func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral)
  {
    print("-> Connected to '\(peripheral.name!)'")

    // Low level notification about CoreBluetooth peripheral connected
    NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_PERIPHERAL_CONNECTED, object: peripheral.copy())

    // Register peripheral in DeviceManager
    let device = Device(peripheral: peripheral)
    DeviceManager.sharedInstance.addMeter(device)

    // High level notification about new device connected
    NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_DEVICE_CONNECTED, object: device)

    peripheral.discoverServices(nil)
  }

  func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?)
  {
    let name = peripheral.name!
    let uuid = peripheral.identifier.UUIDString

    print("-> Peripheral '\(name)' \(uuid) disconnected")

    // Free reference to the peripheral
    if self.peripherals[uuid] != nil
    {
      self.peripherals.removeValueForKey(uuid)
    }

    if self.peripheralDescriptors[uuid] != nil
    {
      self.peripheralDescriptors.removeValueForKey(uuid)
    }

    // Low level notification about CoreBluetooth peripheral disconnection
    NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_PERIPHERAL_DISCONNECTED, object: peripheral.copy())

    // Try to get information about corresponding device
    let device = DeviceManager.sharedInstance.getDeviceForUUID(uuid)

    if device != nil
    {
      // High level notification about device disconnection
      NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_DEVICE_DISCONNECTED, object: device)
    }
  }
  
  func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?)
  {
    print("Connection to \(peripheral.identifier.UUIDString) failed")
  }

  //MARK: -
  //MARK: CBPeripheralDelegate

  func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?)
  {
    for service in peripheral.services!
    {
      print("Registered service: \(service.UUID.UUIDString)")
      if service.UUID == CBUUID.expandToUUID(Constants.GATT_DEVICE_INFORMATION)
      {
        print("Device information service found. Won't discover cause Mooshimeter doesn't fill out it properly")
        //peripheral.discoverCharacteristics(nil, forService: service)
      }
      else if service.UUID == CBUUID.expandToMooshimUUID(Constants.METER_SERVICE)
      {
        print("Mooshimeter service found")
        peripheral.discoverCharacteristics(nil, forService: service)
      }
    }
  }

  func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?)
  {
    if service.UUID == CBUUID.expandToUUID(Constants.GATT_DEVICE_INFORMATION)
    {
      for characteristic in service.characteristics!
      {
        let characteristicUUID: String = characteristic.UUID.UUIDString
        print("DI: Discovered characteristic: \(characteristicUUID)")

        peripheral.readValueForCharacteristic(characteristic)
      }
    }
    else if service.UUID == CBUUID.expandToMooshimUUID(Constants.METER_SERVICE)
    {
      for characteristic in service.characteristics!
      {
        let characteristicUUID: String = characteristic.UUID.UUIDString
        print("MM: Discovered characteristic: \(characteristicUUID)")

        peripheral.readValueForCharacteristic(characteristic)
      }
    }
  }

  func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?)
  {
    let characteristicUUID: String = characteristic.UUID.UUIDString

    switch characteristicUUID
    {
      case Constants.GATT_DI_MANUFACTURER_NAME_UUID:
        var manufacturerName = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)
      case Constants.GATT_DI_MODEL_NUMBER_UUID:
        var modelNumber = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)
      case Constants.METER_SERVICE_IN_UUID:
        var value = characteristic.value
      case Constants.METER_SERVICE_OUT_UUID:
        var value = characteristic.value
      default:
        var value: NSData!
        if characteristic.value != nil
        {
          value = characteristic.value!
        }
        print("Unknown characteristic ID: \(characteristic.UUID.UUIDString) Value: \(value)")
    }
  }

  func peripheralDidUpdateName(peripheral: CBPeripheral) {
  }

  func peripheral(peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
  }

  func peripheralDidUpdateRSSI(peripheral: CBPeripheral, error: NSError?) {
  }

  func peripheral(peripheral: CBPeripheral, didDiscoverIncludedServicesForService service: CBService, error: NSError?) {
  }



  func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?)
  {
  }

  func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
  }

  func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
  }

  func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
  }

  func peripheral(peripheral: CBPeripheral, didWriteValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
  }
}
