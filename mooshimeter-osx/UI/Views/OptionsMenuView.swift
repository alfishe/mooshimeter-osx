//
//  OptionsMenu.swift
//  mooshimeter-osx
//
//  Created by Dev on 5/20/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Foundation
import AppKit
import QuartzCore

class OptionsMenuView: NSView
{
  required init(coder: NSCoder)
  {
    super.init(coder: coder)!
    
    var topLevelObjects = NSArray()
    var view: NSView? = nil
    let frameworkBundle = Bundle(for: classForCoder)
    if frameworkBundle.loadNibNamed("OptionsMenuView", owner: self, topLevelObjects: &topLevelObjects)
    {
      let views = (topLevelObjects as Array).filter { $0 is NSView }
      if views.count > 0
      {
        view = views[0] as? NSView
      }
    }
    
    if view != nil
    {
      self.addSubview(view!)
    }
  }
}
