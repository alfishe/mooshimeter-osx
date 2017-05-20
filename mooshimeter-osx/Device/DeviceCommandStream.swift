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
  internal var currentFrame: [UInt8] = [UInt8](repeating: UInt8(), count: Constants.DEVICE_PACKET_SIZE)
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
    // Just skip all exception handlers for initial version
    let packetVerified: Bool? = try? verifyPacket(data)
    
    if packetVerified != nil
    {
      let packetNum = data![0]
      let packetData = data!.subdata(in: 1...data!.count - 1)
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
      self.resetReceiveBufferState()
      
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
    
    let commandVerified = try? verifyCommand(commandData)

    if commandVerified != nil
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
          self.command = commandTypeByte
        
          let valueLength = Int(payloadData.to(type: UInt16.self))
          if valueLength > payloadData.count - 2  // 2 bytes block length value
          {
            // Binary or string data block does not fit into current packet. Expect more
            let valueChunk = payloadData.subdata(in: 2...payloadData.count - 1)
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

      // Store received and decoded value in a context
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
      else
      {
        // No more data to process - prepare for next packet
        self.resetReceiveBufferState()
      }
    }
    else
    {
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
            let decompressedTree = self.decompressTreeData(treeData: compressedBuffer)
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
  
  func decompressTreeData(treeData: [UInt8]) -> [UInt8]?
  {
    var result: [UInt8]? = nil
    
    let compressedData: Data = Data(treeData)
    
    let decompressedData = compressedData.unzip()
    
    if decompressedData != nil
    {
      result =  [UInt8](decompressedData!)
    }
    
    return result
  }
  
  //MARK: -
  //MARK: Helper methods
  func resetReceiveBufferState()
  {
    self.currentFrame.removeAll(keepingCapacity: true)
    self.receiveBuffer.removeAll(keepingCapacity: true)
    
    self.expectFirstPacket = true
    self.expectMoreData = false
    self.expectingBytes = 0
  }
}
