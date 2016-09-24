//
//  PeripheralWrapper.swift
//  mooshimeter-osx
//
//  Created by Dev on 9/5/16.
//  Copyright © 2016 alfishe. All rights reserved.
//

import Foundation
import CoreBluetooth

class PeripheralWrapper
{
  func protectedCall(_ executeClosure: () ->())
  {
    executeClosure()
  }
}
