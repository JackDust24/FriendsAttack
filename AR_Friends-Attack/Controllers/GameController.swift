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

// For the Physics
enum BitMaskCategory: Int {
    case target = 2
    case bullet = 3
}

class GameController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, NSFetchedResultsControllerDelegate {
    
    // The context for keeping the names of friends etc
    var managedContext: NSManagedObjectContext! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    //MARK:- Properties
    
    // Game Buttons
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    //View
    @IBOutlet var sceneView: ARSCNView!
    // Header Labels
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var killsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var gameKills: UILabel!
    @IBOutlet weak var gamePoints: UILabel!
    @IBOutlet weak var totalKills: UILabel!
    @IBOutlet weak var totalPoints: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    var message: String = "" // This is for the message label
    
    // Bools
    var gameStarted = false
    var gameFinished = false
    var targetsOnScreen = false // If targets are on screen then game is playing
    var currentlyShooting = false // If shooting can't shoot
    var faceHit = false
    // Nodes
    var target: SCNNode?
    // Values
    var power: Float = 50 // power of the shot
    var points = 0
    var kills = 0
    var friends = 0
    var peopleAdded = 0
    // Timers
    var myTimer = Timer()
    var countdown: Double = 40.00
    // Misc
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
        
        // Set up boundaries for the nodes etc:
        setBoundariesForNodes()
        // Fetch the Friends Data
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
        //TODO:- Check what we will do here
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
        let sortNames = NSSortDescriptor(key: "name", ascending: false) // Because we want Start Month first
        fetchRequest.sortDescriptors = [sortNames]
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
            //TODO:- Set Error
            // fatalCoreDataError(error)
            print("Perform fetch error")
        }
    }
    
    //TODO - Are we adding friends?
    func populateFriends() {
        
    }
    
    // MARK: - Add the Targets (the targets)
    // This is when the user clicks the Start Button
    @IBAction func startPressed(_ sender: Any) {
        
        // 1. We want to add the nodes to shoot.
        // We don't want to add if already finished
        if !gameFinished {
            
            // Add the appropriate amount of targets
            // If it is nil then we will add sample data
            if managedContext == nil {
                print("Add Sample Friends Data")

                let objectsToAdd = GameStateManager.sharedInstance().initialTargets
                friendsLabel.text = "\(objectsToAdd)"
                
                for i in 1...objectsToAdd {
                    print("1. Add Friend")
                    addFriends(numOfFriend: i)
                }
                friends = objectsToAdd
           
            } else {
                print("Fetch Request to add friends")
                let request: NSFetchRequest<Friend> = Friend.fetchRequest()
                
                do {
                    // Get results of friends request
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
                    print("Finished adding people")
                    
                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }
            }
            // 2. No longer need the start button, so amend the game variables
            startButton.isHidden = true
            startButton.isEnabled = false
            targetsOnScreen = true
        }
    }
    
    //TODO - We will add sample code onto other model
    // Sample Code
    func addFriends(numOfFriend: Int) {
        
        var target = friend.init()
        switch numOfFriend {
            case 1:
                target.name = "Harsh"
            case 2:
                target.name = "Ploy"
            case 3:
                target.name = "Scotto"
            case 4:
                target.name = "Doug"
            case 5:
                target.name = "Ian"
            case 6:
                target.name = "Rory"
            default:
                target.name = "no-name-given"
        }
        
        addNodeToScene(nodeFriend: target.name, defaultImage: true, image: nil)
        
    }
 
    //TODO: - Split the movemenents into different functions
    // We set default image for any images that are on the system
    func addNodeToScene(nodeFriend: String, defaultImage: Bool, image: UIImage?) {
        
        // Set passedName for the node we want to name
        var nodedName = nodeFriend
        
        // Use default iamge if we do not have a name
        // No name given is when a person is added by there is no name
        if nodeFriend == "no-name-given" {
            nodedName = "Harsh"
        }
        
        // Create a new scene
        let targetScene = SCNScene(named: "target.scnassets/target.scn")!
        let targetNode = targetScene.rootNode.childNode(withName: "target", recursively: false)!
        targetNode.name = nodedName
        let childNode = targetNode.childNode(withName: "box", recursively: false)
        childNode?.name = nodedName
        
        // Position of node
        let x = randomNumbers(numA: -4, numB: 4.5)
        let y = randomNumbers(numA: -0.5, numB: 3)
        let z = randomNumbers(numA: -1, numB: -2.5)
        targetNode.position = SCNVector3(x,y,z)
        
        // Set the Physics body
        targetNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        targetNode.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
        // TODO:- Play around with this - targetNode.physicsBody?.restitution = 0.1
        
        // Add images; we also pass through a bool of default image in case we are loading up the images from core data or the device
        self.addFace(nodeName: "faceFront", targetNode: targetNode, imageName: nodedName, defaultImage: defaultImage, image: image)
        self.addFace(nodeName: "faceBack", targetNode: targetNode, imageName: nodedName, defaultImage: defaultImage, image: image)
        self.addLabel(nodeName: "nameLabelLeft", targetNode: targetNode, imageName: nodedName)
        self.addLabel(nodeName: "nameLabelRight", targetNode: targetNode, imageName: nodedName)
        
        self.sceneView.scene.rootNode.addChildNode(targetNode)
        
        // Movement
        // TODO:- Play around with this - try and set up by frames
        let waitRandom = randomNonWholeNumbers(numA: 3, numB: 0)
        
        let wait = SCNAction.wait(duration: TimeInterval(waitRandom))
        let parentRotation = rotation(time: 4)
        let nodeAnimation = animateNode()
        let sequence = SCNAction.sequence([parentRotation, wait, nodeAnimation])
        let loopSequence = SCNAction.repeatForever(sequence)
        // node.runAction(sequence)
        targetNode.runAction(loopSequence)
        
    }
    
    // We don't want the nodes to go out of bounds
    func setBoundariesForNodes() {
        
        //
        
    }
    
    //MARK:- Set the friend nodes up
    // Add the image to the node
    func addFace(nodeName: String, targetNode: SCNNode, imageName: String, defaultImage: Bool, image: UIImage?) {
        
        print("Node Check for face we are adding - \(nodeName), \(targetNode), \(imageName)")
        // Get the child node
        let child = targetNode.childNode(withName: nodeName, recursively: true)
        // If a default image from the system, then use that name of the image, otherwise hysr you the image contents
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
    
    // Add the name labels for the nodes
    func addLabel(nodeName: String, targetNode: SCNNode, imageName: String) {
        
        let labelScene = addLabelText(text: imageName)
        
        let child = targetNode.childNode(withName: nodeName, recursively: true)
        child?.name = "label-side"
        child?.geometry?.firstMaterial?.diffuse.contents = labelScene
        child?.geometry?.firstMaterial?.isDoubleSided = true
        child?.renderingOrder = 200
    }
    
    // Add the label text
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
        
        return skScene
    }
    
    // MARK: Touches - fire bullets
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        print("Handle Tap")
        
        // Of currntly shooting then we return
        if currentlyShooting {
            print("Currently shooting already")
            return
        }
        
        // Cannot shoot if Game hasn't started.
        if !targetsOnScreen {
            print("Targets not on screen")
            return
        }
        
        if !gameStarted {
            print("Await to get game started then can start firing")
            gameStarted = true
            // Change the text to say we can now shoot
            //TODO:- test this
            message = "Shoot in the face to kill"
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
        
        // If not the sender view then exit
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
            // We don't need the bullet anymore once shot whether missed or shot.
            bullet.runAction(SCNAction.sequence(
                [SCNAction.wait(duration: 2.0),
                SCNAction.removeFromParentNode()]), completionHandler: ({
                    print("Finished Shooting")
                    self.currentlyShooting = false
                })
            )
        }
    }
    
    //TODO: - To decide whether to keep this and how we can add this to main queue
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        
        print("Touches Began")
        
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
    
    // Timer for the game if run out of time
    func startTimer() {
    
        // First call the Game Management method
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
            
            // Check if we have reached zerp
            if countdown <= 0.0  {
                
                print("countdown reached")
                
                // Pause session view
                sceneView.session.pause()
                message = "Time Ran Out"
                
                // set game as finished & stop the timer
                myTimer.invalidate()
                timerLabel.text = String(format: "%.2f", 00.00)
                gameFinished = true
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    self.message = "Save and Exit"
                    self.endGame()
                }
            }
            
            // We can also end the game if it reaches zero
            if friends == 0 {
                
                print("All friends killed")
                
                // Pause session view
                // set game as finished & stop the timer
                myTimer.invalidate()
                gameFinished = true
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    self.message = "You have killed all friends"
                    self.endGame()
                }
            }
        }
    }
    
    // Show the pop up for ending the game
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
        //TODO:- Game Exit check?
        
        // Otherwise we exit
        gameFinished = true
        myTimer.invalidate()
        countdown = 0.0
        timerLabel.text = String(format: "%.2f", self.countdown)
        self.message = "Game about to exit"

        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            self.message = "Exit in a second"
