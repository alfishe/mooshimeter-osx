//
//  DeviceCommandStream.swift
//  mooshimeter-osx
//
//  Created by Dev on 5/17/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Foundation

class DeviceCommandStream
{
  // Markers for errneous command responses from the device
  static let BadreadData = "BADREAD".data(using: .ascii)
  static let BadwriteData = "BADWRITE".data(using: .ascii)
  
  // Back reference for the device in-serve
  weak internal var device: Device?
  weak internal var deviceContext: DeviceContext?
  
  // Packet numeration counters
  internal var receivePacketNum: UInt8 = 0
  internal var sendPacketNum: UInt8 = 0
  
  // Receive buffers and helpers
  internal var receiveBuffer: [UInt8] = [UInt8]()
  internal var currentFrame: [UInt8] = [UInt8](repeating: UInt8(), count: Constants.DEVICE_PACKET_SIZE)
  internal var expectFirstPacket: Bool = false
  internal var expectMoreData: Bool = false

  // Command result parsing state
  internal var command: UInt8 = 0
  internal var expectingBytes: Int = 0
  
  // Higher level session state properties
  internal var handshakePassed: Bool = false
  
  init(device: Device, context: DeviceContext)
  {
    self.device = device
    self.deviceContext = context
    
    self.resetSendPacketNum()
  }
  
  func isHandshakePassed() -> Bool
  {
    return self.handshakePassed
  }
  
  //MARK: -
  //MARK: Packet number helpers
  
  // Packet numeration starts from 1
  // Firmware doesn't like zero packet num and returns an error
  func resetSendPacketNum() -> Void
  {
    self.sendPacketNum = 1
  }
  
  func getNextSendPacketNum() -> UInt8
  {
    let result = self.sendPacketNum
    self.sendPacketNum = self.sendPacketNum &+ 1
    
    if self.sendPacketNum == 0
    {
      self.sendPacketNum = 1
    }
    
    return result
  }
  
  func prepareForDataReceive() -> Void
  {
    self.currentFrame.removeAll(keepingCapacity: true)
    self.receiveBuffer.removeAll(keepingCapacity: true)
    
    self.expectFirstPacket = true
    self.expectMoreData = false
    self.expectingBytes = 0
  }
  
  //MARK: -
  //MARK: Data receive processor
  
  func handleReadData(_ data: Data?)
  {
    if let unwrappedData = data
    {
      if unwrappedData.count > 0
      {
        let packetNum: UInt8 = unwrappedData[0]
        
        if unwrappedData.contains(DeviceCommandStream.BadreadData)
        {
          print("Bad read data received. Packet #\(String(packetNum))")
          
          self.resetReceiveBufferState()
        }
        else if unwrappedData.contains(DeviceCommandStream.BadwriteData)
        {
          print("Bad write data received. Packet #\(String(packetNum))")
          
          self.resetReceiveBufferState()
        }
        else if !self.expectFirstPacket && packetNum != self.receivePacketNum &+ 1
        {
          print ("Packet #\(String(packetNum)) received out of order. Expected #\(String(self.receivePacketNum))")
        }
        else
        {
          // Store current frame for decoding purposes
          self.currentFrame.removeAll()
          self.currentFrame.append(contentsOf: unwrappedData)
          
          self.decodeData()
          
          // Debug
          // self.dumpPacket(packetNum: packetNum, data: unwrappedData)
        }
        
        self.receivePacketNum = packetNum
      }
    }
  }
  
  func verifyPacket(_ packet: Data) throws
  {
    // Check 1: BLE packet is not empty
    if packet.count == 0
    {
      throw CommandStreamPacketError.emptyPacket
    }
    
    // Check 2: Packet number is in sequence (no packets missed)
    let packetNum: UInt8 = packet[0]
    if packetNum != self.receivePacketNum &+ 1
    {
      throw CommandStreamPacketError.packetNumOutOfOrder
    }
    
    let dataPacket = packet.subdata(in: 1...packet.count)
    
    // Check 3: Data packet is not empty
    if dataPacket.count == 0
    {
      throw CommandStreamPacketError.emptyDataPacket
    }
    
    // Check 4: Verify that the device didn't respond either with BADREAD or BADWRITE values
    if packet.contains(DeviceCommandStream.BadreadData)
    {
      throw CommandStreamPacketError.badReadData
    }
    else if packet.contains(DeviceCommandStream.BadwriteData)
    {
      throw CommandStreamPacketError.badWriteData
    }
  }
  
  func verifyCommand(_ commandData: Data) throws
  {
    // Check 1: Data bytes are not empty
    if commandData.count == 0
    {
      throw CommandStreamCommandError.emptyCommand
    }
    
    let commandType: UInt8 = commandData[0]
    
    // Check 2: Check that command is valid (command code is correct)
    if commandType > DeviceCommandType.RealPwr.rawValue
    {
      throw CommandStreamCommandError.invalidCommand
    }
    
    let payloadData = commandData.subdata(in: 1...commandData.count)
    let payloadSize = payloadData.count
    let resultType = DeviceCommand.getResultTypeByCommand(command: commandType)
    let resultSize = DeviceCommand.getResultSizeType(resultType)
    
    // Check 3: Check that payload is presented in full
    if resultSize == 0
    {
      // Nothing to do
    }
    else if resultSize == Constants.DEVICE_COMMAND_PAYLOAD_VARIABLE_LEN
    {
      // Variable length result has 2 bytes value for real length
      if payloadSize < 2
      {
        throw CommandStreamCommandError.incompletePayload
      }
    
      let realLength = Int(payloadData.to(type: UInt16.self))
      if payloadSize - 2 < realLength
      {
        throw CommandStreamCommandError.incompletePayload
      }
    }
    else
    {
      if payloadSize < resultSize
      {
        throw CommandStreamCommandError.incompletePayload
      }
    }
  }
  
