//
//  TodayViewController.swift
//  today-extension
//
//  Created by Dev on 12/17/16.
//  Copyright © 2016 alfishe. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding
{
  @IBOutlet weak var title1Label: NSTextField!
  @IBOutlet weak var value1Label: NSTextField!
  @IBOutlet weak var title2Label: NSTextField!
  @IBOutlet weak var value2Label: NSTextField!
  @IBOutlet weak var graphView: NSView!
  
  var voltage1: Float = 0.0
  var voltage2: Float = 0.0
  
  var gCompletionHandler: ((NCUpdateResult) -> Void)?
  
  override var nibName: String?
  {
    return "TodayViewController"
  }

  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void))
  {
    gCompletionHandler = completionHandler
    
    
    // Update your data and prepare for a snapshot. Call completion handler when you are done
    // with NoData if nothing has changed or NewData if there is new data since the last
    // time we called you
    completionHandler(.newData)
    //completionHandler(.noData)
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    title1Label.stringValue = "AC"
    title2Label.stringValue = "DC"
    
    value1Label.stringValue = "--.----"
    value2Label.stringValue = "--.----"
    
    graphView.wantsLayer = true
    graphView.layer?.backgroundColor = NSColor.white.cgColor
    
    Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
  }
  
  func updateData()
  {
    voltage1 += 0.001
    voltage2 += 0.002
    
    value1Label.stringValue = "\(voltage1)"
    value2Label.stringValue = "\(voltage2)"
  }
}
