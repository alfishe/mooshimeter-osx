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
  internal var receiveBuffer: Data = Data()
  internal var expectFirstPacket: Bool = true
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
    resetReceiveBufferState()
  }
  
  //MARK: -
  //MARK: Data receive processor
  func handleReadData(_ data: Data)
  {
    // Debug
    // let hex = data.hexBytesEncodedString()
    // print(hex)
    
    // Just skip all exception handlers for initial version
    let packetVerified: Bool? = try? verifyPacket(data)
    
    if packetVerified != nil
    {
      let packetNum = data[0]
      let packetData = data.subdata(in: 1...data.count - 1)
      parsePacket(packetData)
      
      self.receivePacketNum = packetNum
    }
  }
  
  //MARK: -
  //MARK: Verification
  func verifyPacket(_ packet: Data?) throws -> Bool
  {
    let result: Bool = true
    
    // Check 1: BLE packet is not empty
    if packet == nil || packet!.count == 0
    {
      throw CommandStreamPacketError.emptyPacket
    }
    
    // Check 2: Packet number is in sequence (no packets missed)
    let packetNum: UInt8 = packet![0]
    if packetNum != self.receivePacketNum &+ 1
    {
      throw CommandStreamPacketError.packetNumOutOfOrder
    }
    
    let dataPacket = packet!.subdata(in: 1...packet!.count - 1)
    
    // Check 3: Data packet is not empty
    if dataPacket.count == 0
    {
      throw CommandStreamPacketError.emptyDataPacket
    }
    
    // Check 4: Verify that the device didn't respond either with BADREAD or BADWRITE values
    if dataPacket.contains(DeviceCommandStream.BadreadData)
    {
      throw CommandStreamPacketError.badReadData
    }
    else if dataPacket.contains(DeviceCommandStream.BadwriteData)
    {
      throw CommandStreamPacketError.badWriteData
    }
    
    return result
  }
  
  func verifyCommand(_ commandData: Data) throws -> Bool
  {
    let result: Bool = true
    
    // Check 1: Data bytes are not empty
    if commandData.count == 0
    {
      throw CommandError.emptyCommand
    }
    
    let commandType: UInt8 = commandData[0]
    
    // Check 2: Check that command is valid (command code is correct)
    if commandType > DeviceCommandType.RealPwr.rawValue
    {
      throw CommandError.invalidCommand
    }

    
    let resultType = DeviceCommand.getResultTypeByCommand(command: commandType)
    let resultSize = DeviceCommand.getResultSizeType(resultType)
    
    // Check 3: Check that payload is presented in full
    if resultSize == 0
    {
      // Nothing to do
    }
    else
    {
      if commandData.count == 1
      {
        throw CommandError.incompletePayload
      }
      
      let payloadData = commandData.subdata(in: 1...commandData.count - 1)
      let payloadSize = payloadData.count
      
      if resultSize == Constants.DEVICE_COMMAND_PAYLOAD_VARIABLE_LEN
      {
        // Variable length result has 2 bytes value for real length
        if payloadSize < 2
        {
          throw CommandError.incompletePayload
        }
      
        let realLength = Int(payloadData.to(type: UInt16.self))
        if payloadSize - 2 < realLength
        {
          throw CommandError.incompletePayload
        }
      }
      else
      {
        if payloadSize < resultSize
        {
          throw CommandError.incompletePayload
        }
      }
    }
    
    return result
  }
  
  //MARK: -
  //MARK: Decode
  func parsePacket(_ packetData: Data)
  {
    var dataBlock: Data
    
    if self.expectFirstPacket
    {
      // New packet should start from command. It's not a tail of previously started data stream
      self.resetReceiveBufferState()
      dataBlock = packetData
    }
    else
    {
      // Packet will be parsed as a tail of previously started data stream
      dataBlock = self.receiveBuffer
      dataBlock.append(packetData)
    }
    
    var moreDataAvailable = false
    
    repeat
    {
      do
      {
        moreDataAvailable = try parseCommand(&dataBlock)
      }
      catch CommandError.incompletePayload
      {
        
      }
      catch let error
      {
        //print(error.localizedDescription)
      }
    }
    while moreDataAvailable
  }
  
  func parseCommand(_ commandData: inout Data) throws -> Bool
  {
    var result = false
    var value: AnyObject? = nil
    
    var commandCheckEnabled = true
    var commandVerified = false
    var incompletePayload = false
    var pendingDataBlockDownload = false

    // If we're expeting large BIN or STR data - disable command check (packet and the whole receive buffer contains no command, just accumulated data)
    if self.command != 0xFF && self.expectingBytes > 0
    {
      let resultType = DeviceCommand.getResultTypeByCommand(command: self.command)
      if resultType == .val_BIN || resultType == .val_STR
      {
        commandCheckEnabled = false
        pendingDataBlockDownload = true
      }
    }

    // Verify command validity
    // For BIN and STR types we need to pass with incompletePayload error
    if commandCheckEnabled
    {
      do
      {
        commandVerified = try verifyCommand(commandData)
      }
      catch CommandError.incompletePayload
      {
        commandVerified = true
        incompletePayload = true
      }
      catch is Error
      {
        // Do nothing for now
      }
    }
      
    if commandVerified == true
    {
      let commandTypeByte: UInt8 = commandData[0]
      let commandType = DeviceCommandType(rawValue: commandTypeByte)!
      let payloadData = commandData.subdata(in: 1...commandData.count - 1)
      let payloadSize = payloadData.count
      let resultType = DeviceCommand.getResultTypeByCommand(command: commandTypeByte)
      let resultSize = DeviceCommand.getResultSizeType(resultType)
      var leftoverSize = 0
      
      switch resultType
      {
        case .val_BIN:
          fallthrough
        case .val_STR:
          let valueLength = Int(payloadData.to(type: UInt16.self))
          if valueLength > payloadData.count - 2  // 2 bytes block length value
          {
            // Binary or string data block does not fit into current packet. Expect more
            let valueChunk = payloadData.subdata(in: 2...payloadData.count - 1)
            
            self.command = commandTypeByte
            self.expectingBytes = valueLength
            self.receiveBuffer.append(valueChunk)
            self.expectMoreData = true
            self.expectFirstPacket = false
          }
          else
          {
            // Data block fits current packet
            let valueData = payloadData.subdata(in: 2...valueLength + 1) // [2: 2 + valuelength - 1]

            if resultType == .val_BIN
            {
              value = [UInt8](valueData) as AnyObject?
            }

            if resultType == .val_STR
            {
              value = String(data: valueData, encoding: String.Encoding.utf8) as AnyObject?
            }

            leftoverSize = payloadData.count - 2 - valueLength
          }
        default:
          let payload = payloadData.subdata(in: 0...resultSize - 1)
          value = DeviceCommand.getValue(resultType: resultType, data: payload)
          leftoverSize = payloadSize - resultSize
          break
      }

      // Store received and decoded value in a context (all subscribers will be notified automatically)
      if value != nil
      {
        let tupleValue = (type: resultType, value: value!)
        self.deviceContext?.setValue(commandType, value: tupleValue as AnyObject?)
      }

      if leftoverSize > 0
      {
        // Report about data bytes left unprocessed
        commandData = commandData.subdata(in: commandData.count - leftoverSize...commandData.count - 1)
        result = true
      }
      else if !incompletePayload
      {
        // No more data to process - prepare for next packet
        self.resetReceiveBufferState()
      }
    }
    else if pendingDataBlockDownload
    {
      let receivedLen = self.receiveBuffer.count
      let packetLen = commandData.count
      
      if receivedLen + packetLen >= self.expectingBytes
      {
        // All expected data received
        self.receiveBuffer.append(commandData)
        
        let commandType = DeviceCommandType(rawValue: self.command)!
        let resultType = DeviceCommand.getResultTypeByCommand(command: self.command)
        let value = self.receiveBuffer.subdata(in: 0...expectingBytes - 1)
        
        // Store received and decoded value in a context (all subscribers will be notified automatically)
        let tupleValue = (type: resultType, value: value)
        self.deviceContext?.setValue(commandType, value: tupleValue as AnyObject?)
      }
      else
      {
        // More data needed
        self.receiveBuffer.append(commandData)
      }
    }
    else if incompletePayload
    {
      // More data need to be received
      self.expectFirstPacket = false
      self.expectMoreData = true
      self.receiveBuffer.removeAll()
      
      if commandData.count > 0
      {
        self.receiveBuffer.append(commandData)
      }
    }
    
    return result
  }
  
  func decompressTreeData(treeData: [UInt8]) -> [UInt8]?
  {
    var result: [UInt8]? = nil
    
    let compressedData: Data = Data(treeData)
    
    let decompressedData = compressedData.unzip()
    
    if decompressedData != nil
    {
      result = [UInt8](decompressedData!)
    }
    
    return result
  }
  
  //MARK: -
  //MARK: Helper methods
  func resetReceiveBufferState()
  {
    self.command = 0xFF
    self.receiveBuffer.removeAll(keepingCapacity: true)
    
    self.expectFirstPacket = true
    self.expectMoreData = false
    self.expectingBytes = 0
  }
}
