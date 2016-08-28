//
// Created by Dev on 8/27/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import Foundation

class Device: NSObject
{
  var UUID: String = ""

  //MARK: -
  //MARK: Initialization and status methods

  func initialize()
  {

  }

  func isConnected() -> Bool
  {
    let result = false

    return result
  }

  func isStreaming() -> Bool
  {
    let result = false

    return result
  }

  //MARK: -
  //MARK: Time methods
  func getTime() -> Double
  {
    let result: Double = 0.0

    return result
  }

  func setTime(time: Double)
  {

  }

  //MARK: -
  //MARK: Sample rate methods
}
