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
  
  internal var deviceReady: Bool = false

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
    
    // Subscribe for notification when CRC32 calculated for AdminTree retrieved from the device
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.crc32Calculated),
      name: NSNotification.Name(rawValue: Constants.NOTIFICATION_ADMINTREE_CRC32_READY),
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
    let result = self.deviceCommandStream!.isHandshakePassed()
    
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
      let deviceEvent = DeviceEvent(UUID: self.UUID, payload: self)
      NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_DEVICE_READY), object: deviceEvent)
    }
  }
  
  @objc
  fileprivate func crc32Calculated(_ notification: Notification)
  {
    let object = notification.object
    
    if object != nil && (object as? DeviceEvent) != nil
    {
      let deviceEvent = object as! DeviceEvent
      let deviceUUID = deviceEvent.UUID
      
      if self.UUID == deviceUUID
      {
        let crc32 = deviceEvent.payload as! UInt32
      
        self.sendCRC32(crc: crc32)
      }
    }
  }
  
  //MARK: -
  //MARK: Helper methods
  
  func handleReadData(_ data: Data?)
  {
    self.deviceCommandStream?.handleReadData(data)
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
      
      self.setSamplingRate(SamplingRateType.Freq1000Hz)
      
      // Switching to continuous triggering mode activates streaming from the device side (multiple command+payload values transmitted as stream in several sequential packets)
      //self.setSamplingTrigger(SamplingTriggerType.Continuous)
    }
    
    
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
  
