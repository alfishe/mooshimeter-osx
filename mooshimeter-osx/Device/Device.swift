import Foundation
import CoreBluetooth

class Device: NSObject
{
  static let badreadData = "BADREAD".data(using: .ascii)
  static let badwriteData = "BADWRITE".data(using: .ascii)
  
  private var readCharacteristic: CBCharacteristic?
  private var writeCharacteristic: CBCharacteristic?
  private var heartbeatTimer: Timer?
  
  private var deviceReady: Bool = false
  let peripheral: CBPeripheral
  let UUID: String
  private var deviceContext: DeviceContext? = nil
  private var handshakePassed: Bool = false
  
  // Receive/send variables
  private var receiveBuffer: [UInt8] = [UInt8]()
  private var currentFrame: [UInt8] = [UInt8](repeating: UInt8(), count: Constants.DEVICE_PACKET_SIZE)
  private var expectFirstPacket: Bool = false
  private var expectMoreData: Bool = false
  private var receivePacketNum: UInt8 = 0
  private var sendPacketNum: UInt8 = 0
  
  // Command result parsing state
  private var command: UInt8 = 0
  private var expectingBytes: Int = 0

  //MARK: -
  //MARK: Class methods
  class func isDeviceSupported(_ version: UInt32) -> Bool
  {
    var result = false

    // Only versions after ... supported
    if version >= 1454355414
    {
      result = true
    }

    return result
  }

  //MARK: -
  //MARK: Initialization and status methods

  init(peripheral: CBPeripheral)
  {
    self.peripheral = peripheral
    self.UUID = peripheral.identifier.uuidString
    
    super.init()
    
    self.deviceContext = DeviceContext(device: self)
    
    self.resetSendPacketNum()
  }
  
  deinit
  {
    self.stop()
  }
  
  func stop()
  {
    // Stop heartbeat timer
    if self.heartbeatTimer != nil && (self.heartbeatTimer?.isValid)!
    {
      self.heartbeatTimer?.invalidate()
    }
    
    // Unsubscribe from any notifications
    NotificationCenter.default.removeObserver(self)
  }

  func isConnected() -> Bool
  {
    var result = false

    if peripheral.state == .connected
    {
      result = true
    }

    return result
  }
  
  func isHandshakePassed() -> Bool
  {
    let result = self.handshakePassed
    
    return result
  }
  
  func setCharacteristics(read: CBCharacteristic, write: CBCharacteristic)
  {
    self.readCharacteristic = read
    self.writeCharacteristic = write
    
    if self.isConnected()
    {
      self.deviceReady = true
      
      // Notify that device is fully initialized and ready
      NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_DEVICE_READY), object: self)
    }
  }

  func isStreaming() -> Bool
  {
    let result = false

    return result
  }
  
  //MARK: -
  //MARK: Helper methods
  
  // Packet numeration starts from 1
  // Firmware doesn't like zero packet num and returns an error
  func resetSendPacketNum() -> Void
  {
    self.sendPacketNum = 221
  }
  
  func prepareForDataReceive() -> Void
  {
    self.currentFrame.removeAll(keepingCapacity: true)
    self.receiveBuffer.removeAll(keepingCapacity: true)
    
    self.expectFirstPacket = true
    self.expectMoreData = false
    self.expectingBytes = 0
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
  
  func writeValueSync()
  {
    // Use Async wrapper to encapsulate wait for async logic. Can be implemented at least two ways using native GCD calls
    // dispatch_group_create + dispatch_group_enter + dispatch_group_leave + dispatch_group_wait
    // or dispatch_semaphore_create + dispatch_semaphore_signal + dispatch_semaphore_wait
    let group = AsyncGroup()
    
    // Execute as async block
    group.background
    {
        print("writeValueSync executed on the background queue")
    }
    
    // But wait until it completes
    group.wait()
  }
  
  func writeValueAsync(value: String)
  {
    let data = value.data(using: .utf8)!
    
    self.writeValueAsync(data: data)
  }
  
  func writeValueAsync(bytes: [UInt8])
  {
    let data: Data = Data(bytes: bytes)

    self.writeValueAsync(data: data)
  }
  
  func writeValueAsync(data: Data)
  {
    if writeCharacteristic != nil
    {
      self.peripheral.writeValue(data, for: self.writeCharacteristic!, type: .withResponse)
      self.prepareForDataReceive()
    }
  }

  func handleReadData(_ data: Data?)
  {
    if let unwrappedData = data
    {
      if unwrappedData.count > 0
      {
        let packetNum: UInt8 = unwrappedData[0]
        
        if unwrappedData.contains(Device.badreadData)
        {
          print("Bad read data received. Packet #\(String(packetNum))")
          
          self.resetReceiveBufferState()
        }
        else if unwrappedData.contains(Device.badwriteData)
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
          //self.dumpPacket(packetNum: packetNum, data: unwrappedData)
        }
        
        self.receivePacketNum = packetNum
      }
    }
  }
  
  func resetReceiveBufferState()
  {
    self.currentFrame.removeAll(keepingCapacity: true)
    self.receiveBuffer.removeAll(keepingCapacity: true)
    
    self.expectFirstPacket = true
    self.expectMoreData = false
    self.expectingBytes = 0
  }
  
  func decodeData()
  {
    var decodingFinished = false
    
    if self.currentFrame.count > 0
    {
      if self.expectFirstPacket
      {
        self.command = self.currentFrame[1]
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
            if !self.handshakePassed && commandType == .CRC32 && value?.type == ResultType.val_U32
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
            print("Decoded: \(String(describing: value!.type)) = \(DeviceCommand.printValue(commandType: commandType, valueTuple: value))")
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
              
              // Send calculated CRC32 value to Mooshimeter device in order to complete handshake procedure
              self.sendCRC32(crc: crc)
              
              // Decompress ADMIN:TREE data and store in a context
              let decompressedTree = self.decompressTreeData(data: compressedBuffer)
              if decompressedTree != nil
              {
                self.deviceContext?.adminTree = decompressedTree
              }
            
              //TODO: Remove test commands
              self.getPCBVersion()
              self.getSamplingRate()
              self.getTime()
              self.getTimeMs()
              self.setSamplingRate(SamplingRateType.Freq125Hz)
              self.getSamplingRate()
            
              DispatchQueue.main.async
              {
                if #available(OSX 10.12, *)
                {
                  self.heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true)
                  { timer in
                    self.getTime()
                    self.getTimeMs()
                  }
                }
                else
                {
                  self.heartbeatTimer = Timer.scheduledTimer(
                    timeInterval: 1,
                    target: self,
                    selector: #selector(self.heartbeatTimerFire(timer:)),
                    userInfo: nil,
                    repeats: true)
                }
              }
            // End of Debug test commands
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
    //let decompressedData = try! compressedData.blockUnzip(skipCheckSumValidation: false)
    
    if decompressedData != nil
    {
      result =  [UInt8](decompressedData!)
    }
    
    return result
  }
  
  @objc
  private func heartbeatTimerFire(timer: Timer)
  {
    self.getTime()
    self.getTimeMs()
  }
  
  //MARK: -
  //MARK: - Debug methods
  func dumpPacket(packetNum: UInt8, data: Data) -> Void
  {
    var text: String = "Packet #\(String(packetNum))"
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
    let result = data!.map{ String(format: "%02x ", $0) }.joined()
    
    return result
  }
  
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
  //MARK: Sample rate methods
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
}
