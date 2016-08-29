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
  
  func applicationDidFinishLaunching(aNotification: NSNotification)
  {
    bleManager.start()
  }

  func applicationWillTerminate(aNotification: NSNotification)
  {
    print("applicationWillTerminate")

    // Unsubscribe from all notifications
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply
  {
    print("applicationShouldTerminate")

    var result: NSApplicationTerminateReply = .TerminateNow

    if DeviceManager.sharedInstance.count() > 0
    {
      result = NSApplicationTerminateReply.TerminateLater

      Async.background
      {
        // Disconnect all devices
        DeviceManager.sharedInstance.removeAll()

        // Subscribe for notification about all devices disconnection (application will terminate when triggered)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.exitApplication), name: Constants.NOTIFICATION_ALL_DEVICES_DISCONNECTED, object: nil)

        // But to be sure that application is not blocked for termination forever - start watchdog closure with termination in 10 seconds
        delay(bySeconds: 10)
        {
          // delayed code, by default run in main thread
          print("Delay timeout")
          NSApplication.sharedApplication().replyToApplicationShouldTerminate(true)
        }
      }
    }

    return result
  }

  func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool
  {
    return true
  }

  //MARK: -
  //MARK: Helper methods
  @objc
  private func exitApplication(notification: NSNotification)
  {
    print("-> exitApplication")
    NSApplication.sharedApplication().replyToApplicationShouldTerminate(true)
  }
}

