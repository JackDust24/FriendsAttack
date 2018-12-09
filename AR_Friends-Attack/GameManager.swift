//
//  GameManager.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 23/6/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import Foundation
import UIKit

class GameStateManager: NSObject {
    
    public var gameLevel: Int = 1
    public var initialTargets: Int = 5
    public class func sharedInstance() -> GameStateManager {
        return GameStateManagerInstance
    }
    
    override init() {
        super.init()
        print("Init GameStateManager")
    }
    
}

private let GameStateManagerInstance = GameStateManager()

