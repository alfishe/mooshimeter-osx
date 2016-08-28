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
    var prefix: MetricPrefix = .Pico
    var multiplier = UOMHelper.getPrefixMultiplier(prefix)
    var isEqual = Double.isEqualWithPrecision(multiplier, arg2: Double(1e-12), precision: UOMHelper.getPrefixPrecision(prefix))
    XCTAssertTrue(isEqual)

    prefix = .Nano
    multiplier = UOMHelper.getPrefixMultiplier(prefix)
    isEqual = Double.isEqualWithPrecision(multiplier, arg2: Double(1e-9), precision: UOMHelper.getPrefixPrecision(prefix))
    XCTAssertTrue(isEqual)

    prefix = .Micro
    multiplier = UOMHelper.getPrefixMultiplier(prefix)
    isEqual = Double.isEqualWithPrecision(multiplier, arg2: Double(1e-6), precision: UOMHelper.getPrefixPrecision(prefix))
    XCTAssertTrue(isEqual)

    prefix = .Milli
    multiplier = UOMHelper.getPrefixMultiplier(prefix)
    isEqual = Double.isEqualWithPrecision(multiplier, arg2: Double(1e-3), precision: UOMHelper.getPrefixPrecision(prefix))
    XCTAssertTrue(isEqual)

    prefix = .NoPrefix
    multiplier = UOMHelper.getPrefixMultiplier(prefix)
    isEqual = Double.isEqualWithPrecision(multiplier, arg2: Double(1), precision: UOMHelper.getPrefixPrecision(prefix))
    XCTAssertTrue(isEqual)

    prefix = .Kilo
    multiplier = UOMHelper.getPrefixMultiplier(prefix)
    isEqual = Double.isEqualWithPrecision(multiplier, arg2: Double(1e3), precision: UOMHelper.getPrefixPrecision(prefix))
    XCTAssertTrue(isEqual)

    prefix = .Mega
    multiplier = UOMHelper.getPrefixMultiplier(prefix)
    isEqual = Double.isEqualWithPrecision(multiplier, arg2: Double(1e6), precision: UOMHelper.getPrefixPrecision(prefix))
    XCTAssertTrue(isEqual)

    prefix = .Giga
    multiplier = UOMHelper.getPrefixMultiplier(prefix)
    isEqual = Double.isEqualWithPrecision(multiplier, arg2: Double(1e9), precision: UOMHelper.getPrefixPrecision(prefix))
    XCTAssertTrue(isEqual)
  }
}
