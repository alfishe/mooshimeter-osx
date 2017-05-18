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
  @IBOutlet weak var viewCRC32: DeviceCommandStatusView!
  @IBOutlet weak var viewBattery: DeviceCommandStatusView!
  @IBOutlet weak var viewPCBVersion: DeviceCommandStatusView!
  @IBOutlet weak var viewTimeUTC: DeviceCommandStatusView!
  @IBOutlet weak var viewTimeUTCMs: DeviceCommandStatusView!
  // Sampling
  @IBOutlet weak var viewSamplingRate: DeviceCommandStatusView!
  @IBOutlet weak var viewSamplingDepth: DeviceCommandStatusView!
  @IBOutlet weak var viewSamplingTrigger: DeviceCommandStatusView!
  // Channel 1
  @IBOutlet weak var viewChannel1Mapping: DeviceCommandStatusView!
  @IBOutlet weak var viewChannel1Value: DeviceCommandStatusView!
  // Channel 2
  @IBOutlet weak var viewChannel2Mapping: DeviceCommandStatusView!
  @IBOutlet weak var viewChannel2Value: DeviceCommandStatusView!
  
  
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
    
    viewCRC32.setCommandName(name: "CRC32")
    viewBattery.setCommandName(name: "Battery")
    viewPCBVersion.setCommandName(name: "PCB Version")
    viewTimeUTC.setCommandName(name: "Time UTC")
    viewTimeUTCMs.setCommandName(name: "Time UTC ms")
    
    viewSamplingRate.setCommandName(name: "Sampling Rate")
    viewSamplingDepth.setCommandName(name: "Sampling Depth")
    viewSamplingTrigger.setCommandName(name: "Sampling Trigger")
    
    viewChannel1Mapping.setCommandName(name: "CH1 Mapping")
    viewChannel1Value.setCommandName(name: "CH1 Value")
    viewChannel2Mapping.setCommandName(name: "CH2 Mapping")
    viewChannel2Value.setCommandName(name: "CH2 Value")
    
    viewCRC32.setValue(value: "N/A")
    viewBattery.setValue(value: "N/A")
    viewPCBVersion.setValue(value: "N/A")
    viewTimeUTC.setValue(value: "N/A")
    viewTimeUTCMs.setValue(value: "N/A")
    
    viewSamplingRate.setValue(value: "N/A")
    viewSamplingDepth.setValue(value: "N/A")
    viewSamplingTrigger.setValue(value: "N/A")
    
    viewChannel1Mapping.setValue(value: "N/A")
    viewChannel1Value.setValue(value: "N/A")
    viewChannel2Mapping.setValue(value: "N/A")
    viewChannel2Value.setValue(value: "N/A")
    
    self.hideAllIndicators()
  }
  
  override func viewWillDisappear()
  {
    // Cancel all animations and hide indicators
    self.hideAllIndicators()
    
    // Unsubscribe from all notifications
    NotificationCenter.default.removeObserver(self)
  }
  
  //MARK: -
  //MARK: Helper methods
  
  fileprivate func hideAllIndicators()
  {
    viewCRC32.hideIndicator()
    viewBattery.hideIndicator()
    viewPCBVersion.hideIndicator()
    viewTimeUTC.hideIndicator()
    viewTimeUTCMs.hideIndicator()
    
    viewSamplingRate.hideIndicator()
    viewSamplingDepth.hideIndicator()
    viewSamplingTrigger.hideIndicator()
    
    viewChannel1Mapping.hideIndicator()
    viewChannel1Value.hideIndicator()
    viewChannel2Mapping.hideIndicator()
    viewChannel2Value.hideIndicator()
  }
  
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
      
      self.hideAllIndicators()
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
          self.viewCRC32.setValue(value: msg)
        case .Battery:
          let msg = String(format: "%.6f", value as! Float)
          self.viewBattery.setValue(value: msg)
        case .PCBVersion:
          let msg = String(format: "%d", value as! UInt8)
          self.viewPCBVersion.setValue(value: msg)
        case .TimeUTC:
          let date = NSDate(timeIntervalSince1970: TimeInterval(value as! UInt32))
          let dayTimePeriodFormatter = DateFormatter()
          dayTimePeriodFormatter.dateFormat = "MMM dd YYYY hh:mm:ss a"
          dayTimePeriodFormatter.timeZone = TimeZone.current
          let msg = dayTimePeriodFormatter.string(from: date as Date)
          self.viewTimeUTC.setValue(value: msg)
        case .TimeUTCms:
          let msg = String(format: "%u", value as! UInt16)
          self.viewTimeUTCMs.setValue(value: msg)
        
        case .SamplingRate:
          let msg = String(format: "%@", DeviceCommand.printChooserValue(commandType: deviceCommand, value: (value as! UInt8)))
          self.viewSamplingRate.setValue(value: msg)
        case .SamplingDepth:
          let msg = String(format: "%@", DeviceCommand.printChooserValue(commandType: deviceCommand, value: (value as! UInt8)))
          self.viewSamplingDepth.setValue(value: msg)
        case .SamplingTrigger:
          let msg = String(format: "%@", DeviceCommand.printChooserValue(commandType: deviceCommand, value: (value as! UInt8)))
          self.viewSamplingTrigger.setValue(value: msg)
        
        
        case .Channel1Mapping:
          let msg = String(format: "%@", DeviceCommand.printChooserValue(commandType: deviceCommand, value: (value as! UInt8)))
          self.viewChannel1Mapping.setValue(value: msg)
        case .Channel1Value:
          let msg = String(format: "%.6f", value as! Float)
          self.viewChannel1Value.setValue(value: msg)
        case .Channel2Mapping:
          let msg = String(format: "%@", DeviceCommand.printChooserValue(commandType: deviceCommand, value: (value as! UInt8)))
          self.viewChannel2Mapping.setValue(value: msg)
        case .Channel2Value:
          let msg = String(format: "%.6f", value as! Float)
          self.viewChannel2Value.setValue(value: msg)

        default:
          break
      }
    }
  }
}