//            _ = self.navigationController?.popViewController(animated: true)
            self.endGame()
        }
    }
    
    // PopUp for ending thegame
    func showPopUp() {
        
        //TODO - Check the popup
        constX.constant = 0
        updatePopUpScores()
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // Add the PopUp Scores
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
        print("popUpButtonDismiss pressed")
        
        constX.constant = -1000
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.dismissToMainScreen()
            }, completion: nil)
    }
    
    // Dismissed to main screen - need to checj
    func dismissToMainScreen() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
//            self.messageLabel.text = "Exiting to main screen"
            _ = self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    // MARK:- For collision
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        print("physicsWorld")
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        let nodeAMask = nodeA.categoryBitMask
        let nodeBMask = nodeB.categoryBitMask

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
        
        // Depending if we PRESSED the face or not, what effect we would have.
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
            
            // If hit the face then the node is removed
            if self.faceHit {
                print("You Killed \(self.target?.name ?? "No Name")")
                
                self.points += 10
                self.kills += 1
                self.friends -= 1
                self.message = "You KILLED \(self.target?.name ?? "No Name")"
                self.target?.removeFromParentNode()
                
            } else {
                print("You hit \(self.target?.name ?? "No Name")")
                self.points += 1
                self.message = "You hit \(self.target?.name ?? "No Name")"
            }
            self.faceHit = false
        }
    }
    
    // Bullet Effect
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
        // let repeatForever = SCNAction.repeatForever(rotateSequence)
        node.runAction(rotateSequence)
    }
    
    func rotation(time: TimeInterval) -> SCNAction {
        
        print("Rotate")
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: time)
        //TODO:- Check this rotation
       //  let foreverRotation = SCNAction.repeatForever(rotation)
        return rotation
    }
    
    func animateNode() -> SCNAction  {
        
        print("Animate Node")
        //TODO:- Set Parameters -
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
    
    //MARK:- Renders
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        print("update node")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            self.messageLabel.text = self.message
            self.pointsLabel.text = "\(self.points)"
            self.killsLabel.text = "\(self.kills)"
            self.friendsLabel.text = "\(self.friends)"
        }
    }
    
    //MARK: Helper methods
    // Random Numbers flost
    func randomNumbers(numA: CGFloat, numB: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(numA - numB) + min(numA, numB)
    }
    
    func randomNonWholeNumbers(numA: CGFloat, numB: CGFloat) -> CGFloat {
        let randomNumber =  CGFloat(arc4random()) / CGFloat(UINT32_MAX) * (numA - numB) + min(numA, numB)
        let roundedNumber = (randomNumber*100).rounded()/100
        print(roundedNumber)  // 1.57
        return roundedNumber
    }
    
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
