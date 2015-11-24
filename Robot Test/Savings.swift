//
//  Savings.swift
//  Robot Test
//
//  Created by Clement Gires on 5/2/15.
//  Copyright (c) 2015 test. All rights reserved.
//

import Foundation

class Savings: NSObject, NSCoding {
    var bestLevel:Int
    
    init(bestLevel:Int) {
        self.bestLevel = bestLevel
          }
    
    required init(coder: NSCoder) {

        self.bestLevel = coder.decodeObjectForKey("bestLevel")! as! Int
        super.init()
        
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.bestLevel, forKey: "bestLevel")
    }
}