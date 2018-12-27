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
    case target = 2
    case bullet = 3
}

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    var managedContext: NSManagedObjectContext!

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    var gameStarted = false
    var targetsOnScreen = false
    var power: Float = 50
    var target: SCNNode?
    var testOne = false
    
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
            // getTheNodesStarted()
            print("Nodes Started")
        }
        
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
        bullet.name = "bullet"
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
    
    func addRotation(node: SCNNode) {
        let rotateOne = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 25.0)
        
        let backwards = rotateOne.reversed()
        let rotateSequence = SCNAction.sequence([rotateOne, backwards])
        let repeatForever = SCNAction.repeatForever(rotateSequence)
        node.runAction(repeatForever)
    }
    
    func getTheNodesStarted() {
        
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "target" {
                print("Runing Block")
                
                // addRotation(node: node)
                
                if testOne { return }
                
                print("Test Node One")

                
                testOne = true
                
                //edit something
//                let wait = SCNAction.wait(duration: 0.5)
//                let nodeRotateAction = rotation(time: 10)
//                let nodeRotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 5.0)
//                let foreverRotation = SCNAction.repeatForever(nodeRotation)
//                let nodeAnimation = animateNode()
//                let sequence = SCNAction.sequence([wait, nodeRotateAction, wait,  nodeAnimation])
//                let loopSequence = SCNAction.repeatForever(nodeAnimation)
//                node.runAction(foreverRotation)
                
                let rotateOne = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi), z: 0, duration: 5.0)
                
                let backwards = rotateOne.reversed()
                let rotateSequence = SCNAction.sequence([rotateOne, backwards])
                let repeatForever = SCNAction.repeatForever(rotateSequence)
                node.runAction(repeatForever)
            }
        }
        print("Game now true")
        
        gameStarted = true
    }
    
    func addNodeToScene(nodeFriend: String) {
        
        print("Add Node To Scene")
        
        let targetParent = SCNNode()

        // Create a new scene and set it's position
        let targetScene = SCNScene(named: "target.scnassets/target.scn")!
        let targetNode = targetScene.rootNode.childNode(withName: "target", recursively: true)!
        targetNode.name = nodeFriend
        let childNode = targetNode.childNode(withName: "box", recursively: false)
        
        print("targetNode.name \(targetNode.name)")
        print("childNode \(childNode?.name)")
        childNode?.name = nodeFriend

        
        // Position of node
        let x = randomNumbers(numA: -5, numB: 5.5)
        let y = randomNumbers(numA: -0.5, numB: 4)
        let z = randomNumbers(numA: -1, numB: -5)
        targetNode.position = SCNVector3(x,y,z)
        
        // Physics Body
//        targetNode.physicsBody?.type = .dynamic
//        targetNode.physicsBody?.isAffectedByGravity = true
//        print("Add Physics Body2")
//
        targetNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        targetNode.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
        
    
        // Add images
        self.addFace(nodeName: "faceFront", targetNode: targetNode, imageName: nodeFriend)
        self.addFace(nodeName: "faceBack", targetNode: targetNode, imageName: nodeFriend)
        self.addLabel(nodeName: "nameLabelLeft", targetNode: targetNode, imageName: nodeFriend)
        self.addLabel(nodeName: "nameLabelRight", targetNode: targetNode, imageName: nodeFriend)
    
        
        // self.addWalls(nodeName: "sideDoorB", portalNode: portalNode, imageName: "b-frontb")
        
        self.sceneView.scene.rootNode.addChildNode(targetNode)

        
        let waitRandom = randomNonWholeNumbers(numA: 3, numB: 0)
        print("Waitrandom Check \(waitRandom)")
        
        let wait = SCNAction.wait(duration: TimeInterval(waitRandom))
        let parentRotation = rotation(time: 4)
        let nodeAnimation = animateNode()
        let sequence = SCNAction.sequence([parentRotation, wait, nodeAnimation])
        let loopSequence = SCNAction.repeatForever(sequence)
       // node.runAction(sequence)
        targetNode.runAction(loopSequence)
        
        //targetParent.addChildNode(targetNode)
        
        print("Added Node")
    
    }
    
    // MARK: - Animation and random positioning
    
    
    func rotation(time: TimeInterval) -> SCNAction {
        print("Rotate")
        
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: time)
        
