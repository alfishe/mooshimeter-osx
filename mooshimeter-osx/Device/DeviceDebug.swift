//
//  DeviceDebug.swift
//  mooshimeter-osx
//
//  Created by Dev on 5/17/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Foundation

extension Device
{
  //MARK: -
  //MARK: - Dump methods
  func dumpPacket(packetNum: UInt8, data: Data) -> Void
  {
    let hex = getDataDumpString(data: data)
    var text: String = "Pkt: #\(String(packetNum)) len: \(data.count) hex: \(hex)"
    if let value = String(data: data, encoding: .ascii)
    {
      text = text + ". Value: " + value
    }
    print(text)
    
    self.dumpData(data: data)
  }
  
  func dumpCommandPacket(data: Data) -> Void
  {
    if data.count == 0
    {
      print("Unable to dump empty packet")
      return
    }
    
    let packetNumber = data.first!
    let commandTypeByte = data.suffix(from: 1).first!
    let commandType = DeviceCommandType(rawValue: commandTypeByte)!
    let commandTypeText = commandType.description
    let resultType = DeviceCommand.getResultTypeByCommand(command: commandTypeByte)
    let value = DeviceCommand.printPacketValue(data: data)
    
    print("")
    
    var text: String = "Pkt #\(String(format: "%u", packetNumber))"
    text = text + " Cmd: \(commandTypeText)"
    print(text)
    
    text = "Type: \(String(describing: resultType))"
    text += " Value: \(value)"
    print(text)
    
    let range: Range<Int> = 2..<data.count
    if let value = String(data: data.subdata(in: range), encoding: .ascii)
    {
      text = "ASCII: " + value
      print(text)
    }
    
    text = "HEX: " + getDataDumpString(data: data)
    print(text)
    
    print("")
  }
  
  func dumpData(data: Data?)
  {
    if data != nil
    {
      print(getDataDumpString(data: data))
    }
  }
  
  func getDataDumpString(data: Data?) -> String
  {
    var result = ""
    
    if data != nil
    {
      result = data!.map{ String(format: "%02x ", $0) }.joined()
    }
    
    return result
  }
}
