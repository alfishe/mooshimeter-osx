import Foundation
import CoreBluetooth

enum DeviceInputMode: Int8
{
  case NATIVE = 0
  case TEMP = 1
  case AUX_V = 2
  case RESISTANCE = 3
  case DIODE = 4
}

enum GainType: Int8
{
  case PGA_GAIN_1 = 0
  case PGA_GAIN_4 = 1
  case PGA_GAIN_12 = 2
  case PGA_IGNORE = 3
}

enum GPIOSetting: Int8
{
  case GPIO0 = 0
  case GPIO1 = 1
  case GPIO2 = 2
  case GPIO3 = 3
  case GPIO_IGNORE = 4
}

enum ISrcSetting: Int8
{
  case ISRC_OFF = 0
  case ISRC_LOW = 1
  case ISRC_MID = 2
  case ISRC_HIGH = 3
  case ISRC_IGNOR = 4
}

class Device: NSObject
{
  static let badreadData = "BADREAD".data(using: .ascii)
  static let badwriteData = "BADWRITE".data(using: .ascii)
  
  let peripheral: CBPeripheral
  let UUID: String
  
  private var readCharacteristic: CBCharacteristic?
  private var writeCharacteristic: CBCharacteristic?
  
  private var deviceReady: Bool = false
  
  // Receive/send variables
  private var receiveBuffer: [UInt8] = [UInt8]()
  private var currentFrame: [UInt8] = [UInt8](repeating: UInt8(), count: 20)
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
    
    self.resetSendPacketNum()
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
      let packetNum: UInt8 = self.currentFrame[0]
      
      if self.expectFirstPacket
      {
        self.command = self.currentFrame[1]
        let resultType = DeviceCommand.getResultTypeByCommand(command: self.command)
        
        switch resultType
        {
          case .val_BIN:
            self.expectingBytes = Int(self.currentFrame[3]) << 8 | Int(self.currentFrame[2])
          
            self.receiveBuffer.append(contentsOf: self.currentFrame.suffix(from: 4))
            break
          case .val_U16:
            let valuePart = self.currentFrame.suffix(from: 2)
            let valueData = Data(bytes: valuePart)
            let value: UInt16 = UInt16(littleEndian: valueData.withUnsafeBytes { $0.pointee })
            
            print(String(format: "val_U16=0x%x", value))
            
            decodingFinished = true
            break
          case .val_U32:
            let valuePart = self.currentFrame.suffix(from: 2)
            let valueData = Data(bytes: valuePart)
            let value: UInt32 = UInt32(littleEndian: valueData.withUnsafeBytes { $0.pointee })
            
            print(String(format: "val_U32=0x%x", value))
            
            decodingFinished = true
            break
          default:
            print("decodeData - unhandled data format")
            print(String(describing: resultType))
            self.dumpCommandPacket(data: Data(self.currentFrame))
            
            decodingFinished = true
            break
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
          
          let compressedBuffer: [UInt8] = Array(self.receiveBuffer)
          let compressedData: Data = Data(compressedBuffer)
          
          //let crc = compressedData.getCrc32()
          let crc: UInt32 = 0x14795c4a
          self.sendCRC32(crc: crc)
          //self.getDiagnostic()
          
          self.decompressTreeData(data: compressedBuffer)
          
          self.resetReceiveBufferState()
        }
      }
      else
      {
        self.resetReceiveBufferState()
      }
    }
  }
  
  func decompressTreeData(data: [UInt8])
  {
    let compressedData: Data = Data(data)
    
    let decompressedData = compressedData.unzip()
    //let decompressedData = try! compressedData.blockUnzip(skipCheckSumValidation: false)

    //self.dumpData(data: decompressedData)
    
    do
    {
      try decompressedData?.write(to: URL(fileURLWithPath: "/Users/dev/admTree.log"), options: .atomic)
    }
    catch
    {
      print(error)
    }
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
    let packetNumber = data.first!
    let commandTypeByte = data.suffix(from: 1).first!
    let commandType = DeviceCommandType(rawValue: commandTypeByte)!
    let commandTypeText = commandType.description
    let resultType = DeviceCommand.getResultTypeByCommand(command: commandTypeByte)
    
    print("")
    
    var text: String = "Pkt #\(String(format: "%u", packetNumber))"
    text = text + " Cmd: \(commandTypeText)"
    print(text)
    
    text = "Type: \(String(describing: resultType))"
    text += " Value: <TBD>"
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
  
  func getDiagnostic() -> Void
  {
    print("Getting Diagnostic...")
  
    var dataBytes: [UInt8] = [UInt8]()
    dataBytes.append(self.getNextSendPacketNum())
    dataBytes.append(DeviceCommand.getReadCommandCode(type: DeviceCommandType.Diagnostic))
    
    self.dumpData(data: Data(dataBytes))
    
    self.writeValueAsync(bytes: dataBytes)
  }

  //MARK: -
  //MARK: Time methods
  func getTime() -> Double
  {
    let result: Double = 0.0

    return result
  }

  func setTime(_ time: Double)
  {

  }

  //MARK: -
  //MARK: Sample rate methods
}
