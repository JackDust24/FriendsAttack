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
    case bullet = 1
    case target = 2
}

enum Movement: String {
    case left = "left"
    case right = "right"
    case up = "up"
    case down = "down"
    case forwards = "forwards"
    case backwards = "backwards"
}

class GameController: UIViewController, SCNPhysicsContactDelegate, NSFetchedResultsControllerDelegate {
    
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
    var collisionInProgress = false
//    var faceHit = false
    // Nodes
//    var target: SCNNode?
    // Values
    var power: Float = 50 // power of the shot
    var points = 0
    var kills = 0
    var friends = 0
    var peopleAdded = 0
    // Timers
    var myTimer = Timer()
    var countdown = kStartTime
    // Misc
    // This is for the popup screen
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
        
        // Fetch the Friends Data
        performFetch()
        
        populateFriends()
    }
    
    func testCall() {
        print("Test")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        self.sceneView.autoenablesDefaultLighting = true
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.session.delegate = self as? ARSessionDelegate
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.scene.physicsWorld.contactDelegate = self

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //TODO:- Check what we will do here

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
        
        // We can start this but no need to add to screen just yet
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
            
            
        } else {
            print("Fetch Request to add friends")
            let request: NSFetchRequest<Friend> = Friend.fetchRequest()
            
            do {
                // Get results of friends request
                let results = try managedContext.fetch(request)
                friends = results.count
                print("Friends Count - \(friends)")
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
    }
    
    // MARK: - Add the Targets (the targets)
    // This is when the user clicks the Start Button
    @IBAction func startPressed(_ sender: Any) {
        
        // 1. We want to add the nodes to shoot.
        // We don't want to add if already finished
        if !gameFinished {
            
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
        DispatchQueue.global(qos: .background).async {
            
            let targetScene = SCNScene(named: "target.scnassets/target_copy.scn")!
            let targetNode = targetScene.rootNode.childNode(withName: "target", recursively: false)!
            targetNode.name = nodedName
            targetNode.scale = SCNVector3(1.1, 1.1, 1.1)
            //        let childNode = targetNode.childNode(withName: "box", recursively: false)
            //        childNode?.name = nodedName
            
            
            // Position of node
            let x = self.randomNumbers(numA: CGFloat(kMinX), numB: CGFloat(kMaxX))
            let y = self.randomNumbers(numA: CGFloat(kMinY), numB: CGFloat(kMaxY))
            let z = self.randomNumbers(numA: CGFloat(kMinZ), numB: CGFloat(kMaxZ))
            targetNode.position = SCNVector3(x,y,z)
            
            // Set the Physics body
            targetNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: targetNode, options: nil))
            targetNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
            targetNode.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
            targetNode.categoryBitMask = BitMaskCategory.target.rawValue
            // TODO:- Play around with this - targetNode.physicsBody?.restitution = 0.1
            
            // Add images; we also pass through a bool of default image in case we are loading up the images from core data or the device
            self.addFace(nodeName: "faceFront", targetNode: targetNode, imageName: nodedName, defaultImage: defaultImage, image: image)
            self.addFace(nodeName: "faceBack", targetNode: targetNode, imageName: nodedName, defaultImage: defaultImage, image: image)
            self.addLabel(nodeName: "nameLabelLeft", targetNode: targetNode, imageName: nodedName)
            self.addLabel(nodeName: "nameLabelRight", targetNode: targetNode, imageName: nodedName)
            
            // Set default colours
            self.changeNodeLabelColour(targetNode: targetNode)
            
            //        targetNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: targetNode, options: nil))
            
            
            self.sceneView.scene.rootNode.addChildNode(targetNode)
            
            // Movement
            // TODO:- Play around with this - try and set up by frames
            let waitRandom = self.randomNonWholeNumbers(numA: 3, numB: 0)
            
            let wait = SCNAction.wait(duration: TimeInterval(waitRandom))
            let parentRotation = self.rotation(time: 2)
            let nodeAnimation = self.animateNode(nodePosition: targetNode.position)
            let sequence = SCNAction.sequence([parentRotation, wait, nodeAnimation])
            let loopSequence = SCNAction.repeatForever(sequence)
            targetNode.runAction(sequence)
            //         targetNode.runAction(loopSequence)
            
        }
   
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
        labelNode.fontColor = UIColor.black
        skScene.addChild(rectangle)
        skScene.addChild(labelNode)
        
        return skScene
    }
    
    // For when the bullet hits
    func changeNodeLabelColour(targetNode: SCNNode) {
        
        // Go through all the sides that need changing
        let frontChild = targetNode.childNode(withName: "front", recursively: true)
        let backChild = targetNode.childNode(withName: "back", recursively: true)
        let leftChild = targetNode.childNode(withName: "left", recursively: true)
        let rightChild = targetNode.childNode(withName: "right", recursively: true)
        
        let nodeArrays = [frontChild, backChild, leftChild, rightChild]
        
        for childNode in nodeArrays {
            let colour = childNode?.geometry?.firstMaterial?.diffuse.contents as! UIColor
            print("\(colour) is chosen")
            changeColourForNode(childNode: (childNode)!, existingColour: colour)
            let colourCheck = childNode?.geometry?.firstMaterial?.diffuse.contents as! UIColor
            print("\(colourCheck) is Colour Check")

        }
    }
    
    // Every time a bullet hits a node we change the colour of the node
    func changeColourForNode(childNode: SCNNode, existingColour: UIColor) {
        
        var currentColour = existingColour
        
        if currentColour == UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0) {
            print("\(currentColour) is green -> blue")
            childNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            currentColour = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
            
        } else if currentColour == UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0) {
            print("\(currentColour) is blue -> red")
            childNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            currentColour = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            
        } else if currentColour == UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0) {
            print("\(currentColour) is red -> black")
            childNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
            currentColour = UIColor(white: 0, alpha: 1)
            
        } else if currentColour == UIColor(white: 0, alpha: 1) {
            print("\(currentColour) is black -> Stay black")
            
        } else {
            print("\(currentColour) is the original")
            childNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
            currentColour = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)

        }
        
        print("Current Colour Check - \(currentColour)")

    }
    
    // MARK: Touches - fire bullets
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        print("Handle Tap")
        
        // Of currntly shooting then we return
        if currentlyShooting {
            print("HT - Currently shooting already")
            return
        }
        
        // Cannot shoot if Game hasn't started.
        if !targetsOnScreen {
            print("HT- Targets not on screen")
            return
        }
        
        if !gameStarted {
            print("HT - Await to get game started then can start firing")
            gameStarted = true
            // Change the text to say we can now shoot
            //TODO:- test this
            message = "Shoot 3 times to Kill"
            myTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                self.startTimer()
            }
            return
        }
        
        if gameFinished {
            print("Game Finished")
            return
        }
        
        print("Handle Tap - Shooting")

        // We are currently shooting
        currentlyShooting = true
        
        // If not the sender view then exit
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfView = sceneView.pointOfView else {return}
        
        // Set up the bullet
        print("Bullet fired")
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
        bullet.name = "bullet"
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        bullet.position = position
        print("Bullet world position \(bullet.worldPosition)")
        
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
        body.isAffectedByGravity = false
        body.categoryBitMask = BitMaskCategory.bullet.rawValue
        
        bullet.physicsBody = body
        bullet.physicsBody?.applyForce(SCNVector3(orientation.x*self.power, orientation.y*self.power, orientation.z*self.power), asImpulse: true)
        bullet.physicsBody?.categoryBitMask = BitMaskCategory.bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
        
        self.sceneView.scene.rootNode.addChildNode(bullet)
        print("Bullet added to scene")


        bullet.runAction(SCNAction.sequence(
            [SCNAction.wait(duration: 1.0), SCNAction.removeFromParentNode()]), completionHandler: ({
                print("Finished Shooting")
                self.currentlyShooting = false
             })
        )
    }
    
    //TODO: - To decide whether to keep this and how we can add this to main queue
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        
        print("Touches Began")
        
        if currentlyShooting {
            print("Currently shooting already")
            
            return
        }

    }
    
    // MARK: - Game management and timer
    
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
            print("Current Friends Total - \(friends) & kills - \(kills)")
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
//        GameStateManager.sharedInstance().saveKillPointsPerFriend(kills: kills, friend: points)
        
        sceneView.scene.rootNode.childNodes.filter({
            $0.categoryBitMask == 2 }).forEach({
                //                print("Node Enumerate -\($0.name)")
                if !$0.hasActions {
                    $0.removeAllActions()                }
                
            })
        
        sceneView.session.pause()
        showPopUp()
        
    }
    
    
    @IBAction func exitButtonPressed(_ sender: Any) {

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
        
        if collisionInProgress {
            print("collisionInProgress = true")
            return // We don't want this to run again while it is still in progress
        }
        
        // We only want to do one collision in this loop
        collisionInProgress = true
        
        // collision for nodes
        var targetNode: SCNNode?
        
        print("physicsWorld")
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        let nodeAMask = nodeA.categoryBitMask
        let nodeBMask = nodeB.categoryBitMask

        print(nodeAMask, nodeBMask)
        print(nodeA.name as Any, nodeB.name as Any)
        print(BitMaskCategory.target.rawValue)
        
        print("NodeA Name - \(String(describing: nodeA.name)) / NodeA Position - \(nodeA.worldPosition) / NodeB Name - \(String(describing: nodeB.name))/ NodeB Position - \(nodeB.position)")
        
        if nodeAMask == nodeBMask {
            print("Same nodes colliding, can return")
            nodeA.removeAllActions()
            nodeB.removeAllActions()
            return
        }
        
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            targetNode = nodeA
            nodeA.removeAllActions()
            
        } else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            targetNode = nodeB
            nodeB.removeAllActions()

        }
        
        var particle: SCNParticleSystem
        
   
        
        var tempMessage = "" // We will use this further down for updating the message on the screen
        
        // Check Target node to see if Black if so, them it will be destroyed
        
        // 2. We only need to check one of the sides
        let frontChild = targetNode?.childNode(withName: "front", recursively: true)
        
        // 3. Check the colour of that node
        let colourCheck = frontChild?.geometry?.firstMaterial?.diffuse.contents as! UIColor
        
        // 4. If Black means it has been hit 3 times
        if colourCheck == UIColor(white: 0, alpha: 1) {
            
            particle = bulletHitEffect(particleName: "target.scnassets/Fire.scnp", directory: nil, loops: false, lifeSpan: 4)
            print("You Killed \(targetNode?.name ?? "No Name")")
            
            points += 10
            kills += 1
            friends -= 1
            tempMessage = "You KILLED \(targetNode?.name ?? "No Name")"
            addKillPointsToFriend(friend: targetNode?.name ?? "No Name")
            targetNode!.removeFromParentNode()
//            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
//                print("Remove node")
//                // No longer in collision so can end
//                self.collisionInProgress = false
//                targetNode!.removeFromParentNode()
//                print("Finished Kill")
//            }
            
        } else {
            
            particle = bulletHitEffect(particleName: "target.scnassets/HitSide.scnp", directory: nil, loops: false, lifeSpan: 0.5)
            print("You hit \(targetNode?.name ?? "No Name")")
            
            points += 1
            tempMessage = "You hit \(targetNode?.name ?? "No Name")"
        }
        
        // 1. Change the colour of the node if it hits, but we only want to do this IF node is not nil
        if let nodeToChangeColour = targetNode {
            changeNodeLabelColour(targetNode: nodeToChangeColour)
        }
        
        DispatchQueue.main.async {

            self.message = tempMessage
        }
        
        let particleNode = SCNNode()
        particleNode.addParticleSystem(particle)
        particleNode.position = contact.contactPoint
        particleNode.scale = SCNVector3(0.5, 0.5, 0.5)
        
        self.sceneView.scene.rootNode.addChildNode(particleNode)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        
