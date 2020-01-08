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
    
    // MARK: Properties
    // Use this bool to see if app is already in use
    var gameStarted = Bool()
    
    // Game Level initial settingsWe can change these depending on the level
    var kStartTime: Double = 40.0
    var kGameSpeed = 0.8 // This can be changed
    var currentGameLevel = GameLevel.medium
    // Different Game level options
    let gameLevels = [String](arrayLiteral: NSLocalizedString("Easy", comment: "Game Level"), NSLocalizedString("Medium", comment: "Game Level"), NSLocalizedString("Hard", comment: "Game Level"))
    
    public enum GameLevel: String, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        
        // Add this for localization
        func localizedString() -> String {
            switch self {
            case .easy:
                return NSLocalizedString("Easy", comment: "Game Level")
            case .medium:
                return NSLocalizedString("Medium", comment: "Game Level")
            case .hard:
                return NSLocalizedString("Hard", comment: "Game Level")

            }
        }
    }
    
    // MARK: Instances & Initializers
    // Shared Instance to get scores etc
    public class func sharedInstance() -> GameStateManager {
        return GameStateManagerInstance
    }
    
    override init() {
        super.init()
    }
    
    // MARK: App Starting and setup
    func checkIfAppStarting() -> Bool {
        
        // If bool already set, no need to show Inital Messages for helping user
        if gameStarted == true {
            return false
        }
        // Set game to start
        gameStarted = true
        return true
    }
    
    // MARK: Changing Game Level Difficulty
    // 1. This will get called by the Settings screen if the text changes
    func changeLevel(newLevel: String) {
        
        if newLevel == NSLocalizedString("Easy", comment: "Game Level") {
            settingsGameLevel(level: GameLevel.easy)
        } else if newLevel == NSLocalizedString("Medium", comment: "Game Level") {
            settingsGameLevel(level: GameLevel.medium)
        } else if newLevel == NSLocalizedString("Hard", comment: "Game Level") {
            settingsGameLevel(level: GameLevel.hard)
        }
//        print(GameLevel.allCases[0].localizedString())
    }
    
    // 2. Set the game settings
    func settingsGameLevel(level: GameLevel) {
        
        switch level {
        case .easy:
            kStartTime = 60.0
            kGameSpeed = 1.5
            currentGameLevel = .easy
        case .medium:
            kStartTime = 40.0
            kGameSpeed = 0.8
            currentGameLevel = .medium
        case .hard:
            kStartTime = 30.0
            kGameSpeed = 0.4
            currentGameLevel = .hard
        }
        // Save into defaults
        saveGameLevelSettings()
    }
    
    // 3. Save onto User Defaults
    func saveGameLevelSettings() {
        let defaults = UserDefaults.standard
        defaults.set(currentGameLevel.rawValue, forKey: "gameLevel")
        defaults.set(kStartTime, forKey: "startTime")
        defaults.set(kGameSpeed, forKey: "gameSpeed")

    }
    
    // We call this to get the game level at load up to set the game level
    func initialGameLoad() {
        
        // We see if there are Defaults set for speed etc
        let defaults = UserDefaults.standard
        if UserDefaults.standard.object(forKey: "gameLevel") != nil {
            let gameLevel = defaults.string(forKey: "gameLevel")
            currentGameLevel = GameStateManager.GameLevel(rawValue: gameLevel!)!
        }
        
        if UserDefaults.standard.object(forKey: "startTime") != nil {
            kStartTime = defaults.double(forKey: "startTime")
        }
        
        if UserDefaults.standard.object(forKey: "gameSpeed") != nil {
            kGameSpeed = defaults.double(forKey: "gameSpeed")
        }
    }
    
    // MARK: Game Stats
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
        
        // Set the Defaults
        defaults.set(newPoints, forKey: "pointsKey")
        defaults.set(newKills, forKey: "killsKey")
    }
    
    // When we retrieve the scoress
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

// MARK: Singleton
// The Singleton to call
private let GameStateManagerInstance = GameStateManager()

