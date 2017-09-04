import Foundation
import CoreBluetooth

class Device: NSObject
{
  internal var readCharacteristic: CBCharacteristic?
  internal var writeCharacteristic: CBCharacteristic?
  internal var heartbeatTimer: Timer?
  
  internal let peripheral: CBPeripheral
  internal let UUID: String

  internal var deviceCommandStream: DeviceCommandStream? = nil
  internal var deviceContext: DeviceContext? = nil
  internal var measurementManager: MeasurementManager? = nil
  internal var deviceWatchDog: DeviceWatchDog? = nil
  
  internal var deviceReady: Bool = false
  internal var handshakePassed: Bool = false

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
    self.deviceCommandStream = DeviceCommandStream(device: self, context: self.deviceContext!)
    self.measurementManager = MeasurementManager(device: self)
    self.deviceWatchDog = DeviceWatchDog()
    
    
    // Subscribe for notification when ADMINTREE data retrieved from the device
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.adminTreeReceived(_:)),
      name: NSNotification.Name(rawValue: Constants.NOTIFICATION_ADMINTREE_RECEIVED),
      object: nil)
    
    // Subscribe for notification when handshake with device finished
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.handshakePassed(_:)),
      name: NSNotification.Name(rawValue: Constants.NOTIFICATION_ADMINTREE_RECEIVED),
      object: nil)
  }
  
  /*
   * Testing only constructor
   */
  init(UUID: String)
  {
    self.peripheral = CBPeripheral()
    self.UUID = UUID
    
    super.init()
    
    self.deviceContext = DeviceContext(device: self)
    self.deviceCommandStream = DeviceCommandStream(device: self, context: self.deviceContext!)
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
    
    // Reset session handshake passed flag
    self.handshakePassed = false
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
    return self.handshakePassed
  }
  
  func setCharacteristics(read: CBCharacteristic, write: CBCharacteristic)
  {
    self.readCharacteristic = read
    self.writeCharacteristic = write
    
    if self.isConnected()
    {
      self.deviceReady = true
      
      // Notify that device is fully initialized and ready
      let deviceEvent = DeviceEvent(UUID: self.UUID, payload: self)
      NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_DEVICE_READY), object: deviceEvent)
    }
  }
  
  //MARK: -
  //MARK: Event handlers
  @objc
  fileprivate func adminTreeReceived(_ notification: Notification)
  {
    let deviceEvent = getDeviceEvent(notification)
    
    if deviceEvent != nil
    {
      let eventData = deviceEvent!.payload as! DeviceStateChangeEvent
      let adminTreeData = eventData.value as! Data
      
      // Calculate crc32 value for compressed data block to complete session handshake with device
      let crc32 = calculateCRC32(adminTreeData)
      deviceContext?.setCalculatedCRC32(value: crc32)
      
      // Send calculated CRC32 to device
      self.sendCRC32(crc: crc32)
      
      // Decompress tree data (zlib)
      let decompressedTreeData = decompressAdminTreeData(adminTreeData)
      if decompressedTreeData != nil
      {
        // Decompressed data can be parsed to get initial value state
      }
    }
  }
  
  @objc
  fileprivate func handshakePassed(_ notification: Notification)
  {
    let deviceEvent = getDeviceEvent(notification)
    
    if deviceEvent != nil
    {
      self.handshakePassed = true
      
      // DEBUG
      testCommands()
      // End DEBUG
    }
  }
  
  //MARK: -
  //MARK: Helper methods
  
  func handleReadData(_ data: Data?)
  {
    if data != nil
    {
      self.deviceCommandStream?.handleReadData(data!)
    }
  }
  
  func getDeviceEvent(_ notification: Notification) -> DeviceEvent?
  {
    var result: DeviceEvent? = nil
    let object = notification.object
    
    if object != nil && (object as? DeviceEvent) != nil
    {
      let deviceEvent = object as! DeviceEvent
      let deviceUUID = deviceEvent.UUID
      
      if self.UUID == deviceUUID
      {
        result = deviceEvent
      }
    }
    
    return result
  }
  
  class func getDeviceEvent(_ notification: Notification, UUID: String) -> DeviceEvent?
  {
    var result: DeviceEvent? = nil
    let object = notification.object
    
    if object != nil && (object as? DeviceEvent) != nil
    {
      let deviceEvent = object as! DeviceEvent
      let deviceUUID = deviceEvent.UUID
      
      if UUID == deviceUUID
      {
        result = deviceEvent
      }
    }
    
    return result
  }
  
  func decompressAdminTreeData(_ compressedData: Data) -> Data?
  {
    let result = compressedData.unzip()
    
    return result
  }
  
  func calculateCRC32(_ data: Data) -> UInt32
  {
    let result = data.getCrc32()
    return result
  }
  
  func getNextSendPacketNum() -> UInt8
  {
    let result = (self.deviceCommandStream?.getNextSendPacketNum())!
    
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
      self.deviceCommandStream?.prepareForDataReceive()
    }
  }

    

  //MARK: -
  //MARK: Test debug code
  @objc
  private func heartbeatTimerFire(timer: Timer)
  {
    //self.getTime()
    //self.getTimeMs()
    
    //self.getChannel1Mapping()
    self.getChannel1Value()
    
    //self.getChannel2Mapping()
    self.getChannel2Value()
  }

  
  private func testCommands()
  {
    //TODO: Remove test commands
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3)
    {
      self.getPCBVersion()
      self.getChannel1Mapping()
      self.getChannel2Mapping()
      self.getSamplingRate()
      self.getSamplingDepth()
      self.getSamplingTrigger()
      self.getTime()
      self.getTimeMs()
      
      self.setSamplingRate(SamplingRateType.Freq125Hz)
      
      self.getChannel1Buffer()
      
      // Switching to continuous triggering mode activates streaming from the device side (multiple command+payload values transmitted as stream in several sequential packets)
      self.setSamplingTrigger(SamplingTriggerType.Continuous)
    }
    
    //return
  
    DispatchQueue.main.async
    {
      self.heartbeatTimer = Timer.scheduledTimer(
        timeInterval: 1,
        target: self,
        selector: #selector(self.heartbeatTimerFire(timer:)),
        userInfo: nil,
        repeats: true)
    }
    
    // End of Debug test commands
  }
}
  
