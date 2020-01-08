//
//  Constants.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 18/9/2562 BE.
//  Copyright © 2562 JasonMac. All rights reserved.
//

import Foundation

// Boundaries for checking node does not go out of bounds
let kMinX = -3
let kMaxX = 3
let kMinY = -3
let kMaxY = 3
let kMinZ = -1
let kMaxZ = -6

// Max Friends Allowed
let kMinFriends = 1 // Not used at present as we will just add default friends if none available.
let kMaxFriends = 8

// In game messages:
let kHelperMsg0 = NSLocalizedString("Add and Remove Friends in Friends Screen", comment: "Helper Message")
let kHelperMsg1 = NSLocalizedString("Press Play to Play Game", comment: "Helper Message")
let kHelperMsg2 = NSLocalizedString("Shoot the Boxes - 4 Times to Kill", comment: "Helper Message")
let kHelperMsg3 = NSLocalizedString("When a Box Turns Black, One Shot Will Kill", comment: "Helper Message")
let kHelperMsg4 = NSLocalizedString("You Only Have 30 Seconds to Kill the Targets", comment: "Helper Message")
let kHelperMsg5 = NSLocalizedString("Go to the Settings to Change Game Level", comment: "Helper Message")

let kDefaultLabel = NSLocalizedString("Shoot 4 Times to Kill", comment: "Helper Message")
let kGameMsgLoading = NSLocalizedString("Loading Up Game ...", comment: "Helper Message")
let kGameMsgStart = NSLocalizedString("Press the Start Button", comment: "Helper Message")
let kGameMsgStart1 = NSLocalizedString("Hit the Start Button", comment: "Helper Message")
let kGameMsgExit = NSLocalizedString("Game Will Exit", comment: "Helper Message")
let kGameMsgTime = NSLocalizedString("You Have Ran Out Of Time", comment: "Helper Message")
let kGameMsgWon = NSLocalizedString("You Killed ALL Your Friends", comment: "Helper Message")

// Alerts
let kDefaultFriendsMsg = NSLocalizedString("Do you want to add your own friends? Click the Friends Button Below.", comment: "Helper Message")
let kDefaultExitBeforeSave = NSLocalizedString("You have not saved this Friend. Are you sure you want to leave this screen?", comment: "Helper Message")

// Constants for Default friends
let kDefaultFriend0 = NSLocalizedString("A1", comment: "Placeholder Player")
let kDefaultFriend1 = NSLocalizedString("A2", comment: "Placeholder Player")
let kDefaultFriend2 = NSLocalizedString("A3", comment: "Placeholder Player")
let kDefaultFriend3 = NSLocalizedString("A4", comment: "Placeholder Player")
let kDefaultFriend4 = NSLocalizedString("A5", comment: "Placeholder Player")
let kDefaultFriend5 = NSLocalizedString("A6", comment: "Placeholder Player")
let kDefaultFriendAdd = NSLocalizedString("B1", comment: "Placeholder Player")

