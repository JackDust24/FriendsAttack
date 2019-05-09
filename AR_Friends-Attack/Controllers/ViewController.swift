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
    
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var killsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var gameStarted = false
    var targetsOnScreen = false
    var power: Float = 50
    var target: SCNNode?
    var currentlyShooting = false
    var points = 0
    var kills = 0
    
    var faceHit = false
    
    var peopleAdded = 0
    
    // MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        messageLabel.text = "Press Start to Begin"
    
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
    
    // MARK: - Add the Targets
    @IBAction func addTargets(_ sender: Any) {
        
        // Add the appropriate amount of targets
        let objectsToAdd = GameStateManager.sharedInstance().initialTargets
        
        friendsLabel.text = "\(objectsToAdd)"

        
        for i in 1...objectsToAdd {
            print("1. Add Friend")
            addFriends(numOfFriend: i)
        }
        print("Add Targets done")

        // No longer need the start button
        startButton.isHidden = true
        startButton.isEnabled = false
        targetsOnScreen = true
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
            
        case 6:
            target.name = "Rory"
            print("1.3 Add Friend")
            
        default:
            target.name = "Harsh"
            print("1.4 Add Friend")
            
        }
        
        addNodeToScene(nodeFriend: target.name)
        
    }
 
    //TODO: - Split the movemenents into different functions
    func addNodeToScene(nodeFriend: String) {
        
        print("Add Node To Scene")
        let targetParent = SCNNode()
        
        // Create a new scene and set it's position
        let targetScene = SCNScene(named: "target.scnassets/target.scn")!
        let targetNode = targetScene.rootNode.childNode(withName: "target", recursively: false)!
        targetNode.name = nodeFriend
        
        let childNode = targetNode.childNode(withName: "box", recursively: false)
        childNode?.name = nodeFriend
        
        // Position of node
        let x = randomNumbers(numA: -3, numB: 3.5)
        let y = randomNumbers(numA: -0.5, numB: 2)
        let z = randomNumbers(numA: -1, numB: -2)
        targetNode.position = SCNVector3(x,y,z)
        
        // Physics body
        targetNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        targetNode.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
//        targetNode.physicsBody?.restitution = 0.1
        
        // Add images
        self.addFace(nodeName: "faceFront", targetNode: targetNode, imageName: nodeFriend)
        self.addFace(nodeName: "faceBack", targetNode: targetNode, imageName: nodeFriend)
        self.addLabel(nodeName: "nameLabelLeft", targetNode: targetNode, imageName: nodeFriend)
        self.addLabel(nodeName: "nameLabelRight", targetNode: targetNode, imageName: nodeFriend)
        
        self.sceneView.scene.rootNode.addChildNode(targetNode)
        
        // Movement
        let waitRandom = randomNonWholeNumbers(numA: 3, numB: 0)
        print("Waitrandom Check \(waitRandom)")
        
        let wait = SCNAction.wait(duration: TimeInterval(waitRandom))
        let parentRotation = rotation(time: 4)
        let nodeAnimation = animateNode()
        let sequence = SCNAction.sequence([parentRotation, wait, nodeAnimation])
        let loopSequence = SCNAction.repeatForever(sequence)
        // node.runAction(sequence)
        targetNode.runAction(loopSequence)
        
    }
    
    func addFace(nodeName: String, targetNode: SCNNode, imageName: String) {
        
        print("Node Check - \(nodeName), \(targetNode), \(imageName)")
        let child = targetNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "target.scnassets/\(imageName).png")
        child?.renderingOrder = 200
        child?.name = "face-side"

        //TODO: - Test texture can remove another time
        if imageName == "Harsh" && (nodeName == "faceFront" || nodeName == "faceBack") {
            print("Specular Check")
            child?.geometry?.firstMaterial?.normal.contents = UIImage(named: "target.scnassets/\(imageName).png_specular.png")
        }
    }
    
    func addLabel(nodeName: String, targetNode: SCNNode, imageName: String) {
        
        print("Label Check - \(nodeName), \(targetNode), \(imageName)")
        let child = targetNode.childNode(withName: nodeName, recursively: true)
        child?.name = "label-side"

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
    
    
    // MARK: Touches - fire bullets
    @objc func handleTap(sender: UITapGestureRecognizer) {
        print("Handle Tap")

        if currentlyShooting {
            print("Currently shooting already")

            return
        }
        // Don't need to do this if Game hasn't started.
        if !targetsOnScreen {
            print("Targets not on screen")
            return
        }
        
        if !gameStarted {
            print("Await to get game started then can start firing")
            gameStarted = true
            messageLabel.text = "Shoot in the face to kill"
            return

        }
        
        // We are currently shooting
        currentlyShooting = true
        
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfView = sceneView.pointOfView else {return}
        
        // Set up the bullet
        DispatchQueue.main.async {
            
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
            body.categoryBitMask = BitMaskCategory.bullet.rawValue
            
            bullet.physicsBody = body
            bullet.physicsBody?.applyForce(SCNVector3(orientation.x*self.power, orientation.y*self.power, orientation.z*self.power), asImpulse: true)
            bullet.physicsBody?.categoryBitMask = BitMaskCategory.bullet.rawValue
            bullet.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
            
            self.sceneView.scene.rootNode.addChildNode(bullet)
            bullet.runAction(
                SCNAction.sequence([SCNAction.wait(duration: 2.0),
                                    SCNAction.removeFromParentNode()])
            )
            bullet.runAction(SCNAction.sequence([SCNAction.wait(duration: 2.0),
                                                 SCNAction.removeFromParentNode()]), completionHandler: ({
                                                    print("Finished Shooting")
                                                    self.currentlyShooting = false
                                                 }))
        }
    }
    
    //TODO: - To decide whether to keep this and how we can add this to main queue
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        
        print("Touches Began")

        // Must default back to false
//        faceHit = false
        if currentlyShooting {
            print("Currently shooting already")
            
            return
        }
        
        DispatchQueue.main.async {
            // 1
            if let touchLocation = touches.first?.location(
                in: self.sceneView) {
                // 2
                if let hit = self.sceneView.hitTest(touchLocation,
                                                    options: nil).first {
                    
                    print(hit.node.name!)
                    // 3
                    if hit.node.name == "face-side" || hit.node.name == "front" || hit.node.name == "back" {
                        // 4
                        print("WE HAVE A HIT IN THE FACE")
                        self.faceHit = true

                    } else {
                        print("NO HIT")
                        self.faceHit = false

                    }
                }
            }
        }
    }
    
    // For collision
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("physicsWorld")
        
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        let nodeAMask = nodeA.categoryBitMask
        let nodeBMask = nodeB.categoryBitMask
        
