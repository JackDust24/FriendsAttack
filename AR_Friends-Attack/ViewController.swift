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
import CoreData

struct friend {
    var name = ""
}

enum BitMaskCategory: Int {
    case bullet = 2
    case target = 3
}

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    var managedContext: NSManagedObjectContext!

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    var gameStarted = false
    var targetsOnScreen = false
    var power: Float = 50
    var Target: SCNNode?
    
    var peopleAdded = 0
    
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
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.scene.physicsWorld.contactDelegate = self

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
            print("1. Add Friend")
            addFriends(numOfFriend: i)
        }
        
        print("Add Targets done")

        // No longer need the start button
        startButton.isHidden = true
        startButton.isEnabled = false
        targetsOnScreen = true
//        peopleAdded += 1
//
//        addFriends(numOfFriend: peopleAdded)
        
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        print("Handle Tap")
        
        // Don't need to do this if Game hasn't started.
        if !targetsOnScreen {
            print("Targets not on screen")

            return

        }
        
        if !gameStarted {
            // Get nodes moving.
            getTheNodesStarted()
            print("Nodes Started")
        }
        
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        bullet.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
        body.isAffectedByGravity = false
        bullet.physicsBody = body
        bullet.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
        bullet.physicsBody?.categoryBitMask = BitMaskCategory.bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
        self.sceneView.scene.rootNode.addChildNode(bullet)
        bullet.runAction(
            SCNAction.sequence([SCNAction.wait(duration: 2.0),
                                SCNAction.removeFromParentNode()])
        )
        
    }
    
    func addFriends(numOfFriend: Int) {
        
        var target = friend.init()

        switch numOfFriend {
            
        case 1:
            target.name = "Harsh"
            print("1.1 Add Friend")

        case 2:
            target.name = "Ploy"
            print("1.2 Add Friend")

        case 3:
            target.name = "Scotto"
            print("1.3 Add Friend")
            
        case 4:
            target.name = "Doug"
            print("1.3 Add Friend")
            
        case 5:
            target.name = "Ian"
            print("1.3 Add Friend")

        default:
            target.name = "Harsh"
            print("1.4 Add Friend")

        }
        
        addNodeToScene(nodeFriend: target.name)

    }
    
    func getTheNodesStarted() {
        
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "target" {
                print("Runing Block")
                
                //edit something
                let wait = SCNAction.wait(duration: 0.5)
                let nodeRotateAction = rotation(time: 15)
                let nodeAnimation = animateNode()
                let sequence = SCNAction.sequence([wait, nodeRotateAction, wait,  nodeAnimation])
                node.runAction(sequence)
            }
        }
        print("Game now true")
        
        gameStarted = true
    }
    
    func addNodeToScene(nodeFriend: String) {
        
        print("Add Node To Scene")

        // Create a new scene and set it's position
        let targetScene = SCNScene(named: "target.scnassets/target.scn")!
        let targetNode = targetScene.rootNode.childNode(withName: "target", recursively: false)
        
        print("Add Physics Body")
        
        // Position of node
        let x = randomNumbers(numA: -5, numB: 5.5)
        let y = randomNumbers(numA: -0.5, numB: 4)
        let z = randomNumbers(numA: -1, numB: -5)
        targetNode?.position = SCNVector3(x,y,z)
        
        // Physics Body
//        targetNode?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: boxNode!, options: nil))
////        print("Add Physics Body2")
//
        targetNode?.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        targetNode?.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
        
    
        // Add images
        self.addFace(nodeName: "faceFront", targetNode: targetNode!, imageName: nodeFriend)
        self.addFace(nodeName: "faceBack", targetNode: targetNode!, imageName: nodeFriend)
        self.addLabel(nodeName: "nameLabelLeft", targetNode: targetNode!, imageName: nodeFriend)
        self.addLabel(nodeName: "nameLabelRight", targetNode: targetNode!, imageName: nodeFriend)

        // self.addWalls(nodeName: "sideDoorB", portalNode: portalNode, imageName: "b-frontb")
        self.sceneView.scene.rootNode.addChildNode(targetNode!)
        print("Added Node")

        
    }
    
    // MARK: - Animation and random positioning
    
    
    func rotation(time: TimeInterval) -> SCNAction {
        print("Rotate")

        
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: time)
        let foreverRotation = SCNAction.repeatForever(rotation)
        
        return foreverRotation
    }
    
    
    func animateNode() -> SCNAction  {
        
        print("Animate")

        let waitStart = SCNAction.wait(duration: 0.25)
        let moveDown = SCNAction.move(by: SCNVector3(0, -2, 0), duration: 1)
        let moveUp = SCNAction.move(by: SCNVector3(0,2,0), duration: 1)
        let waitAction = SCNAction.wait(duration: 0.25)
        let hoverSequence = SCNAction.sequence([waitStart, moveUp,waitAction,moveDown])
        let loopSequence = SCNAction.repeatForever(hoverSequence)
       //  node.runAction(loopSequence)
        
        return loopSequence
        

    }
    
    func randomNumbers(numA: CGFloat, numB: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(numA - numB) + min(numA, numB)
    }
    
    // MARK: - Rendering
    
    
    func addFace(nodeName: String, targetNode: SCNNode, imageName: String) {
        
        print("Node Check - \(nodeName), \(targetNode), \(imageName)")

        let child = targetNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "target.scnassets/\(imageName).png")
        child?.renderingOrder = 200
//        if let mask = child?.childNode(withName: "mask", recursively: false) {
//            mask.geometry?.firstMaterial?.transparency = 0.000001
//        }
    }
    
    func addLabel(nodeName: String, targetNode: SCNNode, imageName: String) {
        
        print("Label Check - \(nodeName), \(targetNode), \(imageName)")
        let child = targetNode.childNode(withName: nodeName, recursively: true)
        let labelScene = addLabelText(text: imageName)
        child?.geometry?.firstMaterial?.diffuse.contents = labelScene
        child?.geometry?.firstMaterial?.isDoubleSided = true
        child?.renderingOrder = 200
    
    }
    
    func addLabelText(text: String) -> SKScene {
        let skScene = SKScene(size: CGSize(width: 200, height: 200))
        skScene.backgroundColor = UIColor.clear
        
        let rectangle = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 400, height: 400), cornerRadius: 10)
        rectangle.fillColor = #colorLiteral(red: 0.6235300899, green: 0.8764483929, blue: 1, alpha: 1)
        rectangle.strokeColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        rectangle.lineWidth = 5
        rectangle.alpha = 0.4
        let labelNode = SKLabelNode(text: text)
        labelNode.fontSize = 46
        labelNode.fontName = "SanFranciscoText-Bold"
        labelNode.position = CGPoint(x:100,y:100)
        skScene.addChild(rectangle)
        skScene.addChild(labelNode)
        print("Add label")

        
        return skScene
    }
    
    
    // For collision
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("physicsWorld")

        
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            self.Target = nodeA
        } else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            self.Target = nodeB
        }
        let confetti = SCNParticleSystem(named: "target.scnassets/Fire.scnp", inDirectory: nil)
        confetti?.loops = false
        confetti?.particleLifeSpan = 4
        confetti?.emitterShape = Target?.geometry
        let confettiNode = SCNNode()
        confettiNode.addParticleSystem(confetti!)
        confettiNode.position = contact.contactPoint
        self.sceneView.scene.rootNode.addChildNode(confettiNode)
        Target?.removeFromParentNode()
        
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

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

// Convert degrees to radians
extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/100}
}
