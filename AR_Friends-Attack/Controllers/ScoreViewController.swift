//
//  ScoreViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 16/5/2562 BE.
//  Copyright © 2562 JasonMac. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {

    @IBOutlet weak var killsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // We don't use an optional here as there will always be a value even if zero
        let killsAndPoints = GameStateManager.sharedInstance().returnKillsAndPoints()
        let tKills = killsAndPoints.0
        let tPoints = killsAndPoints.1
        
        killsLabel.text = String(tKills)
        pointsLabel.text = String(tPoints)

        // Do any additional setup after loading the view.
    }

}