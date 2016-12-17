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
      .pico: 1e-12,
      .nano: 1e-9,
      .micro: 1e-6,
      .milli: 1e-3,
      .noPrefix: 1.0,
      .kilo: 1e3,
      .mega: 1e6,
      .giga: 1e9
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
