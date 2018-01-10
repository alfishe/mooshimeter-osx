//
//  ViewController.swift
//  mooshimeter-osx
//
//  Created by Dev on 8/27/16.
//  Copyright © 2016 alfishe. All rights reserved.
//

import Foundation
import AppKit

class ViewController: NSViewController
{
  @IBOutlet weak var lblVCC: NSTextField!
  @IBOutlet weak var viewGraph: GraphView!

  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    initSubviews()

    NotificationCenter.default.addObserver(self, selector: #selector(self.deviceStateValueChanged), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_DEVICE_STATE_VALUE_CHANGED), object: nil)
  }

  override var representedObject: Any?
  {
    didSet
    {
    // Update the view, if already loaded.
    }
  }
  
  func initSubviews()
  {
    //self.viewGraph.initialize()
  }

  //MARK: -
  //MARK: Event handlers
  @objc
  func deviceStateValueChanged(_ notification: Notification)
  {
    let object = notification.object
    
    if object != nil
    {
      let deviceStateChange = object as! DeviceStateChangeEvent
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

