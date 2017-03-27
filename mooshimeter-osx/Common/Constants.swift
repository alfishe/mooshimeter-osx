//
//  Constants.swift
//  Mooshimeter
//
//  Created by Dev on 6/21/16.
//  Copyright © 2016 moosh. All rights reserved.
//

import Foundation

struct Constants
{
  static let METER_SERVICE_UUID : String      = "1BC5FFA0-0200-62AB-E411-F254E005DBD4"
  static let METER_SERVICE_IN_UUID: String    = "1BC5FFA1-0200-62AB-E411-F254E005DBD4"
  static let METER_SERVICE_OUT_UUID: String   = "1BC5FFA2-0200-62AB-E411-F254E005DBD4"
  static let OAD_SERVICE_UUID : String        = "1BC5FFC0-0200-62AB-E411-F254E005DBD4"
  
  static let METER_SERVICE: UInt16       = 0xFFA0
  static let METER_SERVICE_IN: UInt16    = 0xFFA1
  static let METER_SERVICE_OUT: UInt16   = 0xFFA2
  
  static let METER_INFO: UInt16          = 0xFFA1
  static let METER_NAME: UInt16          = 0xFFA2
  static let METER_SETTINGS: UInt16      = 0xFFA3
  static let METER_LOG_SETTINGS: UInt16  = 0xFFA4
  static let METER_UTC_TIME: UInt16      = 0xFFA5
  static let METER_SAMPLE: UInt16        = 0xFFA6
  static let METER_CH1BUF: UInt16        = 0xFFA7
  static let METER_CH2BUF: UInt16        = 0xFFA8
  static let METER_CAL: UInt16           = 0xFFA9
  static let METER_LOG_DATA: UInt16      = 0xFFAA
  static let METER_TEMP: UInt16          = 0xFFAB
  static let METER_BAT: UInt16           = 0xFFAC
  
  static let OAD_SERVICE: UInt16         = 0xFFC0
  static let OAD_IMAGE_NOTIFY: UInt16    = 0xFFC1
  static let OAD_IMAGE_BLOCK_REQ: UInt16 = 0xFFC2
  static let OAD_REBOOT: UInt16          = 0xFFC3

  // GATT constants
  static let GATT_DEVICE_INFORMATION: UInt16 = 0x180A
  static let GATT_DEVICE_INFORMATION_UUID: String = "180A"

  // GATT Device Information Characteristics
  static let GATT_DI_MANUFACTURER_NAME: UInt16 = 0x2A29
  static let GATT_DI_MODEL_NUMBER: UInt16 = 0x2A24
  static let GATT_DI_SERIAL_NUMBER: UInt16 = 0x2A25
  static let GATT_DI_HARDWARE_REVISION: UInt16 = 0x2A27
  static let GATT_DI_FIRMWARE_REVISION: UInt16 = 0x2A26
  static let GATT_DI_SOFTWARE_REVISION: UInt16 = 0x2A28
  static let GATT_DI_SYSTEM_ID: UInt16 = 0x2A23
  static let GATT_DI_IEEE_11073_20601: UInt16 = 0x2A2A
  static let GATT_DI_PNP_ID: UInt16 = 0x2A50

  static let GATT_DI_MANUFACTURER_NAME_UUID: String = "2A29"
  static let GATT_DI_MODEL_NUMBER_UUID: String = "2A24"
  static let GATT_DI_SERIAL_NUMBER_UUID: String = "2A25"
  static let GATT_DI_HARDWARE_REVISION_UUID: String = "2A27"
  static let GATT_DI_FIRMWARE_REVISION_UUID: String = "2A26"
  static let GATT_DI_SOFTWARE_REVISION_UUID: String = "2A28"
  static let GATT_DI_SYSTEM_ID_UUID: String = "0x2A23"
  static let GATT_DI_IEEE_11073_20601_UUID: String = "2A2A"
  static let GATT_DI_PNP_ID_UUID: String = "2A50"
  
  // Transmission parameters
  static let DEVICE_PACKET_SIZE: Int = 20

  // Notification name IDs
  static let NOTIFICATION_DEVICE_CONNECTED = "DEVICE_CONNECTED"
  static let NOTIFICATION_DEVICE_DISCONNECTED = "DEVICE_DISCONNECTED"
  static let NOTIFICATION_ALL_DEVICES_DISCONNECTED = "ALL_DEVICES_DISCONNECTED"
  static let NOTIFICATION_DEVICE_READY = "DEVICE_READY"
  static let NOTIFICATION_DEVICE_HANDSHAKE_PASSED = "DEVICE_HANDSHAKE_PASSED"

  static let NOTIFICATION_PERIPHERAL_CONNECTED = "PERIPHERAL_CONNECTED"
  static let NOTIFICATION_PERIPHERAL_DISCONNECTED = "PERIPHERAL_DISCONNECTED"
  
  static let NOTIFICATION_DEVICE_STATE_VALUE_CHANGED = "DEVICE_STATE_VALUE_CHANGED"
}
