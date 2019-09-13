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

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, NSFetchedResultsControllerDelegate {
    
    var managedContext: NSManagedObjectContext! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var killsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var gameKills: UILabel!
    @IBOutlet weak var gamePoints: UILabel!
    @IBOutlet weak var totalKills: UILabel!
    @IBOutlet weak var totalPoints: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    var gameStarted = false
    var gameFinished = false
    var targetsOnScreen = false
    var power: Float = 50
    var target: SCNNode?
    var currentlyShooting = false
    var points = 0
    var kills = 0
    var friends = 0
    
    var faceHit = false
    
    var peopleAdded = 0
    
    // Timers
    var myTimer = Timer()
    var countdown: Double = 40.00
    
    @IBOutlet weak var constX: NSLayoutConstraint!
    // MARK: - Views
    
    func configureView() {
        print("View Controller = Check if context set")
        if managedContext == nil {
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        messageLabel.text = "Press Start to Begin"
        
        print("TestJW1")
        performFetch()
    
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
        
//        // Pause the view's session
//        print("**** Leaving the View")
//        GameStateManager.sharedInstance().savePointsAndKills(kills: kills, points: points)
//        sceneView.session.pause()
    }
    
    // MARK: - Core Data Methods
    lazy var fetchedResultsController: NSFetchedResultsController<Friend> = {
        let fetchRequest = NSFetchRequest<Friend>()
        let entity = Friend.entity()
        fetchRequest.entity = entity
        let sort1 = NSSortDescriptor(key: "name", ascending: false) // Because we want Start Month first
        // let sort2 = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sort1]
        fetchRequest.fetchBatchSize = 20
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedContext, sectionNameKeyPath: nil, cacheName: "Friends")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    func performFetch() {
        do {
            print("Perform fetch")
            try fetchedResultsController.performFetch()
            
        } catch {
            // fatalCoreDataError(error)
            print("Perform fetch error")
            
        }
    }
    
    func populateFriends() {
        
    }
    
    // MARK: - Add the Targets (the targets)
    @IBAction func addTargets(_ sender: Any) {
        
        // We don't want to add if already finished
        if !gameFinished {
            
            // Add the appropriate amount of targets
            // If it is nil then we will add sample data
            if managedContext == nil {
                print("Add Sample Data")

                let objectsToAdd = GameStateManager.sharedInstance().initialTargets
                
                friendsLabel.text = "\(objectsToAdd)"
                
                for i in 1...objectsToAdd {
                    print("1. Add Friend")
                    addFriends(numOfFriend: i)
                }
                print("Add Targets done")
                
                friends = objectsToAdd
           
            } else {
                print("Fetch Request")

                let request: NSFetchRequest<Friend> = Friend.fetchRequest()
                
                do {
                    //3
                    let results = try managedContext.fetch(request)
                    friends = results.count
                    
                    // Fetch List Records
                    for result in results {
                        print(result.value(forKey: "name") ?? "no name")
                        print("Record - \(result)")
                        var target = friend.init()
                        let name = result.value(forKey: "name") ?? "no-name-given"
                        let imageData = result.value(forKey: "friendImage") ?? nil
                        var image = UIImage()
                        if let imageAvailable = imageData {
                            // Image exists
                            print("Image exists")
                            image = UIImage(data: imageAvailable as! Data)!
                        }
                        
                        target.name = "\(name)"
                        addNodeToScene(nodeFriend: target.name, defaultImage: false, image: image)
                    }
                    //4
                    print("Finished adding people")
                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }
            }
            
            // No longer need the start button
            startButton.isHidden = true
            startButton.isEnabled = false
            targetsOnScreen = true
            
        }

    }
    
    // Sample Code
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
        
        addNodeToScene(nodeFriend: target.name, defaultImage: true, image: nil)
        
    }
 
    //TODO: - Split the movemenents into different functions
    // We set default image for any images that are on the system
    func addNodeToScene(nodeFriend: String, defaultImage: Bool, image: UIImage?) {
        
        var passedName = nodeFriend
        
        // Use default iamge
        if nodeFriend == "no-name-given" {
            passedName = "Harsh"
        }
        
        print("Add Node To Scene")
        let targetParent = SCNNode()
        
        // Create a new scene and set it's position
        let targetScene = SCNScene(named: "target.scnassets/target.scn")!
        let targetNode = targetScene.rootNode.childNode(withName: "target", recursively: false)!
        targetNode.name = passedName
        
        let childNode = targetNode.childNode(withName: "box", recursively: false)
        childNode?.name = passedName
        
        // Position of node
        let x = randomNumbers(numA: -3, numB: 3.5)
        let y = randomNumbers(numA: -0.5, numB: 2)
        let z = randomNumbers(numA: -1, numB: -2)
        targetNode.position = SCNVector3(x,y,z)
        
        // Physics body
        targetNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        targetNode.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
//        targetNode.physicsBody?.restitution = 0.1
        
        // Add images; we also pass through a bool of default image in case we are loading up the images from core data or the device
        self.addFace(nodeName: "faceFront", targetNode: targetNode, imageName: passedName, defaultImage: defaultImage, image: image)
        self.addFace(nodeName: "faceBack", targetNode: targetNode, imageName: passedName, defaultImage: defaultImage, image: image)
        self.addLabel(nodeName: "nameLabelLeft", targetNode: targetNode, imageName: passedName)
        self.addLabel(nodeName: "nameLabelRight", targetNode: targetNode, imageName: passedName)
        
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
    
    func addFace(nodeName: String, targetNode: SCNNode, imageName: String, defaultImage: Bool, image: UIImage?) {
        
        print("Node Check - \(nodeName), \(targetNode), \(imageName)")
        let child = targetNode.childNode(withName: nodeName, recursively: true)
        if defaultImage {
            child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "target.scnassets/\(imageName).png")
        } else {
            print("Adding image for a face in core data")
            child?.geometry?.firstMaterial?.diffuse.contents = image!
        }

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
            myTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                self.startTimer()
            }
            return

        }
        
        if gameFinished {
            print("Game Finished")

            return
        }
        
        print("Handle Tap - Proceed")

        
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
    
    
    // MARK - Game management and timer
    func startTimer() {
    
        gameManagement()
        
        // No point doing this if game has finished
        if !gameFinished {
            countdown -= 0.01
            
            DispatchQueue.main.async {
                self.timerLabel.text = String(format: "%.2f", self.countdown)
            }
        }
    }

    
    func gameManagement() {
        
        if !gameFinished {
            
            if countdown <= 0.0  {
                print("countdown reached")
                // endGame()
                // Pause session view
                sceneView.session.pause()
                messageLabel.text = "Time Ran Out"
                // set game as finished & stop the timer
                myTimer.invalidate()
                timerLabel.text = String(format: "%.2f", 00.00)

                gameFinished = true
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    self.messageLabel.text = "Save and Exit"
                    self.endGame()
//                    _ = self.navigationController?.popViewController(animated: true)
                    
                    // Stats Pop Up
                }
                
            }
            
            if friends == 0 {
                print("All friends killed")

                // endGame()
                // Pause session view
                // set game as finished & stop the timer
                myTimer.invalidate()
                gameFinished = true
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    self.messageLabel.text = "You have killed all friends"
                    self.endGame()
//                    _ = self.navigationController?.popViewController(animated: true)

                    // Stats Pop Up
                }
            }
        }
    }
    
    func endGame() {
        
        // Pause the view's session
        print("**** ending Game")
        GameStateManager.sharedInstance().savePointsAndKills(kills: kills, points: points)
        sceneView.session.pause()
        showPopUp()
        
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        
        print("**** Exit button Pressed")

        
        // Set alert if not sure
        gameFinished = true
        myTimer.invalidate()
        countdown = 0.0
        timerLabel.text = String(format: "%.2f", self.countdown)
//        endGame()
        self.messageLabel.text = "Game about to exit"

        // Pop Up
//        showPopUp()
        
        // Go Back
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.messageLabel.text = "Exit in a second"
//            _ = self.navigationController?.popViewController(animated: true)
            self.endGame()

        }
    }
    
    func showPopUp() {
        
        constX.constant = 0
        updatePopUpScores()
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    func updatePopUpScores() {
        
        gameKills.text = String(kills)
        gamePoints.text = String(points)
        
        let killsAndPoints = GameStateManager.sharedInstance().returnKillsAndPoints()
        let tKills = killsAndPoints.0
        let tPoints = killsAndPoints.1
        
        totalKills.text = String(tKills)
        totalPoints.text = String(tPoints)
        
    }
    @IBAction func popUpButtonDismiss(_ sender: Any) {
        print("Hello")
        
        constX.constant = -1000
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.dismissToMainScreen()
            }, completion: nil)
    }
    
    func dismissToMainScreen() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
//            self.messageLabel.text = "Exiting to main screen"
            _ = self.navigationController?.popViewController(animated: true)
            
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
                self.friends -= 1
                self.killsLabel.text = "\(self.kills)"
                self.friendsLabel.text = "\(self.friends)"
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
