//
//  GameManager.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 23/6/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//
// This is for all the data that's relevant for when the game is running

import Foundation
import UIKit

class GameStateManager: NSObject {
    
    public var gameLevel: Int = 1 // Need to decide if there will be higher levels etc
    public var initialTargets: Int = 1
    
    // Shared Instance to get scores etc
    public class func sharedInstance() -> GameStateManager {
        return GameStateManagerInstance
    }
    
    override init() {
        super.init()
        print("Init GameStateManager")
    }
    
    // WHen we save our score we store here
    func savePointsAndKills(kills: Int, points: Int) {
        
        // Creeate temp totals of zero
        var pointsTemp = 0
        var killsTemp = 0
        // Get the UserDefaults
        let defaults = UserDefaults.standard
    
        // Extract and manipulate the temp scores if a score already exists
        if UserDefaults.standard.object(forKey: "pointsKey") != nil {
            pointsTemp = defaults.integer(forKey: "pointsKey")
            
        }
        
        if UserDefaults.standard.object(forKey: "killsKey") != nil {
            killsTemp = defaults.integer(forKey: "killsKey")
            
        }
        
        // Get new totals
        let newPoints = pointsTemp + points
        let newKills = killsTemp + kills
        
        print("New Kills - \(newKills) New Points - \(newPoints)")

        // Set the Defaults
        defaults.set(newPoints, forKey: "pointsKey")
        defaults.set(newKills, forKey: "killsKey")
        
    }
    
    func returnKillsAndPoints() -> (Int, Int) {
        
        // Creeate temp totals of zero
        var pointsTemp = 0
        var killsTemp = 0
        // Get the UserDefaults
        let defaults = UserDefaults.standard
        
        // Extract and manipulate the temp scores if a score already exists
        if UserDefaults.standard.object(forKey: "pointsKey") != nil {
            pointsTemp = defaults.integer(forKey: "pointsKey")
            
        }
        
        if UserDefaults.standard.object(forKey: "killsKey") != nil {
            killsTemp = defaults.integer(forKey: "killsKey")
            
        }
        
        return (killsTemp, pointsTemp)
    
    }
    
}

// The Singleton to call
private let GameStateManagerInstance = GameStateManager()