//        let nodeA = contact.nodeA
//        let nodeB = contact.nodeB

        // We can shoot again
        
//        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.bullet.rawValue {
//            print("NodeA check being Removed - \(nodeA.name)")
//            nodeA.removeFromParentNode()
//
//        } else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.bullet.rawValue {
//            print("NodeB check being Removed - \(nodeB.name)")
//            nodeB.removeFromParentNode()
//
//        } else {
//            return
//        }
//
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            print("collisionInProgressn = false")
            // No longer in collision so can end
            self.collisionInProgress = false
            self.currentlyShooting = false

        }
    }
    
    func addKillPointsToFriend(friend: String) {
    
//        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        
        DispatchQueue.global(qos: .background).async {
            
            print("1")
            let fetchResults = self.fetchedResultsController.fetchedObjects
            
            do {
                //            // Get results of friends request
                //            let results = try managedContext.fetch(request)
                //            friends = results.count
                print("2")
                
                if let fetchResults = fetchResults {
                    print("3")
                    
                    // Fetch List Records
                    for fetch in fetchResults {
                        
                        let name = fetch.value(forKey: "name") as! String
                        print("Name Check - \(name)")
                        print("friend Check - \(friend)")
                        
                        if name == friend {
                            print("4")
                            
                            
                            var currentKilled = fetch.value(forKey: "killed") as! Int
                            currentKilled = currentKilled + 1
                            
                            fetch.setValue(Int64(currentKilled), forKey: "killed")
                            
                        }
                        print("5")
                        
                        try self.managedContext.save()
                    }
                    print("Finished adding score")
                    
                }
                
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
        }
       
    }
    
    // Bullet Effect
    func bulletHitEffect(particleName: String, directory: String?, loops: Bool, lifeSpan: CGFloat) -> SCNParticleSystem {
        
        let particle = SCNParticleSystem(named: particleName, inDirectory: directory)
        particle?.loops = loops
        particle?.particleLifeSpan = lifeSpan
//        particle?.emitterShape =
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
//        // Get rid of this
//        return SCNAction.wait(duration: TimeInterval(1))
        
        print("Rotate")
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: time)
        //TODO:- Check this rotation
       //  let foreverRotation = SCNAction.repeatForever(rotation)
        return rotation
    }
    
    // We take the node argument for when calling the boundaries check
    func animateNode(nodePosition: SCNVector3) -> SCNAction  {
        
        print("Animate Node")
        // 1. Create the constants for this functions
        let randomPlus = randomNonWholeNumbers(numA: 2, numB: 0)
        let waitRandom = randomNonWholeNumbers(numA: 3, numB: 0)
        let randomNegative = -randomPlus
        let wait = SCNAction.wait(duration: TimeInterval(waitRandom))
        
//        let hoverSequence = SCNAction.sequence([wait, moveUp, wait, moveLeft, wait, moveDown, wait, moveRight])
//        let hoverSequence = SCNAction.sequence([wait, moveLeft, wait, moveRight])
//        let loopSequence = SCNAction.repeatForever(hoverSequence)
        
        // 2. Create the SCNVectors for the movement
        let moveDown = SCNVector3(0, randomNegative, 0)
        let moveUp = SCNVector3(0, randomPlus, 0)
        let moveLeft = SCNVector3(randomNegative, 0, 0)
        let moveRight = SCNVector3(randomPlus, 0, 0)
        let moveForwards = SCNVector3(0, 0, randomPlus)
        let moveBackwards = SCNVector3(0, 0, randomNegative)
        
        // 3. Do a random movement 0 - 5
        // 4. Create a movement variable for action
        let moveDirectionChoice = Int(arc4random_uniform(6))
        var movement: SCNAction
        
//        let newPosition = SCNVector3((moveLeft.x + nodePosition.x), nodePosition.y, nodePosition.z)
        print("Check Move - \(moveDirectionChoice)")
        
//        movement = SCNAction.move(to: newPosition, duration: 1.0)
        
//         5. Switch through the random numbers
//         6. If the movement is safe to move in that direction, then it can move, otherwise it moves the opposite way.
        switch moveDirectionChoice {
        case 0: // left
            if canNodeMove(nodePosition: nodePosition, newPosition: moveLeft, moveDirection: Movement.left) {
                movement = SCNAction.move(by: moveLeft, duration: 1.5)
            } else {
                movement = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 0.5)
//                movement = SCNAction.move(by: moveRight, duration: 0.5)
            }
        case 1: // right
            print("Check Move - move Right")

            if canNodeMove(nodePosition: nodePosition, newPosition: moveRight, moveDirection: Movement.right) {
                print("Check Move - True")
                movement = SCNAction.move(by: moveRight, duration: 1.5)
            } else {
                print("Check Move - False")

                movement = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 0.5)

//                movement = SCNAction.move(by: moveLeft, duration: 0.5)
            }
        case 2: // down
            if canNodeMove(nodePosition: nodePosition, newPosition: moveDown, moveDirection: Movement.down) {
                movement = SCNAction.move(by: moveDown, duration: 1.5)
            } else {
                movement = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 0.5)

