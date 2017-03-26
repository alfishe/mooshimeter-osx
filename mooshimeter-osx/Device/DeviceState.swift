//
//  DeviceState.swift
//  mooshimeter-osx
//
//  Created by Dev on 3/26/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Foundation

class DeviceState
{
  private var commandStates: [DeviceCommandType: AnyObject?] = [:]
  
  func getValue(_ command: DeviceCommandType) -> AnyObject?
  {
    let result = commandStates[command]
    
    return result!
  }
  
  func setValue(_ command: DeviceCommandType, value: AnyObject?) -> Void
  {
    commandStates[command] = value
  }
}
