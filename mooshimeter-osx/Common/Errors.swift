//
//  Errors.swift
//  mooshimeter-osx
//
//  Created by Dev on 5/18/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Foundation

enum CommandStreamPacketError: Error
{
  case emptyPacket
  case emptyDataPacket
  case packetNumOutOfOrder
  case badReadData
  case badWriteData
  case invalidCommand
}

enum CommandError: Error
{
  case emptyCommand
  case invalidCommand
  case incompletePayload
}
