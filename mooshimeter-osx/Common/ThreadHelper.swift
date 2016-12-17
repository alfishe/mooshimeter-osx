//
// Created by Dev on 8/28/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import Foundation

func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void)
{
  let dispatchTime = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
  dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
}

enum DispatchLevel
{
  case main
  case userInteractive
  case userInitiated
  case utility
  case background

  var dispatchQueue: DispatchQueue
  {
    var result: DispatchQueue

    switch self
    {
      case .main:
        result = DispatchQueue.main
      case .userInteractive:
        result = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
      case .userInitiated:
        result = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
      case .utility:
        result = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
      case .background:
        result = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    }

    return result
  }
}
