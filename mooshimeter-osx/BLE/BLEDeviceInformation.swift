//
// Created by Dev on 8/27/16.
// Copyright (c) 2016 alfishe. All rights reserved.
//

import Foundation

class BLEDeviceInformation: NSObject
{
    var manufacturerName: String?
    var modelNumber: String?

    var isSupported: Bool = false
    var manufacturerData: UInt32!
    var dataServiceUUID: String?
}
