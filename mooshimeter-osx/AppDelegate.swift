//
//  AppDelegate.swift
//  mooshimeter-osx
//
//  Created by Dev on 8/27/16.
//  Copyright © 2016 alfishe. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
  let bleManager = BLEManager()
  
  func applicationDidFinishLaunching(aNotification: NSNotification)
  {
    bleManager.start()
  }

  func applicationWillTerminate(aNotification: NSNotification)
  {
  }


}

