//
//  RandomTests.swift
//  mooshimeter-osx
//
//  Created by Dev on 5/21/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Foundation
import XCTest
@testable import mooshimeter_osx

class RandomTests : XCTestCase
{
  override func setUp()
  {
    super.setUp()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  func testFloat()
  {
    var testValues: [Float?] = [Float?](repeating: nil, count: 100)
    let lower:Float = -0.05
    let upper:Float = 0.05
    
    for i in 0...testValues.count - 1
    {
      testValues[i] = Float.random(lower: -0.05, 0.05)
    }
    
    for i in 0...testValues.count - 1
    {
      let value = testValues[i]!
      if value < lower || value > upper
      {
        XCTAssert(true, "Value outside boundaries")
      }
    }
  }
}
