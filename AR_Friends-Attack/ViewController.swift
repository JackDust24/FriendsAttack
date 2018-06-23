//
//  ViewController.swift
//  AR_Friends-Attack
//
//  Created by JasonMac on 22/6/2561 BE.
//  Copyright © 2561 JasonMac. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

struct friend {
    var name = ""
}

enum BitMaskCategory: Int {
    case bullet = 2
    case target = 3
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        self.sceneView.autoenablesDefaultLighting = true
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    

    // TODO:
    /*
     // Create a struct to hold the image - done
     // Apply the image to the box - done
     // Random position - done
     // Random movement - done
     // Other objects - done
     // Shooting
     */
    
    // Set the scene to the view
    // sceneView.scene = target
    
    // MARK: - Buttons

    @IBAction func addTargets(_ sender: Any) {
        
        // Add the appropriate amount of targets
        let objectsToAdd = GameStateManager.sharedInstance().initialTargets
        
        for i in 1...objectsToAdd {
            addFriends(numOfFriend: i)
        }
    
    }
    
    func addFriends(numOfFriend: Int) {
        
        var target = friend.init()

        switch numOfFriend {
            
        case 1:
            target.name = "Harsh"
        case 2:
            target.name = "Ploy"
        case 3:
            target.name = "Scotto"
        default:
            target.name = "Harsh"
        }
        
        addNodeToScene(nodeFriend: target.name)

    }
    
    func addNodeToScene(nodeFriend: String) {
        
        // Create a new scene and set it's position
        let targetScene = SCNScene(named: "target.scnassets/target.scn")!
        let targetNode = targetScene.rootNode.childNode(withName: "target", recursively: false)
        
        // Position of node
        let x = randomNumbers(numA: -0.3, numB: 0.3)
        let y = randomNumbers(numA: -0.3, numB: 0.3)
        let z = randomNumbers(numA: -0.3, numB: 0.3)
        targetNode?.position = SCNVector3(x,y,z)
        
        // Add images
        self.addFace(nodeName: "faceFront", targetNode: targetNode!, imageName: nodeFriend)
        self.addFace(nodeName: "faceBack", targetNode: targetNode!, imageName: nodeFriend)
        //self.addWalls(nodeName: "sideDoorA", portalNode: portalNode, imageName: "b-frontA")
        // self.addWalls(nodeName: "sideDoorB", portalNode: portalNode, imageName: "b-frontb")
        
        self.sceneView.scene.rootNode.addChildNode(targetNode!)

        
        // Rotate object
        let nodeRotateAction = rotation(time: 8)
        targetNode?.runAction(nodeRotateAction)
        

        
        animateNode(node: targetNode!)
        
    }
    
    // MARK: - Animation and random positioning
    
    
    func rotation(time: TimeInterval) -> SCNAction {
        
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: time)
        let foreverRotation = SCNAction.repeatForever(rotation)
        
        return foreverRotation
    }
    
    
    func animateNode(node: SCNNode) {
        
        let moveDown = SCNAction.move(by: SCNVector3(0, -0.1, 0), duration: 1)
        let moveUp = SCNAction.move(by: SCNVector3(0,0.1,0), duration: 1)
        let waitAction = SCNAction.wait(duration: 0.25)
        let hoverSequence = SCNAction.sequence([moveUp,waitAction,moveDown])
        let loopSequence = SCNAction.repeatForever(hoverSequence)
        node.runAction(loopSequence)
        
        // self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    func randomNumbers(numA: CGFloat, numB: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(numA - numB) + min(numA, numB)
    }
    
    // MARK: - Rendering
    
    
    func addFace(nodeName: String, targetNode: SCNNode, imageName: String) {
        let child = targetNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Assets.xcassets/\(imageName).png")
//        child?.renderingOrder = 200
//        if let mask = child?.childNode(withName: "mask", recursively: false) {
//            mask.geometry?.firstMaterial?.transparency = 0.000001
//        }
    }
    
    func addLabel(nodeName: String, targetNode: SCNNode, imageName: String) {
        let child = targetNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Assets.xcassets/\(imageName).png")
        //child?.renderingOrder = 200
        
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    // MARK: - Session functions
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

// Convert degrees to radians
extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/100}
}
