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
  let bleManager = BLEManager.sharedInstance
  
  func applicationDidFinishLaunching(_ aNotification: Notification)
  {
    bleManager.start()
  }

  func applicationWillTerminate(_ aNotification: Notification)
  {
    print("applicationWillTerminate")

    // Unsubscribe from all notifications
    NotificationCenter.default.removeObserver(self)
  }

  func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply
  {
    print("applicationShouldTerminate")

    var result: NSApplicationTerminateReply = .terminateNow

    if DeviceManager.sharedInstance.count() > 0
    {
      result = NSApplicationTerminateReply.terminateLater

      // Disconnect all active peripheral devices asynchronously and notify application to finalize termination
      Async.background
      {
        // Disconnect all devices
        DeviceManager.sharedInstance.removeAll()

        // Subscribe for notification about all devices disconnection (application will terminate when triggered)
        NotificationCenter.default.addObserver(self, selector: #selector(self.exitApplication), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_ALL_DEVICES_DISCONNECTED), object: nil)

        // But to be sure that application is not blocked for termination forever - start watchdog closure with termination in 10 seconds
        delay(bySeconds: 10)
        {
          // Delayed code, by default run in main thread
          print("Devices disconnection timeout. Enforcing process termination")
          NSApplication.shared().reply(toApplicationShouldTerminate: true)
        }
      }
    }

    return result
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
  {
    return true
  }

  //MARK: -
  //MARK: Helper methods
  @objc
  fileprivate func exitApplication(_ notification: Notification)
  {
    print("-> exitApplication")
    NSApplication.shared().reply(toApplicationShouldTerminate: true)
  }
}

