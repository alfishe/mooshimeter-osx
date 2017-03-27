//
// Created by Dev on 8/28/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import Foundation

protocol DeviceProtocol
{
  func getPCBVersion() -> UInt8
  
  func setName(_ name: String)
  func getName() -> String
}

/*
// TODO: Synchronous wrappers around async operations
extension Device: DeviceProtocol
{
  internal func getPCBVersion() -> UInt8
  {
    var result: UInt8 = 0
    
    return result
  }

  internal func getName() -> String
  {
    var result: String = ""
    
    
    return result
  }

  internal func setName(_ name: String)
  {
  }
}
*/
