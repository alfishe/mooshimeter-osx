//
//  TemperatureHelper.swift
//  mooshimeter-osx
//
//  Created by Dev on 8/27/16.
//  Copyright © 2016 alfishe. All rights reserved.
//

import Foundation

class TemperatureHelper
{
  struct TemperatureCoefficients
  {
    var coefficients: [Double]
    var low: Double
    var high: Double
  }
  
  //MARK: -
  //MARK: Thermopair type coefficients
  
  // All coefficients from Omega's datasheet:
  // ITS-90 Thermocouple Direct and Inverse Polynomials
  // https://www.omega.com/temperature/Z/pdf/z198-201.pdf
  static let typeK: TemperatureCoefficients = TemperatureCoefficients(
    coefficients:
    [
      0.0,
      2.508355e-2,
      7.860106e-8,
      -2.503131e-10,
      8.315270e-14,
      -1.228034e-17,
      9.804036e-22,
      -4.413030e-26,
      1.057734e-30,
      -1.052755e-35
    ],
    low: 0.0,
    high: 50.0
  )

  static let typeJ: TemperatureCoefficients = TemperatureCoefficients(
    coefficients:
    [
      0.0,
      1.978425e-2,
      -2.001204e-7,
      1.036969e-11
    ],
    low: 0.0,
    high: 760.0
  )
  
  static let typeT: TemperatureCoefficients = TemperatureCoefficients(
    coefficients:
    [
      0.0,
      2.592800e-2,
      -7.602961e-7,
      4.637791e-11,
      -2.165394e-15
    ],
    low: 0.0,
    high: 400.0
  )
  
  static let typeE: TemperatureCoefficients = TemperatureCoefficients(
    coefficients:
    [
      0.0,
      1.7057035e-2,
      -2.3301759e-7,
      6.5435585e-12,
      -7.3562749e-17
    ],
    low: 0.0,
    high: 1000.0
  )
  
  static let typeN: TemperatureCoefficients = TemperatureCoefficients(
    coefficients:
    [
      0.0,
      3.8783277e-2,
      -1.1612344e-6,
      6.9525655e-11,
      -3.0090077e-15
    ],
    low: 0.0,
    high: 600.0
  )
  
  static let typeB: TemperatureCoefficients = TemperatureCoefficients(
    coefficients:
    [
      9.842332e1,
      6.997150e-1,
      -8.4765304e-4,
      1.0052644e-6,
      -83345952e-10
    ],
    low: 250.0,
    high: 700.0
  )
  
  static let typeR: TemperatureCoefficients = TemperatureCoefficients(
    coefficients:
    [
      0.0,
      1.8891380e-1,
      -9.3835290e-5,
      1.3068619e-7,
      -2.2703580e-10,
      3.5145659e-13
    ],
    low: -50.0,
    high: 250.0
  )
  
  static let typeS: TemperatureCoefficients = TemperatureCoefficients(
    coefficients:
    [
      0.0,
      1.84949460e-1,
      -8.00504062e-5,
      1.02237430e-7,
      -1.52248592e-10,
      1.88821343e-13
    ],
    low: -50.0,
    high: 250.0
  )


  //MARK: -
  //MARK: Temperature conversion methods

  class func absK2C(_ kelvinValue: Float) -> Float
  {
    let result = kelvinValue - 273.15
    
    return result;
  }
  
  class func absK2F(_ kelvinValue: Float) -> Float
  {
    let result = (kelvinValue - 273.15) * 1.80000 + 32.00
    
    return result;
  }
  
  class func absC2F(_ celsiusValue: Float) -> Float
  {
    let result = celsiusValue * 1.80000 + 32.00
    
    return result;
  }
  
  class func relK2F(_ kelvinValue: Float) -> Float
  {
    let result = kelvinValue * 1.80000
    
    return result
  }
  
  class func convertVoltsToDegreesC(_ volts: Float) -> Float
  {
    let result = applyPolyCoefficients(volts, coefficients: typeK)
    
    return result
  }

  //Mark: -
  //Mark: Helper methods

  fileprivate class func applyPolyCoefficients(_ value: Float, coefficients: TemperatureCoefficients) -> Float
  {
    let uValue: Double = Double(value) * Double(1e6)
    var result: Float = 0.0
    var sum: Double = 0.0
    var power: Double = 0.0

    if coefficients.coefficients.count == 0
    {
      return result
    }

    for coefficient in coefficients.coefficients
    {
      sum += coefficient * pow(uValue, power)
      power += 1
    }

    if sum > coefficients.high || sum < coefficients.low
    {
      print("Warning - using a temperature polynomial outside of it's recommended temp range")
    }

    result = Float(sum)

    return result
  }
}