//        // Test to see if we can tell which part is hit
//        let testA = nodeA.name
//        let testB = nodeA.name?.contains("front")
//        let testBA = nodeA.name?.contains("back")
//        let testBB = nodeA.name?.contains("left")
//        let testBC = nodeA.name?.contains("right")
//        let testBD = nodeA.name?.contains("face-side")
//
//        let testC = nodeA.childNodes.description
//        let testD = nodeA.parent?.name
//        let testE = nodeA.childNodes.first?.name
//        let testF = nodeA.childNodes.first
//
//        print(testA as Any)
//        print(testB as Any)
//        print(testBA as Any)
//        print(testBB as Any)
//        print(testBC as Any)
//        print(testBD as Any)
//        print(testC as Any)
//        print(testD as Any)
//        print(testE as Any)
//        print(testF as Any)
////        print(testC as Any)



        print(nodeAMask, nodeBMask)
        print(nodeA.name as Any, nodeB.name as Any)
        print(BitMaskCategory.target.rawValue)
        
        
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            self.target = nodeA
        } else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            self.target = nodeB
        }
        
        
//        let particle = SCNParticleSystem(named: "target.scnassets/Fire.scnp", inDirectory: nil)
        
        var particle: SCNParticleSystem
        
        if faceHit {
            print("FACE HIT")
            particle = bulletHitEffect(particleName: "target.scnassets/Fire.scnp", directory: nil, loops: false, lifeSpan: 4)
            
        } else {
            print("No FACE HIT")

            particle = bulletHitEffect(particleName: "target.scnassets/HitSide.scnp", directory: nil, loops: false, lifeSpan: 0.5)
        }
        
        let particleNode = SCNNode()
        particleNode.addParticleSystem(particle)
        particleNode.position = contact.contactPoint
        particleNode.scale = SCNVector3(0.5, 0.5, 0.5)
        self.sceneView.scene.rootNode.addChildNode(particleNode)
        print("Target got hit \(target?.name ?? "No Name")")
        
        DispatchQueue.main.async {
            
            if self.faceHit {
                print("You Killed \(self.target?.name ?? "No Name")")
                self.messageLabel.text = "You KILLED \(self.target?.name ?? "No Name")"

                self.points += 10
                //TODO- We will change this depending on the timer
                self.pointsLabel.text = "\(self.points)"
                self.kills += 1
                self.killsLabel.text = "\(self.kills)"
                self.target?.removeFromParentNode()
            } else {
                print("You hit \(self.target?.name ?? "No Name")")
                self.points += 1
                self.pointsLabel.text = "\(self.points)"
                self.messageLabel.text = "You hit \(self.target?.name ?? "No Name")"
            }
            self.faceHit = false

        }
        
    }
    
    func bulletHitEffect(particleName: String, directory: String?, loops: Bool, lifeSpan: CGFloat) -> SCNParticleSystem {
        
        let particle = SCNParticleSystem(named: particleName, inDirectory: directory)
        particle?.loops = loops
        particle?.particleLifeSpan = lifeSpan
        particle?.emitterShape = target?.geometry
        particle?.particleSize = 0.01
        
        return particle!
        
    }
   
    // MARK: - Animation and random positioning
    //TODO: - Do not need this function, can remove.
    func addRotation(node: SCNNode) {
        
        let rotateOne = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 25.0)
        let backwards = rotateOne.reversed()
        let rotateSequence = SCNAction.sequence([rotateOne, backwards])
        let repeatForever = SCNAction.repeatForever(rotateSequence)
        node.runAction(repeatForever)
    }
    
    func rotation(time: TimeInterval) -> SCNAction {
        
        print("Rotate")
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: time)
        let foreverRotation = SCNAction.repeatForever(rotation)
        return rotation
    }
    
    func animateNode() -> SCNAction  {
        
        print("Animate")
        let randomMinus = randomNonWholeNumbers(numA: 0, numB: -2)
        let randomPlus = randomNonWholeNumbers(numA: 2, numB: 0)
        let waitRandom = randomNonWholeNumbers(numA: 2, numB: 0)
        let randomNegative = -randomPlus
//        print("Waitrandom Check  2 \(waitRandom) randomMinus \(randomMinus) randomPlus \(randomPlus)")
        
        let wait = SCNAction.wait(duration: TimeInterval(waitRandom))
        let moveDown = SCNAction.move(by: SCNVector3(0, randomNegative, 0), duration: 0.5)
        let moveUp = SCNAction.move(by: SCNVector3(0, randomPlus,0), duration: 0.5)
        let moveLeft = SCNAction.move(by: SCNVector3(randomNegative, 0, 0), duration: 0.5)
        let moveRight = SCNAction.move(by: SCNVector3(randomPlus,0,0), duration: 0.5)
        let hoverSequence = SCNAction.sequence([wait, moveUp, wait, moveLeft, wait, moveDown, wait, moveRight])
//        let hoverSequence = SCNAction.sequence([wait, moveLeft, wait, moveRight])
//        let loopSequence = SCNAction.repeatForever(hoverSequence)
        return hoverSequence
    }
    
    //MARK: Helper methods
    func randomNumbers(numA: CGFloat, numB: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(numA - numB) + min(numA, numB)
    }
    
    func randomNonWholeNumbers(numA: CGFloat, numB: CGFloat) -> CGFloat {
        let randomNumber =  CGFloat(arc4random()) / CGFloat(UINT32_MAX) * (numA - numB) + min(numA, numB)
        let roundedNumber = (randomNumber*100).rounded()/100
        print(roundedNumber)  // 1.57
        return roundedNumber
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