  func decodeData()
  {
    var decodingFinished = false
    
    if self.currentFrame.count > 0
    {
      if self.expectFirstPacket
      {
        self.command = self.currentFrame[1]
        
        if (self.command > DeviceCommandType.RealPwr.rawValue)
        {
          print("Unknown command code received: \(self.command)")
          return
        }
        
        let commandType = DeviceCommandType(rawValue: self.command)!
        let resultType = DeviceCommand.getResultTypeByCommand(command: self.command)
        
        switch resultType
        {
          // Only binary data needs to be collected across multiple packets
        // Other types fit into a single packet and can be decoded immediately
        case .val_BIN:
          self.expectingBytes = Int(self.currentFrame[3]) << 8 | Int(self.currentFrame[2])
          
          self.receiveBuffer.append(contentsOf: self.currentFrame.suffix(from: 4))
          break
        case .val_STR:
          //TODO: Strings might be lengthy so potentially logic for BIN needs to be replicated here
          fallthrough
        case .chooser:
          fallthrough
        case .val_U8:
          fallthrough
        case .val_U16:
          fallthrough
        case .val_U32:
          fallthrough
        case .val_S8:
          fallthrough
        case .val_S16:
          fallthrough
        case .val_S32:
          fallthrough
        case .val_FLT:
          let value = DeviceCommand.getPacketValue(data: Data(self.currentFrame))
          
          // Store received and decoded value in a context
          self.deviceContext?.setValue(commandType, value: value as AnyObject?)
          
          // If ADMIN:CRC32 response received and value matches to previously calculated checksum from context => handshake passed successfully
          if self.handshakePassed && commandType == .CRC32 && value?.type == ResultType.val_U32
          {
            let calculatedCRC = self.deviceContext?.getCalculatedCRC32()
            if calculatedCRC == (value!.value as! UInt32)
            {
              self.handshakePassed = true
              
              // Notify subscribers that handshake passed for the device and normal workflow unblocked
              NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_DEVICE_HANDSHAKE_PASSED), object: self)
              
              // Debug
              print("Handshake passed successfully. Full workflow unblocked.")
              // End Debug
            }
          }
          
          
          // Debug
          self.dumpCommandPacket(data: Data(self.currentFrame))
          
          if value != nil
          {
            print("Decoded: \(String(describing: value!.type)) = \(DeviceCommand.printValue(commandType: commandType, valueTuple: value))")
          }
          else
          {
            print("Unable to parse value during decode")
          }
          // End Debug
          
          decodingFinished = true
        default:
          print("decodeData - unhandled data format")
          print(String(describing: resultType))
          self.dumpCommandPacket(data: Data(self.currentFrame))
          
          decodingFinished = true
        }
        
        self.expectFirstPacket = false
      }
      else
      {
        let resultType = DeviceCommand.getResultTypeByCommand(command: self.command)
        
        if resultType == .val_BIN
        {
          self.receiveBuffer.append(contentsOf: self.currentFrame.suffix(from: 1))
        }
      }
      
      // Logic for long BIN/STR data blocks only. All single-packet values for the rest of datatypes are handled in a switch case above
      if decodingFinished == false
      {
        if self.receiveBuffer.count < expectingBytes
        {
          self.expectMoreData = true
          
          print("\(String(self.receiveBuffer.count)) / \(String(self.expectingBytes))")
        }
        else
        {
          print("Full binary data received. Length: \(String(expectingBytes))")
          
          let commandType = DeviceCommandType(rawValue: self.command)!
          
          switch commandType
          {
          case .Tree:
            let compressedBuffer: [UInt8] = Array(self.receiveBuffer)
            let compressedData: Data = Data(compressedBuffer)
            
            // Calculate CRC32 over received ADMIN:TREE data (as-is, in compressed form)
            let crc: UInt32 = compressedData.getCrc32()
            
            // Store calculated CRC32 value in a context
            self.deviceContext?.setCalculatedCRC32(value: crc)
            
            // Initiate sending calculated CRC32 value to Mooshimeter device in order to complete handshake procedure
            let deviceEvent = DeviceEvent(UUID: self.device!.UUID, payload: crc as AnyObject?)
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_ADMINTREE_CRC32_READY), object: deviceEvent)
            
            // Decompress ADMIN:TREE data and store in a context
            let decompressedTree = self.decompressTreeData(data: compressedBuffer)
            if decompressedTree != nil
            {
              self.deviceContext?.adminTree = decompressedTree
            }
          case .Diagnostic:
            print(self.receiveBuffer)
          default:
            break
          }
          
          self.resetReceiveBufferState()
        }
      }
      else
      {
        self.resetReceiveBufferState()
      }
    }
  }
  
  func decompressTreeData(data: [UInt8]) -> [UInt8]?
  {
    var result: [UInt8]? = nil
    
    let compressedData: Data = Data(data)
    
    let decompressedData = compressedData.unzip()
    
    if decompressedData != nil
    {
      result =  [UInt8](decompressedData!)
    }
    
    return result
  }
  
  func resetReceiveBufferState()
  {
    self.currentFrame.removeAll(keepingCapacity: true)
    self.receiveBuffer.removeAll(keepingCapacity: true)
    
    self.expectFirstPacket = true
    self.expectMoreData = false
    self.expectingBytes = 0
  }
}
