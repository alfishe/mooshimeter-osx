//
//  LargeIndicator.swift
//  mooshimeter-osx
//
//  Created by Dev on 5/24/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Cocoa
import QuartzCore

@IBDesignable
class LargeIndicatorView: NSView
{
  @IBOutlet weak var lblMode: NSTextField!
  @IBOutlet weak var lblSign: NSTextField!
  @IBOutlet weak var lblValue: NSTextField!
  
  required init(coder: NSCoder)
  {
    super.init(coder: coder)!
    
    
    var topLevelObjects = NSArray()
    var view: NSView? = nil
    let frameworkBundle = Bundle(for: classForCoder)
    if frameworkBundle.loadNibNamed("LargeIndicatorView", owner: self, topLevelObjects: &topLevelObjects)
    {
      let views = (topLevelObjects as Array).filter { $0 is NSView }
      if views.count > 0
      {
        view = views[0] as? NSView
      }
    }
    
    // Use bounds not frame or it'll be offset
    view?.frame = bounds
    
    // Make the view stretch with containing view
    view?.autoresizingMask = [NSAutoresizingMaskOptions.viewWidthSizable, NSAutoresizingMaskOptions.viewHeightSizable]
    
    if view != nil
    {
      self.addSubview(view!)
    }
  }
}
