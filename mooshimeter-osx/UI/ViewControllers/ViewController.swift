//
//  ViewController.swift
//  mooshimeter-osx
//
//  Created by Dev on 8/27/16.
//  Copyright © 2016 alfishe. All rights reserved.
//

import Cocoa

class ViewController: NSViewController
{
  @IBOutlet weak var lblVCC: NSTextField!

  override func viewDidLoad()
  {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(self, selector: #selector(self.deviceStateValueChanged), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_DEVICE_STATE_VALUE_CHANGED), object: nil)
  }

  override var representedObject: Any?
  {
    didSet
    {
    // Update the view, if already loaded.
    }
  }

  @objc
  func deviceStateValueChanged(_ notification: Notification)
  {
    let object = notification.object
    
    if object != nil
    {
      let deviceStateChange = object as! DeviceStateChange
      let deviceUUID = deviceStateChange.UUID
      let deviceCommand = deviceStateChange.commandType
      let valueType = deviceStateChange.valueType
      let value = deviceStateChange.value
      
      if deviceCommand == DeviceCommandType.Battery
      {
        lblVCC.stringValue = String.init(format: "%.4f", value as! Float)
      }
    }
  }
}

