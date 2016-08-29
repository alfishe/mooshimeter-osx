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
  var peripheral: CBPeripheral?
  var service: CBService?
  var characteristic: CBCharacteristic?
  var deviceInformation = BLEDeviceInformation()
  
  func start()
  {
    self.centralManager = CBCentralManager(delegate: self, queue: nil)
  }
  
  func scanForPeripherals()
  {
    let serviceUUIDs:[CBUUID] = [ CBUUID(string: Constants.METER_SERVICE_UUID) ]
    self.centralManager.scanForPeripheralsWithServices(serviceUUIDs, options: nil)
  }

  func disconnectPeripheral(peripheral: CBPeripheral)
  {
    centralManager.cancelPeripheralConnection(peripheral)
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
        self.scanForPeripherals()
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
  
  func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber)
  {
    print("-> Peripheral '\(peripheral.name!)' \(peripheral.identifier.UUIDString) discovered")

    self.centralManager.stopScan()

    self.peripheral = peripheral
    self.peripheral?.delegate = self
    self.centralManager.connectPeripheral(self.peripheral!, options: nil)
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

    self.peripheral?.discoverServices(nil)
  }

  func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?)
  {
    let name = peripheral.name!
    let uuid = peripheral.identifier.UUIDString

    print("-> Peripheral '\(name)' \(uuid) disconnected")

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
    print("Ca a fail... C'est pas bien.")
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
        self.deviceInformation.manufacturerName = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)
      case Constants.GATT_DI_MODEL_NUMBER_UUID:
        self.deviceInformation.modelNumber = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)
      default:
        print("Unknown characteristic ID: \(characteristic.UUID.UUIDString) Value: \(characteristic.value!)")
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



  func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
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