//
// Created by Dev on 8/28/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import XCTest
@testable import mooshimeter_osx

class UOMHelperTests : XCTestCase
{
  override func setUp()
  {
    super.setUp()
  }

  override func tearDown()
  {
    super.tearDown()
  }

  func testGetPrefixMultiplier()
  {
    var test: [MetricPrefix: Double] =
    [
      .Pico: 1e-12,
      .Nano: 1e-9,
      .Micro: 1e-6,
      .Milli: 1e-3,
      .NoPrefix: 1.0,
      .Kilo: 1e3,
      .Mega: 1e6,
      .Giga: 1e9
    ]
    
    for prefix in test.keys
    {
      let refValue = test[prefix]
      let multiplier = UOMHelper.getPrefixMultiplier(prefix)
      let isEqual = Double.isEqualWithPrecision(multiplier, arg2: refValue!, precision: UOMHelper.getPrefixPrecision(prefix))
      XCTAssertTrue(isEqual)
    }
  }
}
