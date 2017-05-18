//
// Created by Dev on 8/28/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import Foundation

protocol DeviceProtocol
{
  func getPCBVersion() -> UInt8
  
  func setName(_ name: String)
  func getName() -> String
  
  func getDiagnostics() -> String
  func getAdminTree() -> Void
  
  
}

extension Device
{
  //MARK: -
  //MARK: - System methods
  
  // Mooshimeter firmware has 20 secs timeout for inactive connection
  // Sending any command each 10 secs will keep connection alive
  func keepalive()
  {
    _ = self.getTime()
  }
  
  func getAdminTree() -> Void
  {
    print("Getting AdminTree...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getReadCommandCode(type: DeviceCommandType.Tree))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  func sendCRC32(crc: UInt32) -> Void
  {
    print(String(format: "Sending CRC: 0x%x ...", crc))
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getWriteCommandCode(type: DeviceCommandType.CRC32))
    dataBytes.append(contentsOf: crc.byteArray())
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  
  // TODO: Doesn't work
  func getDiagnostic() -> Void
  {
    print("Getting Diagnostic...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getReadCommandCode(type: DeviceCommandType.Diagnostic))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  func getPCBVersion() -> Void
  {
    print("Getting PCB_VERSION...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getReadCommandCode(type: DeviceCommandType.PCBVersion))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  func getName() -> Void
  {
    print("Getting Name...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getReadCommandCode(type: DeviceCommandType.Name))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  //MARK: -
  //MARK: Time methods
  func getTime()
  {
    print("Getting Time_UTC...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getReadCommandCode(type: DeviceCommandType.TimeUTC))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  func setTime(_ time: Double)
  {
    
  }
  
  func getTimeMs()
  {
    print("Getting Time_UTCms...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getReadCommandCode(type: DeviceCommandType.TimeUTCms))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  func setTimeMs(_ time: UInt16)
  {
    
  }
  
  //MARK: -
  //MARK: Sampling methods
  func getSamplingRate()
  {
    print("Getting Sampling Rate...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getReadCommandCode(type: DeviceCommandType.SamplingRate))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  func setSamplingRate(_ samplerate: SamplingRateType)
  {
    print("Setting Sampling Rate...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getWriteCommandCode(type: DeviceCommandType.SamplingRate))
    dataBytes.append(contentsOf: DeviceCommand.getCommandPayload(commandType: DeviceCommandType.SamplingRate, value: samplerate as AnyObject))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  func getSamplingDepth()
  {
    print("Getting Sampling Depth...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getReadCommandCode(type: DeviceCommandType.SamplingDepth))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  func setSamplingDepth(_ depth: SamplingDepthType)
  {
    print("Setting Sampling Depth...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getWriteCommandCode(type: DeviceCommandType.SamplingDepth))
    dataBytes.append(contentsOf: DeviceCommand.getCommandPayload(commandType: DeviceCommandType.SamplingDepth, value: depth as AnyObject))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  func getSamplingTrigger()
  {
    print("Getting Sampling Trigger...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getReadCommandCode(type: DeviceCommandType.SamplingTrigger))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  func setSamplingTrigger(_ trigger: SamplingTriggerType)
  {
    print("Setting Sampling Trigger...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getWriteCommandCode(type: DeviceCommandType.SamplingTrigger))
    dataBytes.append(contentsOf: DeviceCommand.getCommandPayload(commandType: DeviceCommandType.SamplingTrigger, value: trigger as AnyObject))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  //MARK: -
  //MARK: Channel1 methods
  func getChannel1Mapping()
  {
    print("Getting Channel1 Mapping...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getReadCommandCode(type: DeviceCommandType.Channel1Mapping))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  func setChannel1Mapping(_ mapping: Channel1MappingType)
  {
    print("Setting Channel1 Mapping...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getWriteCommandCode(type: DeviceCommandType.Channel1Mapping))
    dataBytes.append(contentsOf: DeviceCommand.getCommandPayload(commandType: DeviceCommandType.Channel1Mapping, value: mapping as AnyObject))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  func getChannel1Value()
  {
    print("Getting Channel1 Value...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getReadCommandCode(type: DeviceCommandType.Channel1Value))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  //MARK: -
  //MARK: Channel2 methods
  func getChannel2Mapping()
  {
    print("Getting Channel2 Mapping...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getReadCommandCode(type: DeviceCommandType.Channel2Mapping))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  func setChannel2Mapping(_ mapping: Channel1MappingType)
  {
    print("Setting Channel2 Mapping...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getWriteCommandCode(type: DeviceCommandType.Channel2Mapping))
    dataBytes.append(contentsOf: DeviceCommand.getCommandPayload(commandType: DeviceCommandType.Channel2Mapping, value: mapping as AnyObject))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
  
  func getChannel2Value()
  {
    print("Getting Channel2 Value...")
    
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getReadCommandCode(type: DeviceCommandType.Channel2Value))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }
}
