//
//  DeviceCommand.swift
//  mooshimeter-osx
//
//  Created by Dev on 9/21/16.
//  Copyright © 2016 alfishe. All rights reserved.
//

import Foundation

enum DeviceCommandType: String, CustomStringConvertible
{
  case System = ""
  case Admin = "ADM"
  case Command = "CMD"
  case Sampling = "SAMPLING"
  
  var description : String
  {
    get
    {
      return self.rawValue
    }
  }
}

enum DeviceSystemCommand: String, CustomStringConvertible
{
  case PCBVersion = "PCB_VERSION"
  case Reboot = "REBOOT"
  
  
  var description : String
    {
    get
    {
      return self.rawValue
    }
  }
}

enum DeviceAdminCommand: String, CustomStringConvertible
{
  case CRC32 = "CRC32"
  case Tree = "TREE"
  case Diagnostic = "DIAGNOSTIC"
  
  var description : String
  {
    get
    {
      return self.rawValue
    }
  }
}

class DeviceCommand: NSObject
{
  
}


