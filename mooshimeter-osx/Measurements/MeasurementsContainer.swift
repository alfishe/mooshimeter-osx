//
//  MeasurementsContainer.swift
//  mooshimeter-osx
//
//  Created by Dev on 5/21/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Foundation

class MeasurementsContainer
{
  let measurementType: MeasurementType
  var samples: [Float?] = [Float?](repeating: nil, count: 1000)
  
  init(_ measurementType: MeasurementType)
  {
    self.measurementType = measurementType
    
    // Debug
    populateSamplesWithTestData()
  }
  
  //MARK: -
  //MARK: - Debug and test methods
  func populateSamplesWithTestData()
  {
    for i in 0...samples.count - 1
    {
      let value: Float = Float.random(lower: -0.001, 0.001)
      samples[i] = value
    }
  }
}
