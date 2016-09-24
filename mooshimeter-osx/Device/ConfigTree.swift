//
//  ConfigTree.swift
//  mooshimeter-osx
//
//  Created by Dev on 9/21/16.
//  Copyright © 2016 alfishe. All rights reserved.
//

import Foundation

enum ConfigNodeType: Int
{
  case PLAIN    = 0   // May be an informational node, or a choice in a chooser
  case LINK     = 1   // A link to somewhere else in the tree
  case CHOOSER  = 2   // The children of a CHOOSER can only be selected by one CHOOSER, and a CHOOSER can only select one child
  case VAL_U8   = 3   // These nodes have readable and writable values of the type specified
  case VAL_U16  = 4   // These nodes have readable and writable values of the type specified
  case VAL_U32  = 5   // These nodes have readable and writable values of the type specified
  case VAL_S8   = 6   // These nodes have readable and writable values of the type specified
  case VAL_S16  = 7   // These nodes have readable and writable values of the type specified
  case VAL_S32  = 8   // These nodes have readable and writable values of the type specified
  case VAL_STR  = 9   // These nodes have readable and writable values of the type specified
  case VAL_BIN  = 10  // These nodes have readable and writable values of the type specified
  case VAL_FLT  = 11  // These nodes have readable and writable values of the type specified
  case NOTSET   = -1  // May be an informational node, or a choice in a chooser
};

class ConfigNode: NSObject
{
  var code: Int8 = -1
  var type: ConfigNodeType = .NOTSET
  var name: String = ""
  var value: NSObject = NSObject()
  
  var children: [ConfigNode] = []
  weak var parent: ConfigNode?
  weak var tree: ConfigTree?
  
  init(tree: ConfigTree, type: ConfigNodeType, name: String)
  {
    self.tree = tree
    self.type = type
    self.name = name
  }

  override var description: String
  {
    var result = ""
    
    if self.code != -1
    {
      result += "\(code)"
      result += ":"
      result += "\(name)"
    }
    else
    {
      result += "\(name)"
    }

    
    if !children.isEmpty
    {
      result += " {" + children.map { $0.description }.joinWithSeparator(", ") + "} "
    }
    
    return result
  }
  
  func getIndex() -> Int
  {
    let result = self.parent?.children.indexOf(self)
    
    return result!
  }
  
  func addChild(child: ConfigNode)
  {
    children.append(child)
  }
  
  func getChild(name: String) -> ConfigNode?
  {
    let result = children.filter{ $0.name == name }.first
    
    return result
  }
  
  //MARK: External interfacing
  
  func parseValueString(value: String) -> NSObject?
  {
    var result: NSObject? = nil
    
    switch type
    {
      case .PLAIN:
        result = nil
      case .CHOOSER:
        result = Int(value)
      case .LINK:
        result = nil
      case .VAL_S8, .VAL_S16, .VAL_S32:
        result = Int(value)
      case .VAL_U8, .VAL_U16, .VAL_U32:
        result = UInt(value)
      case .VAL_STR:
        result = value
      case .VAL_BIN:
        print("parseValueString: VAL_BIN type not implemented yet")
      case .VAL_FLT:
        result = Float(value)
      default:
        result = nil
    }
    
    return result
  }
  
  func packToSerial(value: NSObject) -> NSMutableData
  {
    let result: NSMutableData = NSMutableData()
    
    var opcode: UInt8 = UInt8(self.code) | 0x80
    result.appendBytes(&opcode, length: 1)
    
    switch type
    {
      case .PLAIN:
        break
      case .CHOOSER:
        var byte = (value as! NSNumber).unsignedCharValue
        result.appendBytes(&byte, length: 1)
      case .VAL_U8, .VAL_S8:
        var byte = (value as! NSNumber).unsignedCharValue
        result.appendBytes(&byte, length: 1)
      case .VAL_U16, .VAL_S16:
        var short = (value as! NSNumber).unsignedShortValue
        result.appendBytes(&short, length: 2)
      case .VAL_U32, .VAL_S32:
        var long = (value as! NSNumber).unsignedIntegerValue
        result.appendBytes(&long, length: 4)
      case .VAL_STR:
        let strValue = String(value as! NSString)
        var len: Int = strValue.characters.count
        result.appendBytes(&len, length: 2)
        result.appendBytes(strValue, length: len)
      case .VAL_BIN:
        print("packToSerial: VAL_BIN type not implemented yet")
      case .VAL_FLT:
        var floatValue: Float = (value as! NSNumber).floatValue
        result.appendBytes(&floatValue, length: 4)
      default:
        print("packToSerial: Unknown node type")
    }
    
    return result
  }
}

class ConfigTree: NSObject
{
  weak var device: Device?
  
  var sendPacketNum: UInt8 = 0
  var rcvPacketNum: UInt8 = 0
  var rcvBuffer: NSMutableData = NSMutableData()
  
  //MARK: Methods
  
  func attach(device: Device)
  {
    self.device = device
  }
  
  func sendBytes(payload: NSData)
  {
    if payload.length > (Constants.DEVICE_PACKET_SIZE - 1)
    {
      print("Tree:sendBytes payload is too long \(payload.length)")
      return
    }
    
    let wrappedPayload: NSMutableData = NSMutableData(capacity: Constants.DEVICE_PACKET_SIZE)!
    
    // Prepend with packet number
    wrappedPayload.appendBytes(&sendPacketNum, length: 1)
    wrappedPayload.appendData(payload)
    
    let sentPacketNum: UInt8 = sendPacketNum
    
    sendPacketNum = sendPacketNum + 1
    
    // TODO: send data via device's write characteristic
  }
  
  /*
  -(void)sendBytes:(NSData*)payload {
  if(![self.meter isConnected]) {
  NSLog(@"Trying to talk to a disconnected meter");
  return;
  }
  if (payload.length > 19) {
  NSLog(@"Payload too long!");
  return;
  }
  NSMutableData* wrapped_payload = [NSMutableData dataWithCapacity:20];
  [wrapped_payload appendBytes:&_send_seq_n length:1]; // Sequence number, for keeping track of which packet is which
  [wrapped_payload appendData:payload];                // Payload data
  uint8 bind_seqn = _send_seq_n;
  _send_seq_n++;
  LGCharacteristic *c = [self.meter getLGChar:METER_SERIN];
  [c writeValue:wrapped_payload completion:^(NSError *error) {
  if(error) {
  NSLog(@"Badness on send");
  } else {
  NSLog(@"SENT: %u %u bytes",bind_seqn,wrapped_payload.length);
  }
  }];
 */
}