//        let rotation = SCNAction.rotateBy(x: (CGFloat(node.position.x) - x), y: CGFloat(CGFloat(node.position.y) - CGFloat(Float.pi)), z: 0, duration: time)
        let foreverRotation = SCNAction.repeatForever(rotation)
        
        return rotation
    }
    
    
    func animateNode() -> SCNAction  {
        
        print("Animate")

        let randomMinus = randomNonWholeNumbers(numA: 0, numB: -2)
        let randomPlus = randomNonWholeNumbers(numA: 2, numB: 0)
        let waitRandom = randomNonWholeNumbers(numA: 1, numB: 0)
        print("Waitrandom Check  2 \(waitRandom) randomMinus \(randomMinus) randomPlus \(randomPlus)")
        
        let wait = SCNAction.wait(duration: TimeInterval(waitRandom))
        let moveDown = SCNAction.move(by: SCNVector3(0, randomMinus, 0), duration: 0.5)
        let moveUp = SCNAction.move(by: SCNVector3(0, randomPlus,0), duration: 0.5)
        let moveLeft = SCNAction.move(by: SCNVector3(randomMinus, 0, 0), duration: 0.5)
        let moveRight = SCNAction.move(by: SCNVector3(randomPlus,0,0), duration: 0.5)
        let hoverSequence = SCNAction.sequence([wait, moveUp, wait, moveLeft, wait, moveDown, wait, moveRight])
        let loopSequence = SCNAction.repeatForever(hoverSequence)
       //  node.runAction(loopSequence)
        
        return hoverSequence
        

    }
    
    func randomNumbers(numA: CGFloat, numB: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(numA - numB) + min(numA, numB)
    }
    
    func randomNonWholeNumbers(numA: CGFloat, numB: CGFloat) -> CGFloat {
        let randomNumber =  CGFloat(arc4random()) / CGFloat(UINT32_MAX) * (numA - numB) + min(numA, numB)
        let roundedNumber = (randomNumber*100).rounded()/100
        print(roundedNumber)  // 1.57
        
        return roundedNumber
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
        
        if imageName == "Harsh" && (nodeName == "faceFront" || nodeName == "faceBack") {
            print("Specular Check")
            child?.geometry?.firstMaterial?.normal.contents = UIImage(named: "target.scnassets/\(imageName).png_specular.png")

        }
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
        
//        DispatchQueue.main.async {
//            // 1
//            if let touchLocation = touches.first?.location(
//                in: self.sceneView) {
//                // 2
//                if let hit = self.sceneView.hitTest(touchLocation,
//                                                    options: nil).first {
//                    // 3
//                    if hit.node.name == "dice" {
//                        // 4
//                        hit.node.removeFromParentNode()
//                        self.diceCount += 1
//                    }
//                }
//            }
//        }


        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        let nodeAMask = nodeA.categoryBitMask
        let nodeBMask = nodeB.categoryBitMask

        print(nodeAMask, nodeBMask)
        print(nodeA.name, nodeB.name)
        print(BitMaskCategory.target.rawValue)

        
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            print("HIT!")
            self.target = nodeA
        } else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            print("HIT!")
            self.target = nodeB
        }
        let confetti = SCNParticleSystem(named: "target.scnassets/Fire.scnp", inDirectory: nil)
        confetti?.loops = false
        confetti?.particleLifeSpan = 4
        confetti?.emitterShape = target?.geometry
        let confettiNode = SCNNode()
        confettiNode.addParticleSystem(confetti!)
        confettiNode.position = contact.contactPoint
        self.sceneView.scene.rootNode.addChildNode(confettiNode)
        print("Target got hit \(target?.name)")

        target?.removeFromParentNode()
        
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