//                movement = SCNAction.move(by: moveUp, duration: 0.5)
            }
        case 3: // up
            if canNodeMove(nodePosition: nodePosition, newPosition: moveUp, moveDirection: Movement.up) {
                movement = SCNAction.move(by: moveUp, duration: 1.5)
            } else {
//                movement = SCNAction.move(by: moveDown, duration: 0.5)
                movement = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 0.5)

            }
        case 4: // backwards
            if canNodeMove(nodePosition: nodePosition, newPosition: moveBackwards, moveDirection: Movement.backwards) {
                movement = SCNAction.move(by: moveBackwards, duration: 1.5)
            } else {
                movement = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 0.5)

//                movement = SCNAction.move(by: moveForwards, duration: 0.5)
            }
        case 5: // forwards
            if canNodeMove(nodePosition: nodePosition, newPosition: moveForwards, moveDirection: Movement.forwards) {
                movement = SCNAction.move(by: moveForwards, duration: 1.5)
            } else {
                movement = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 0.5)

//                movement = SCNAction.move(by: moveBackwards, duration: 0.5)
            }
        default:
            movement = SCNAction.move(by: moveRight, duration: 1.5)
        }
        
        let moveSequence = SCNAction.sequence([movement, wait, rotation(time: 1)])
        
        return moveSequence
        
    }
    
    // We don't want the nodes to go out of bounds
    func canNodeMove(nodePosition: SCNVector3, newPosition: SCNVector3, moveDirection: Movement) -> Bool {
        
        print("Check Move - canNodeMove \(nodePosition) - \(newPosition)")

        // Set default it can move
        var nodeCanMove = true
        
        // If the movement goes beyond then it fails
        switch moveDirection {
        case .left:
            if Int((nodePosition.x + newPosition.x)) < kMinX {
                nodeCanMove = false
            }
        case .right:
            if Int((nodePosition.x + newPosition.x)) > kMaxX {
                nodeCanMove = false
            }
        case .down:
            if Int((nodePosition.y + newPosition.y)) < kMinY {
                nodeCanMove = false
            }
        case .up:
            if Int((nodePosition.y + newPosition.y)) > kMaxY {
                nodeCanMove = false
            }
        case .backwards:
            if Int((nodePosition.z + newPosition.z)) < kMaxZ {
                nodeCanMove = false
            }
        case .forwards:
            if Int((nodePosition.z + newPosition.z)) > kMinZ {
                nodeCanMove = false
            }

        }
        
        return nodeCanMove
        
    }
    
    // Check what Action to return

    
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
    
