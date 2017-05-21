//
//  MeasurementManager.swift
//  mooshimeter-osx
//
//  Created by Dev on 5/20/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Foundation

/*
 * Manages all measures for a single Device
 */
class MeasurementManager
{
  weak var device: Device? = nil
  
  init(device: Device)
  {
    self.device = device
  }
}
