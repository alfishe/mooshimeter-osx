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
  @IBOutlet weak var viewLeftIndicator: LargeIndicatorView!
  @IBOutlet weak var viewRightIndicator: LargeIndicatorView!

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
      DispatchQueue.main.async
      {
        let deviceStateChange = object as! DeviceStateChangeEvent
        let deviceUUID = deviceStateChange.UUID
        let deviceCommand: DeviceCommandType = deviceStateChange.commandType
        let valueType = deviceStateChange.valueType
        let value = deviceStateChange.value
        
        switch deviceCommand
        {
          case .Battery:
            self.lblVCC.stringValue = String.init(format: "%.4f", value as! Float)
          case .Channel1Mapping:
            let mapping = Channel1MappingType(rawValue: value as! UInt8)!
            switch mapping
            {
              case .Current:
                self.viewLeftIndicator.lblMode.stringValue = "A"
              case .Temperature:
                self.viewLeftIndicator.lblMode.stringValue = "T"
              default:
                self.viewLeftIndicator.lblMode.stringValue = "?"
                break
            }
          case .Channel2Mapping:
            let mapping = Channel2MappingType(rawValue: value as! UInt8)!
            switch mapping
            {
              case .Voltage:
                self.viewRightIndicator.lblMode.stringValue = "V"
              case .Temperature:
                self.viewRightIndicator.lblMode.stringValue = "T"
              default:
                self.viewRightIndicator.lblMode.stringValue = "?"
                break
            }
          case .Channel1Value:
            let sample = value as! Float
            let meterReading = MeterReading(value: sample, uom: UnitsOfMeasure.ampers)
            let sign = sample >= 0 ? " " : "-"
            let absReadingValue = abs(meterReading.formattedValue)
            self.viewLeftIndicator.lblSign.stringValue = sign
            let format = String.init(format: "%%.%df %%@%%@", meterReading.prefixScale)
            self.viewLeftIndicator.lblValue.stringValue = String.init(format: format, absReadingValue, UOMHelper.sharedInstance.prefixShortName[meterReading.prefix]!, meterReading.toStringUOM())
          case .Channel2Value:
            let sample = value as! Float
            let absSample = abs(sample)
            let sign = sample >= 0 ? " " : "-"
            self.viewRightIndicator.lblSign.stringValue = sign
            self.viewRightIndicator.lblValue.stringValue = String.init(format: "%.6f", absSample)
          default:
            break
        }
        
        if deviceCommand == DeviceCommandType.Battery
        {
          self.lblVCC.stringValue = String.init(format: "%.4f", value as! Float)
        }
      }
    }
  }
}

