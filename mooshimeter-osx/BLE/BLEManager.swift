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
  var centralManager: CBCentralManager!
  var peripheral: CBPeripheral?
  var service: CBService?
  var characteristic: CBCharacteristic?
  var deviceInfromation = BLEDeviceInformation()
  
  func start()
  {
    self.centralManager = CBCentralManager(delegate: self, queue: nil)
  }
  
  func scanForPeripherals()
  {
    let serviceUUIDs:[CBUUID] = [ CBUUID(string: Constants.METER_SERVICE_UUID) ]
    self.centralManager.scanForPeripheralsWithServices(serviceUUIDs, options: nil)
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
    print("Peripheral discovered")

    self.centralManager.stopScan()

    self.peripheral = peripheral
    self.peripheral?.delegate = self
    self.centralManager.connectPeripheral(self.peripheral!, options: nil)
  }
  
  func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral)
  {
    print("Connected to '\(peripheral.name!)'")
    self.peripheral?.discoverServices(nil)
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
        print("Device information service found")
        peripheral.discoverCharacteristics(nil, forService: service)
      }
      else if service.UUID == CBUUID.expandToMooshimUUID(Constants.METER_SERVICE)
      {
        print("Mooshimeter service found")
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
        print("Discovered characteristic: \(characteristicUUID)")

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
        self.deviceInfromation.manufacturerName = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)
      case Constants.GATT_DI_MODEL_NUMBER_UUID:
        self.deviceInfromation.modelNumber = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)
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