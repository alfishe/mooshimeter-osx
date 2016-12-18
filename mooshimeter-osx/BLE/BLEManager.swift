//
//  BLEManager.swift
//  mooshimeter-osx
//
//  Created by Dev on 8/27/16.
//  Copyright © 2016 alfishe. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreBluetooth.CBPeripheral

class BLEManager : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate
{
  static let sharedInstance = BLEManager()

  var centralManager: CBCentralManager!
  var peripherals = [String: CBPeripheral]()
  var peripheralDescriptors = [String: BLEDeviceInformation]()

  fileprivate var isStarted = false

  override init()
  {
    super.init()

    self.centralManager = CBCentralManager(delegate: self, queue: DispatchLevel.utility.dispatchQueue)
  }

  func start()
  {
    if !isStarted
    {
      isStarted = true

      if self.centralManager.state == .poweredOn
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
    self.centralManager.scanForPeripherals(withServices: serviceUUIDs, options: nil)
  }

  func disconnectPeripheral(_ peripheral: CBPeripheral)
  {
    print("disconnectPeripheral")
    
    centralManager.cancelPeripheralConnection(peripheral)
  }

  func getPeripheralDescriptor(_ uuid: String) -> BLEDeviceInformation?
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
  
  func convertCBCharacteristicProperties(_ properties: CBCharacteristicProperties) -> String
  {
    var result = "";

    if (properties.contains(.broadcast))
    {
      result += "Broadcast; "
    }
    
    if (properties.contains(.read))
    {
      result += "Read; "
    }

    if (properties.contains(.writeWithoutResponse))
    {
      result += "WriteWithoutResponse; ";
    }
    
    if (properties.contains(.write))
    {
      result += "Write; "
    }
    
    if (properties.contains(.notify))
    {
      result += "Notify; "
    }
    
    if (properties.contains(.indicate))
    {
      result += "Indicate; "
    }
    
    if (properties.contains(.authenticatedSignedWrites))
    {
      result += "SignedWrites; "
    }
    
    if (properties.contains(.extendedProperties))
    {
      result += "ExtendedProperties; "
    }
    
    if (properties.contains(.notifyEncryptionRequired))
    {
      result += "EncryptionRequired; "
    }
    
    if (properties.contains(.indicateEncryptionRequired))
    {
      result += "IndicateEncryptionRequired"
    }
    
    return result
  }


  //MARK: -
  //MARK: CBCentralManagerDelegate
  
  func centralManagerDidUpdateState(_ central: CBCentralManager)
  {
    switch central.state
    {
      case .poweredOn:
        print("Central State PoweredOn")
        if isStarted
        {
          self.scanForPeripherals()
        }
      case .poweredOff:
        print("Central State PoweredOff")
      case .resetting:
        print("Central State Resetting")
      case .unauthorized:
        print("Central State Unauthorized")
      case .unknown:
        print("Central State Unknown")
      case .unsupported:
        print("Central State Unsupported")
    }
  }

  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String:Any], rssi RSSI: NSNumber)
  {
    let name = peripheral.name!
    let uuid = peripheral.identifier.uuidString

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
          dataServiceUUID = (array[0] as! CBUUID).uuidString
        }
      }
    }

    // Extract manufacturer data (Firmware build timestamp for now)
    if let value = advertisementData["kCBAdvDataManufacturerData"]
    {
      if value is Data
      {
        let data = value as! Data
        (data as NSData).getBytes(&manufacturerData, length: MemoryLayout<UInt32>.size)

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
        self.peripherals.removeValue(forKey: uuid)
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

      self.centralManager.connect(peripheral, options: nil)

      // TODO: adapt for multiple devices (i.e. stop scan on timeout, not on first device connected)
      self.centralManager.stopScan()
    }
    else
    {
      print("Peripheral is not connectable")
    }
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
  {
    print("-> Connected to '\(peripheral.name!)'")

    // Low level notification about CoreBluetooth peripheral connected
    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_PERIPHERAL_CONNECTED), object: peripheral.copy())

    // Register peripheral in DeviceManager
    let device = Device(peripheral: peripheral)
    DeviceManager.sharedInstance.addMeter(device)

    // High level notification about new device connected
    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_DEVICE_CONNECTED), object: device)

    peripheral.discoverServices(nil)
  }

  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
  {
    let name = peripheral.name!
    let uuid = peripheral.identifier.uuidString

    print("-> Peripheral '\(name)' \(uuid) disconnected")

    // Free reference to the peripheral
    if self.peripherals[uuid] != nil
    {
      self.peripherals.removeValue(forKey: uuid)
    }

    if self.peripheralDescriptors[uuid] != nil
    {
      self.peripheralDescriptors.removeValue(forKey: uuid)
    }

    // Low level notification about CoreBluetooth peripheral disconnection
    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_PERIPHERAL_DISCONNECTED), object: peripheral.copy())

    // Try to get information about corresponding device
    let device = DeviceManager.sharedInstance.getDeviceForUUID(uuid)

    if device != nil
    {
      // High level notification about device disconnection
      NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_DEVICE_DISCONNECTED), object: device)
    }
  }
  
  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
  {
    print("Connection to \(peripheral.identifier.uuidString) failed")
  }

  //MARK: -
  //MARK: CBPeripheralDelegate

  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
  {
    for service in peripheral.services!
    {
      print("Registered service: \(service.uuid.uuidString)")
      if service.uuid == CBUUID.expandToUUID(Constants.GATT_DEVICE_INFORMATION)
      {
        print("Device information service found. Won't discover cause Mooshimeter doesn't fill out it properly")
        //peripheral.discoverCharacteristics(nil, forService: service)
      }
      else if service.uuid == CBUUID.expandToMooshimUUID(Constants.METER_SERVICE)
      {
        print("Mooshimeter service found")
        peripheral.discoverCharacteristics(nil, for: service)
      }
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
  {
    if service.uuid == CBUUID.expandToUUID(Constants.GATT_DEVICE_INFORMATION)
    {
      for characteristic in service.characteristics!
      {
        let characteristicUUID: String = characteristic.uuid.uuidString
        print("DI: Discovered characteristic: \(characteristicUUID)")

        peripheral.readValue(for: characteristic)
      }
    }
    else if service.uuid == CBUUID.expandToMooshimUUID(Constants.METER_SERVICE)
    {
      for characteristic in service.characteristics!
      {
        let characteristicUUID: String = characteristic.uuid.uuidString
        let properties = convertCBCharacteristicProperties(characteristic.properties);
        print("MM: Discovered characteristic: \(characteristicUUID) with properties: \(properties) ")

        peripheral.readValue(for: characteristic)
      }
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
  {
    let characteristicUUID: String = characteristic.uuid.uuidString

    switch characteristicUUID
    {
      case Constants.GATT_DI_MANUFACTURER_NAME_UUID:
        var manufacturerName = String(data: characteristic.value!, encoding: String.Encoding.utf8)
      case Constants.GATT_DI_MODEL_NUMBER_UUID:
        var modelNumber = String(data: characteristic.value!, encoding: String.Encoding.utf8)
      case Constants.METER_SERVICE_IN_UUID:
        var value = characteristic.value
      case Constants.METER_SERVICE_OUT_UUID:
        var value = characteristic.value
      default:
        var value: Data!
        if characteristic.value != nil
        {
          value = characteristic.value!
        }
        print("Unknown characteristic ID: \(characteristic.uuid.uuidString) Value: \(value)")
    }
  }

  func peripheralDidUpdateName(_ peripheral: CBPeripheral)
  {
  }

  func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService])
  {
  }

  func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?)
  {
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?)
  {
  }



  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
  {
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?)
  {
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?)
  {
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?)
  {
  }

  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?)
  {
  }
}