//    @available(iOS 11.3, *)
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        print("adjust frame")
//        
//        guard let currentFrame = sceneView.session.currentFrame?.camera else { return }
//        let transform = currentFrame.transform
//        sceneView.session.setWorldOrigin(relativeTransform: transform)
//        
//    }
}

//MARK:- SceneView Delegate
extension GameController: ARSCNViewDelegate {
    
    //MARK:- Renders
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        print("update node")
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            self.messageLabel.text = self.message
            self.pointsLabel.text = "\(self.points)"
            self.killsLabel.text = "\(self.kills)"
            self.friendsLabel.text = "\(self.friends)"
        }

//        print(time)
        sceneView.scene.rootNode.childNodes.filter({
            $0.categoryBitMask == 2 }).forEach({
//                print("Node Enumerate -\($0.name)")
                if !$0.hasActions {
                    print("Node Enumerate - no actions")
                    // Node has no actions running so it is okay
                    moveNode(node: $0)
                    // Can break from the loop
                    return
                }
                
//                print("Node Enumerate - actions")

            })
        

    }
    
    func moveNode(node: SCNNode) {
        
        if node.hasActions {
            // Node has actions running so not needed
//            print("Node is running an action")
            return
        }
                
        // Movement
        // TODO:- Play around with this - try and set up by frames
        let waitRandom = randomNonWholeNumbers(numA: 3, numB: 0)

        let wait = SCNAction.wait(duration: TimeInterval(waitRandom))
        let parentRotation = rotation(time: 2)
        let nodeAnimation = animateNode(nodePosition: node.position)
        let nodePositionTest = node.position
        print("Node Name - \(String(describing: node.name)) Node Position - \(nodePositionTest)")
        let sequence = SCNAction.sequence([wait, nodeAnimation])
//         let loopSequence = SCNAction.repeatForever(sequence)
        DispatchQueue.global(qos: .background).async {
            node.runAction(sequence)

        }
        
        
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

// Convert degrees to radians
extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/100}
}
