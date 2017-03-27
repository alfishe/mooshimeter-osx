//
//  DeviceDebugViewController.swift
//  mooshimeter-osx
//
//  Created by Dev on 3/26/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Cocoa

class DeviceDebugViewController : NSViewController
{
  @IBOutlet weak var lblDeviceName: NSTextField!
  @IBOutlet weak var lblDeviceUUID: NSTextField!
  @IBOutlet weak var lblConnectionStatus: NSTextField!
  @IBOutlet weak var viewStatus01: DeviceCommandStatusView!
  @IBOutlet weak var viewStatus02: DeviceCommandStatusView!
  @IBOutlet weak var viewStatus03: DeviceCommandStatusView!
  
  private var device: Device? = nil
  
  override func viewWillAppear()
  {
    // Subscribe for notifications about device connection status changes
    NotificationCenter.default.addObserver(self, selector: #selector(self.deviceConnected), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_DEVICE_CONNECTED), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.deviceDisconnected), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_DEVICE_DISCONNECTED), object: nil)
    
    // Subscribe for value changes
    NotificationCenter.default.addObserver(self, selector: #selector(self.deviceStateValueChanged), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_DEVICE_STATE_VALUE_CHANGED), object: nil)
    
    self.lblDeviceName.stringValue = "N/A"
    self.lblDeviceUUID.stringValue = "N/A"
    self.lblConnectionStatus.stringValue = "Disconnected"
    
    viewStatus01.setCommandName(name: "CRC32")
    viewStatus02.setCommandName(name: "Battery")
    viewStatus03.setCommandName(name: "Sampling Rate")
    
    viewStatus01.setValue(value: "N/A")
    viewStatus02.setValue(value: "N/A")
    viewStatus03.setValue(value: "N/A")
    viewStatus01.hideIndicator()
    viewStatus02.hideIndicator()
    viewStatus03.hideIndicator()
  }
  
  override func viewWillDisappear()
  {
    // Cancel all animations
    viewStatus01.hideIndicator()
    viewStatus02.hideIndicator()
    viewStatus03.hideIndicator()
    
    // Unsubscribe from all notifications
    NotificationCenter.default.removeObserver(self)
  }
  
  //MARK: -
  //MARK: Helper methods
  @objc
  fileprivate func deviceConnected(_ notification: Notification)
  {
    let device: Device? = notification.object as! Device?
    
    if device != nil
    {
      self.device = device
      
      self.lblDeviceName.stringValue = (device?.peripheral.name)!
      self.lblDeviceUUID.stringValue = (device?.UUID)!
      self.lblConnectionStatus.stringValue = "Connected"
    }
  }
  
  @objc
  fileprivate func deviceDisconnected(_ notification: Notification)
  {
    let device: Device? = notification.object as! Device?
    
    if device != nil
    {
      self.lblDeviceName.stringValue = "N/A"
      self.lblDeviceUUID.stringValue = "N/A"
      self.lblConnectionStatus.stringValue = "Disconnected"
      
      self.viewStatus01.hideIndicator()
      self.viewStatus02.hideIndicator()
      self.viewStatus03.hideIndicator()
    }
  }
  
  @objc
  fileprivate func deviceStateValueChanged(_ notification: Notification)
  {
    let object = notification.object
    
    if object != nil
    {
      let deviceStateChange = object as! DeviceStateChange
      let deviceUUID = deviceStateChange.UUID
      let deviceCommand = deviceStateChange.commandType
      let valueType = deviceStateChange.valueType
      let value = deviceStateChange.value
      
      switch deviceCommand
      {
        case .CRC32:
          let msg = String(format: "0x%x", value as! UInt32)
          self.viewStatus01.setValue(value: msg)
        case .Battery:
          let msg = String(format: "%.6f", value as! Float)
          self.viewStatus02.setValue(value: msg)
        case .SamplingRate:
          let msg = String(format: "%@", DeviceCommand.printChooserValue(commandType: deviceCommand, value: (value as! UInt8)))
          self.viewStatus03.setValue(value: msg)
        default:
          break
      }
    }
  }
}
