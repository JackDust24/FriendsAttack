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

//MARK: Structs and Enums
// Friend that is added
struct friend {
    var name = ""
    var image: UIImage?
    
    init(withName: String, withImage: UIImage) {
        name = withName
        image = withImage
    }
}

// Mask Catogory for the Nodes
struct BitMaskCategory: OptionSet {
    let rawValue: Int
    static let bullet = BitMaskCategory(rawValue: 2)
    static let target = BitMaskCategory(rawValue: 4)
}

// Setting movements for the nodes
enum Movement: String {
    case noneSet = "none"
    case left = "left"
    case right = "right"
    case up = "up"
    case down = "down"
    case forwards = "forwards"
    case backwards = "backwards"
}

class GameController: UIViewController, SCNPhysicsContactDelegate, NSFetchedResultsControllerDelegate {
    
    //MARK:- Properties
    // The context for keeping the names of friends etc
    var managedContext: NSManagedObjectContext! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    // Game Buttons
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var dismissPopUp: UIButton!
    @IBOutlet weak var backgroundButton: UIButton!
    //View
    @IBOutlet var sceneView: ARSCNView!
    // Header Labels
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var killsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var gameKills: UILabel!
    @IBOutlet weak var gamePoints: UILabel!
    @IBOutlet weak var totalKills: UILabel!
    @IBOutlet weak var totalPoints: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    // Audio Properties
    var audioShootPlayer: SCNAudioPlayer?
    var getAudioShoot: SCNAudioSource?
    var getAudioExplosion: SCNAudioSource?
    // Temp mesage property
    var message: String = "" // This is for the message label
    // Booleans
    var gameStarted = false
    var gameFinished = false
    var targetsOnScreen = false // If targets are on screen then game is playing
    var currentlyShooting = false // If shooting can't shoot
    var collisionInProgress = false
    var gameIsPaused = false
    var gameHasBecomeActive = false
    var notifiedUserToTurnPhoneAround = false
    // Values
    var power: Float = 50 // power of the shot
    var points = 0
    var kills = 0
    var friends = 0
    var peopleAdded = 0
    var nodeCount = 0 // For making sure we only choose one node every update
    // Times etc
    var gameSpeed = GameStateManager.sharedInstance().kGameSpeed
    var currentTime = GameStateManager.sharedInstance().kStartTime
    var previousTime = 0.0
    var dt: TimeInterval = 0 // delta time
    let moveNodePerSecond: CGFloat = 1.0
    // Arrays
    var killedFriends: Array<String> = []
    // Misc
    var nodeSpawnX: Array<Int> = []
    var nodeSpawnZ: Array<Int> = []
    // Outlets
    // This is for the popup screen
    @IBOutlet weak var constX: NSLayoutConstraint!
    // Last contact bullet node to prevent double contacts
    var lastBulletNode = SCNNode()
    
// MARK: - Views init and deint
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the views
        displayForSecondView(view: self.popUpView)
        addCornerRadiusToButton(button: dismissPopUp)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        if #available(iOS 12.0, *) {
           // configuration.environmentTexturing = .automatic
        }

        // Run the view's session
        sceneView.session.run(configuration)
        // sceneView.session.delegate = self as? ARSessionDelegate
        sceneView.delegate = self

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.scene.physicsWorld.contactDelegate = self

        // Set Notification Observer for messageLabel
        NotificationCenter.default.addObserver(self, selector: #selector(updateHUDLabel(_:)), name: .kHUDLabelNotification, object: nil)
        
        // Set up initial message label
        message = kGameMsgLoading
        messageLabel.text = message
        
        // Hide the Start Button initallay
        startButton.isHidden = true
        startButton.isEnabled = false
        dismissPopUp.isEnabled = false
        
        // Populate the audio sounds
        populateAudioSounds()

        // Any Setups
        // This one gets a random number for the array position, so that no nodes are in the same place, when they appear.
        createArraysForNodeAppearance()
        
        // Fetch the Friends Data
        performFetch()
        populateFriends()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // print("viewWillDisappear")
        // Clear Nodes
        self.sceneView.scene.rootNode.enumerateChildNodes { (existingNodes, _) in
            existingNodes.removeAllActions()
            existingNodes.removeAllAudioPlayers()
            existingNodes.removeAllParticleSystems()
            existingNodes.physicsBody = nil
            existingNodes.removeFromParentNode()
            existingNodes.geometry = nil
        }
    }
    
    deinit {
        // print("Deint")
        fetchedResultsController.delegate = nil

        sceneView.session.delegate = nil
        sceneView.delegate = nil
        sceneView.scene.removeAllParticleSystems()

//        popUpView = nil
//        sceneView?.session.pause()
//        sceneView?.removeFromSuperview()
        audioShootPlayer = nil
        sceneView.scene.rootNode.cleanup()
        sceneView = nil
    }
    
    
    func configureView() {
        if managedContext == nil {
            // print("configureView - managedContext == nil")
            abortApp(abortType: "Data")
            // return
        }
    }
    
    // MARK: - Labels, Audio and Messages
    // For Updating the in Game label
    @objc func updateHUDLabel(_ notification: Notification) {
                
        if let newMessage = notification.userInfo!["NewMessage"] as? String {
            // Set notification label and do animation for the label
            let notificationText = newMessage
            fadeInAndOutLabel(text: notificationText)
        }
    }
    
    // Aniamte the label
    func fadeInAndOutLabel(text: String) {
        
        DispatchQueue.main.async { [weak self] in
            // The set the text
            self?.messageLabel.text = text
            // Then fade in
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self?.messageLabel.alpha = 1.0
                
            }, completion: { (finished: Bool) -> Void in
                // Then fade back out
                UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self?.messageLabel.alpha = 0.0
                }, completion: nil )
            })
        }
    }
    
    // New Mesage Received for Notification
    func loadNewMessage(newMessage: String) {
        
        let dic = ["NewMessage":newMessage]
        NotificationCenter.default.post(name: .kHUDLabelNotification, object: nil, userInfo: dic)
    }
    
    //MARK: Audio
       // Find that initial load helps loading the sound for more efficient display
    func populateAudioSounds() {
        
        // Get the audio sound
        getAudioShoot = returnAudioSound(type: "shoot")
        if let audioSource = getAudioShoot {
            audioSource.load()
            audioShootPlayer = SCNAudioPlayer(source: audioSource)
        }
        
        getAudioExplosion = returnAudioSound(type: "explosion")
    }
    
    //MARK: Nodes and Positions
    // Random place for Nodes to appear
    func createArraysForNodeAppearance() {
        // We create the arrays for X and Z range.
        // We use MaxZ as the start as this is a higher negative amount.
        nodeSpawnX = createRangeOfArrays(start: kMinX, end: kMaxX)
        nodeSpawnZ = createRangeOfArrays(start: kMaxZ, end: kMinZ)
    }
    
    // For random positions of the nodes
    func getRandomPosition(position: Character) -> Int {
        
        // We get random element from the arrays for X and Y then remove them fron array, when no longer needed (so that there are no nodes in a duplicate position).
        if position == "x" {
            guard let posX = nodeSpawnX.randomElement() else { return -1 }
            if let index = nodeSpawnX.firstIndex(of: posX) {
                nodeSpawnX.remove(at: index)
                
            }
            return posX

        } else if position == "z" {
            guard let posZ = nodeSpawnZ.randomElement() else { return -1 }
            if let index = nodeSpawnZ.firstIndex(of: posZ) {
                nodeSpawnZ.remove(at: index)
                
            }
            return posZ
        }
        // We set a default of -1 as we don't want any nodes being Z = 0
        return -1
    }
    
    
   
    //MARK: App in Background
    func appIsInBackground() {
        
        // To stop the timer etc
        sceneView.scene.isPaused = true
        
        sceneView.scene.rootNode.childNodes.filter({
            $0.physicsBody?.categoryBitMask == 4 }).forEach({
                //                // print("Node Enumerate -\($0.name)")
                if !$0.hasActions {
                    $0.removeAllActions()                }
                
            })
        
        self.navigationController?.popToRootViewController(animated: true)

    }
    
    func appIsOnHold() {
        
        // To stop the timer etc
        if !gameIsPaused {
            gameIsPaused = true
            sceneView.scene.isPaused = true
        } else {
            sceneView.scene.isPaused = false
            gameHasBecomeActive = true
            gameIsPaused = false
        }
    }
    
    // MARK: - Core Data
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
            try fetchedResultsController.performFetch()
            
        } catch let error as NSError {

            print("Could not fetch \(error), \(error.userInfo)")
            abortApp(abortType: "Data")
        }
    }
    
    //MARK: Adding Nodes
    func populateFriends() {
        
        if managedContext == nil {
            // print("populateFriends - managedContext == nil")
             abortApp(abortType: "Data")
            // return
            
        } else {
            DispatchQueue.global(qos: .background).sync { [unowned self] in
                let request: NSFetchRequest<Friend> = Friend.fetchRequest()
                
                do {
                    // Get results of friends request
                    let results = try self.managedContext.fetch(request)
                    var friendsArray = Array<friend>()
                    // Fetch List Records
                    for result in results {
                        let name = result.value(forKey: "name") ?? "no-name-given"
                        let imageData = result.value(forKey: "friendImage") ?? nil
                        var image = UIImage()
                        if let imageAvailable = imageData {
                            // Image exists
                            image = UIImage(data: imageAvailable as! Data)!
                        }

                        // Create an object
                        let target = friend.init(withName: name as! String, withImage: image)
                        // Add the friends array
                        friendsArray.append(target)
                        
                    }
                    
                    // Send array of friends to be added onto the game
                    self.addBoxNodeToScene(friendDetails: friendsArray)
                    self.targetsOnScreen = true
                    // Set initial Message
                    self.message = kGameMsgStart

                    // As the targets are on the screen, we can now show the Start Button
                    DispatchQueue.main.async { [weak self] in
                        self?.startButton.isHidden = false
                        self?.startButton.isEnabled = true
                        self?.messageLabel.text = self?.message
                    }
                    
                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                    abortApp(abortType: "Data")
                }
            }
            
        }
    }
    
    func addBoxNodeToScene(friendDetails: Array<friend>) {
        
        guard friendDetails.count > 0 else {
            // print("ERROR NO NODES")
            abortApp(abortType: "Data")
            return
        }
        
        for friend in friendDetails {
            
            // Create box node
            let box = SCNBox(width: 1.0, height: 1.0, length: 1.0,
                             chamferRadius: 0.0)
            // Create side images of colour for the box
            let colorMaterial = SCNMaterial()
            colorMaterial.diffuse.contents = UIColor.green
            colorMaterial.isDoubleSided = true
            
            
            // Get node name and image
            let nodedName = friend.name
            
            if let checkForImage = friend.image {
                
                //let image = checkForImage
                let newImage = checkForImage.resizedImage(newSize: CGSize(width: 50, height:  50))
                           
                // Set the sides which display the image
                let imageMaterial = SCNMaterial()
                imageMaterial.diffuse.contents = newImage
                imageMaterial.locksAmbientWithDiffuse = true
                imageMaterial.isDoubleSided = true
                
                box.materials = [colorMaterial, imageMaterial, imageMaterial, imageMaterial, colorMaterial, colorMaterial]
            } else {
                // If no image then we make the whole box with colours
                box.materials = [colorMaterial, colorMaterial, colorMaterial, colorMaterial, colorMaterial, colorMaterial]
            }
            
           
            
            // Add these details to the node
            let targetNode = SCNNode(geometry: box)
            targetNode.name = nodedName
            targetNode.scale = SCNVector3(0.9, 0.9, 0.9)
            
            // Position of node
            let x = CGFloat(getRandomPosition(position: "x"))
            let y = randomNumbers(numA: CGFloat(kMinY), numB: CGFloat(kMaxY))
            let z = CGFloat(getRandomPosition(position: "z"))
            targetNode.position = SCNVector3(x,y,z)
            
            // Set the Physics body
            targetNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: targetNode, options: nil))
            //TODO:- Need to come back to this
            targetNode.categoryBitMask = BitMaskCategory.target.rawValue
            targetNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
            targetNode.physicsBody?.collisionBitMask = BitMaskCategory.target.rawValue
            //TODO:- Need to play around with this
            targetNode.physicsBody?.restitution = 1.5
            // Add to view
            DispatchQueue.main.async { [weak self] in
                self?.sceneView.scene.rootNode.addChildNode(targetNode)
                self!.friends = self!.friends + 1
            }
        }
    }
    
    // Every time a bullet hits a node we change the colour of the node
    func returnColourForNode(existingColour: UIColor) -> UIColor {
        
        var newColour = existingColour
        
        if existingColour == UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0) {
            // Green to blue
            newColour = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
            
        } else if existingColour == UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0) {
            // Blue to Red
            newColour = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            
        } else if existingColour == UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0) {
            // red -> black
            newColour = UIColor(white: 0, alpha: 1)
            
        } else if existingColour == UIColor(white: 0, alpha: 1) {
            // G black -> Stay black, no action
            
        } else {
            // Keep it green (initial choice in case a problem)
            newColour = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        }
        
        return newColour
        
    }
    
    // MARK:- Node Collision
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if collisionInProgress {
            // Collision already in place so we can remove.
            return
        }
        
        // Check to see if the last node does not equal the new bullte node, if it does not allocate it
        // If it does, it means it is the same node as before and that it is causing a contact twice.
        if lastBulletNode != contact.nodeB {
            // print("Not the same node")
            lastBulletNode = contact.nodeB
        } else {
            // print("Same bullet node - set to avoid collision")
            
            return
        }
        
        // Some nodes collide twice and some nodes are the same so don't need to run all the way through.
        var duplicateCollisionOrSameNode = false
        collisionInProgress = true
        
        // collision for nodes, create a target node and contact nodes
        weak var targetNode: SCNNode?
        weak var nodeA = contact.nodeA
        weak var nodeB = contact.nodeB
        
//        let nodeAMask = nodeA?.categoryBitMask
//        // let nodeAMaskTest = nodeA?.physicsBody?.categoryBitMask
//        let nodeBMask = nodeB?.categoryBitMask
//        // let nodeBMaskTest = nodeB?.physicsBody?.categoryBitMask
//        // print("Node Masks - \(String(describing: nodeAMask)), \(String(describing: nodeBMask))")

        // print("NodeA Name - \(String(describing: nodeA?.name)) / NodeA Position - \(String(describing: nodeA?.worldPosition)) / NodeB Name - \(String(describing: nodeB?.name))/ NodeB Position - \(String(describing: nodeB?.position))")

        // print("Node Info \(String(describing: nodeA)), \(String(describing: nodeB))")
        
        if nodeA?.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            targetNode = nodeA
            
        } else if nodeB?.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            targetNode = nodeB
            
        }
        
        // Check if it is two Friends nodes, clashing; if so, bounce off each other.
        // *** This has been removed as causes memory leaks.
        // Will return to it another time.
        /* if nodeAMask == nodeBMask {
         nodeA?.removeAllActions()
         nodeB?.removeAllActions()
         
         let aX = Double((nodeA?.position.x)!)
         let bX = Double((nodeB?.position.x)!)
         
         var nodeAAction = SCNAction()
         var nodeBAction = SCNAction()
         
         if aX < bX {
         nodeAAction = moveNodesAfterCollision(moveNodeLeft: true)
         nodeBAction = moveNodesAfterCollision(moveNodeLeft: false)
         } else {
         nodeAAction = moveNodesAfterCollision(moveNodeLeft: false)
         nodeBAction = moveNodesAfterCollision(moveNodeLeft: true)
         }
         // Run the actions
         nodeA?.runAction(nodeAAction)
         nodeB?.runAction(nodeBAction)
         
         duplicateCollisionOrSameNode = true
         } */
        
        // Bullet will always be node B, not nodeA
        if nodeB?.physicsBody?.categoryBitMask == BitMaskCategory.bullet.rawValue {
            
            if (nodeB?.physicsBody) == nil {
                duplicateCollisionOrSameNode = true
            }
            nodeB?.physicsBody?.contactTestBitMask = 0
            nodeB?.physicsBody?.categoryBitMask = 0
            nodeB?.categoryBitMask = 0
            nodeB?.physicsBody = nil
            
        }
        
        // Temp variable for updating the HUD
        // We will use this further down for updating the message on the screen
        var tempMessage = ""
        // We do not want to try and change colour of node, if it does not exist
        guard (targetNode?.geometry?.firstMaterial?.diffuse.contents) != nil else {
            return
        }
        
        // Get the current colour so we can change later when hit
        let currentColour = targetNode?.geometry?.firstMaterial!.diffuse.contents as! UIColor
        // We will use the particle system
        unowned var particle: SCNParticleSystem
        
        if !duplicateCollisionOrSameNode {
            // We want to check if Target Killed or not, to that we can add the right sound.
            var targetKilled = Bool()
            
            // 4. If Black means it has been hit 3 times
            if currentColour == UIColor(white: 0, alpha: 1) {
                // Set fire particle
                particle = bulletHitEffect(particleName: "target.scnassets/Fire.scnp", directory: nil, loops: false, lifeSpan: 3)
                
                // Update stats and message
                targetKilled = true
//                // print("You KILLED \(targetNode?.name ?? "No Name")")

                tempMessage = String(format:
                NSLocalizedString("WHO YOU KILLED LABEL",
                comment: "Message for killing target"),
                targetNode?.name ?? "")
                
                killedFriends.append(targetNode?.name ?? "")
                points += 10
                kills += 1
                friends -= 1
                // Clear the node details
                targetNode?.physicsBody = nil
                targetNode?.removeFromParentNode()
                targetNode?.removeAllActions()
                targetNode?.geometry?.firstMaterial?.diffuse.contents = nil
                targetNode?.geometry?.firstMaterial?.normal.contents = nil
                targetNode = nil
                
            } else {
                // print("You HIT \(targetNode?.name ?? "No Name")")

                // Node isn't black so just a hit, not a kill.
                targetKilled = false
                particle = bulletHitEffect(particleName: "target.scnassets/HitSide.scnp", directory: nil, loops: false, lifeSpan: 3.0)
                
                tempMessage = String(format:
                NSLocalizedString("WHO YOU HIT LABEL",
                comment: "Message for hitting target"),
                targetNode?.name ?? "")
                
                points += 1
                // currentlyShooting = false
                // Spin the node after hit
                let parentRotation = rotation(time: 0.2)
                targetNode!.runAction(parentRotation)
                
            }
            
            // Set the particle
            let particleNode = SCNNode()
            particleNode.addParticleSystem(particle)
            particleNode.position = contact.contactPoint
            particleNode.scale = SCNVector3(0.3, 0.3, 0.3)
            
            if targetKilled {
                
                if let audioSource = getAudioExplosion {
                    audioSource.load()
                    let player = SCNAudioPlayer(source: audioSource)
//                    // print("\(player)")
                    nodeB?.addAudioPlayer(player)
                    
                }
                
            } else {
                // Now we cbage node colour as target is not killed.
                if let nodeToChangeColour = targetNode {
                    let getNewColour = returnColourForNode(existingColour: currentColour)
                    nodeToChangeColour.geometry?.firstMaterial?.diffuse.contents = getNewColour
                }
            }
            
            // Update the labels
            DispatchQueue.main.async { [weak self] in
                self?.pointsLabel.text = "\(self!.points)"
                self?.killsLabel.text = "\(self!.kills)"
                self?.friendsLabel.text = "\(self!.friends)"
                self?.sceneView.scene.rootNode.addChildNode(particleNode)
                // Fade in new message
                self?.loadNewMessage(newMessage: tempMessage)
            }
            
            particleNode.runAction(SCNAction.wait(duration: 2.0), completionHandler: ({
                // print("Remove Particle - \(particleNode)")
                particleNode.removeFromParentNode()
                particleNode.geometry = nil
            }))
        }
        
        collisionInProgress = false
    }
  
    // Use this for testing when have memory leaks when nodes twice hit each other
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        // collisionInProgress = false
        
        // print("physicsWorld - didEnd")
//        weak var nodeA = contact.nodeA
//        weak var nodeB = contact.nodeB

        // print("Node Info for end - \(String(describing: nodeA)), \(String(describing: nodeB))")
      /*  nodeB?.removeFromParentNode()
        nodeB?.geometry = nil
        nodeB?.physicsBody = nil
        self.currentlyShooting = false
        self.collisionInProgress = false */

    }
        
    // Bullet Effect caused by collision
    func bulletHitEffect(particleName: String, directory: String?, loops: Bool, lifeSpan: CGFloat) -> SCNParticleSystem {
        let particle = SCNParticleSystem(named: particleName, inDirectory: directory)
        particle?.loops = loops
        particle?.particleLifeSpan = lifeSpan
        particle?.particleSize = 0.01
        return particle!
        
    }
        
    // MARK: Event Handler
    // This is when the user clicks the Start Button
    @IBAction func startPressed(_ sender: Any) {
        
        // If Targets not yet on screen or game started we can return
        if !targetsOnScreen && gameStarted {
            return
        }
        // Set Game Started
        gameStarted = true
        // Give new message to user that game has started
        loadNewMessage(newMessage: kDefaultLabel)
        
        // 1. We want to add the nodes to shoot.
        // We don't want to add if already finished
        if !gameFinished {
            // 2. No longer need the start button, so amend the game variables
            DispatchQueue.main.async { [weak self] in
                self?.startButton.isHidden = true
                self?.startButton.isEnabled = false
            }
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {

         gameFinished = true
         timerLabel.text = String(format: "%.2f", self.currentTime)
         message = kGameMsgExit

         // Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { [weak self] _ in
        self.endGame(message: self.message)
         //}
     }
    
    // MARK: Touches - fire bullets
    @objc func handleTap(sender: UITapGestureRecognizer) {
                
        // If currntly shooting then we return
        if currentlyShooting {
            return
        }
        
        // Cannot shoot if Game hasn't started.
        if !targetsOnScreen {
            return
        }
        
        // To get this far means the Targets are now on the screen
        if !gameStarted {
            let newMessage = kGameMsgStart1
            loadNewMessage(newMessage: newMessage)
            return
        }
        
        if gameFinished {
            return
        }
        
        // Set up the bullet
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfView = sceneView.pointOfView else {return}
        createBullet(pointOfView: pointOfView)
        
    }
    
    func createBullet(pointOfView: SCNNode) {
        
        self.currentlyShooting = true
        
      /*  DispatchQueue.global(qos: .userInitiated).sync { [weak self] in
          guard let self = self else {
            return
        
          }*/
            let transform = pointOfView.transform
            let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
            let position = orientation + location
        
            // print("Position = \(position)")
              
            let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
            bullet.name = "bullet"
            bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            bullet.position = position
            
            let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
            body.isAffectedByGravity = false
            bullet.physicsBody = body
            bullet.physicsBody?.applyForce(SCNVector3(orientation.x*self.power, orientation.y*self.power, orientation.z*self.power), asImpulse: true)
            bullet.physicsBody?.categoryBitMask = BitMaskCategory.bullet.rawValue
            bullet.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
            bullet.categoryBitMask = BitMaskCategory.bullet.rawValue
        
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                  return
              
                }
                self.sceneView.scene.rootNode.addChildNode(bullet)
                // print("bullet added \(bullet)")
                
                // Set the Audio
                if let audioSource = self.getAudioShoot {
                    
                    // Background Sync seems to work well here.
                    DispatchQueue.global(qos: .background).sync { [unowned self] in
                        self.audioShootPlayer = SCNAudioPlayer(source: audioSource)
                        bullet.addAudioPlayer(self.audioShootPlayer!)
    //                    // print("Audio - Bullet - \(String(describing: self.audioShootPlayer))")
                    }
                }
            }
            // Set actions
//            let clearAction = SCNAction.run { _ in
//                bullet.geometry = nil
//                bullet.physicsBody = nil
//            }

            let waitAction = SCNAction.wait(duration: 0.2)

            bullet.runAction(SCNAction.sequence(
                [waitAction, SCNAction.wait(duration: 0.5),
                SCNAction.removeFromParentNode()]),  completionHandler:
                ({ [unowned self] in
                    // print("bullet removed \(bullet)")
                    bullet.geometry = nil
                    bullet.physicsBody = nil
                    self.currentlyShooting = false
                    self.collisionInProgress = false
                })
            )
        //}
    }
    
    //MARK: End Game Setup
    // Show the pop up for ending the game
    func endGame(message: String) {
        
        guard message != "" else {
            return
        }
        
        // Update the stats for friends
        if !killedFriends.isEmpty {
              addKillPointsToFriend(killedFriends: killedFriends)
        }
        
        // Update the stats for total scores
        GameStateManager.sharedInstance().savePointsAndKills(kills: kills, points: points)
        
        let displayMessageAction = SCNAction.run { _ in
            DispatchQueue.main.async { [weak self] in
                self!.messageLabel.text = message

            }
        }

        let waitAction = SCNAction.wait(duration: 0.8)
        // Popup is the view with all the details
        sceneView.scene.rootNode.runAction(SCNAction.sequence(
            [displayMessageAction, waitAction]),  completionHandler:
            ({ [unowned self] in
                self.showPopUp()
            })
        )
    }
    
    // PopUp for ending the game and showing the scores
    func showPopUp() {
        
        //Get the Popupores
        updatePopUpScores()
                
        DispatchQueue.main.async { [weak self] in

            UIView.animate(withDuration: 1.0, delay: 1.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self?.constX.constant = 0
                self?.view.layoutIfNeeded()
                self?.dismissPopUp.isEnabled = true

               }, completion: nil)
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
                self?.backgroundButton.alpha = 0.5
                self!.sceneView.scene.isPaused = true

                }, completion: nil)
        }
    }
    
    // Add the PopUp Scores
    func updatePopUpScores() {
        // Get the total Kills and Points score
        let killsAndPoints = GameStateManager.sharedInstance().returnKillsAndPoints()
        let tKills = killsAndPoints.0
        let tPoints = killsAndPoints.1

        DispatchQueue.main.async { [weak self] in
            self?.gameKills.text = String(self!.kills)
            self?.gamePoints.text = String(self!.points)
            self?.totalKills.text = String(tKills)
            self?.totalPoints.text = String(tPoints)
        }
    }
    
    // This is the dismiss button from the popup window
    @IBAction func popUpButtonDismiss(_ sender: Any) {
        // As the popup is in bounds we need to put back.
        constX.constant = -1000
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.backgroundButton.alpha = 0.5
            self.dismissToMainScreen()
            }, completion: nil)
    }
    
    // Dismissed to main screen - send notification on how many killed etc
    func dismissToMainScreen() {
        
        let dic = ["GameReview":kills]
        NotificationCenter.default.post(name: .kGameReviewNotification, object: nil, userInfo: dic)
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)

    }

    // For updating the stats
    func addKillPointsToFriend(killedFriends: Array<String>) {
        // This can be done on the background queue
       // DispatchQueue.global(qos: .background).sync { [weak self] in
            
        let fetchResults = self.fetchedResultsController.fetchedObjects
  
            do {
                if let results = fetchResults {

                    // Fetch List Records
                    for fetch in results {

                        let name = fetch.value(forKey: "name") as! String
                        
                        if killedFriends.contains(name) {

                            var currentKilled = fetch.value(forKey: "killed") as! Int
                            currentKilled = currentKilled + 1
                            fetch.setValue(Int64(currentKilled), forKey: "killed")
                        }
                    }
                    try self.managedContext.save()
                }
            } catch let error as NSError {
                //TODO:- Core Data Error Handling
                print("Could not fetch \(error), \(error.userInfo)")
                abortApp(abortType: "Data")
            }
       // }
    }
   
    // MARK: - Movement and Animation
    func rotation(time: TimeInterval) -> SCNAction {
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: time)
        return rotation
    }
    
    // Movement methods called by moveNodes method to see if we can move in this direction
    func getDirection(movement: Movement, amountToMove: CGFloat) -> SCNVector3 {
        
        var move: SCNVector3
        switch movement {
            case .left, .right:
                move = SCNVector3(amountToMove, 0, 0)
                return move
            case .down, .up:
                move = SCNVector3(0, amountToMove, 0)
                return move
            case .backwards, .forwards:
                move = SCNVector3(0, 0, amountToMove)
                return move
            case.noneSet:
                move = SCNVector3(0, 0, 0)
                return move
        }
    }
    
    // Called by extension to see if we can move node
    func setNodeToMove(node: SCNNode) -> SCNAction {
        let nodeMovement = moveNode(nodePosition: node.position)
        return nodeMovement
    }
    
    // We take the node argument for when calling the boundaries check
    func moveNode(nodePosition: SCNVector3) -> SCNAction  {
        
        // 1. Create the constants for this functions
        let randomPlus = randomNonWholeNumbers(numA: 4, numB: 0)
        // let durationRandom = randomNonWholeNumbers(numA: 3.5, numB: 2.0)
        let duration = gameSpeed
        let randomNegative = -randomPlus

        // 2. Create the SCNVectors for the movement
        let moveDown = getDirection(movement: .down, amountToMove: randomNegative)
        let moveUp = getDirection(movement: .up, amountToMove: randomPlus)
        let moveLeft = getDirection(movement: .left, amountToMove: randomNegative)
        let moveRight = getDirection(movement: .right, amountToMove: randomPlus)
        let moveForwards = getDirection(movement: .forwards, amountToMove: randomPlus)
        let moveBackwards = getDirection(movement: .backwards, amountToMove: randomNegative)
        
        // 3. Do a random movement 0 - 5
        // 4. Create a movement variable for action
        let moveDirectionChoice = Int(arc4random_uniform(6))
        var movement: SCNAction
        
        // 5. Switch through the random numbers
        // 6. If the movement is safe to move in that direction, then it can move, otherwise it moves the opposite way.
        switch moveDirectionChoice {
        case 0: // left
            if canNodeMove(nodePosition: nodePosition, newPosition: moveLeft, moveDirection: Movement.left) {
                movement = SCNAction.move(by: moveLeft, duration: TimeInterval(duration))
            } else {
                movement = SCNAction.move(by: moveRight, duration: TimeInterval(duration))
            }
        case 1: // right
            if canNodeMove(nodePosition: nodePosition, newPosition: moveRight, moveDirection: Movement.right) {
                movement = SCNAction.move(by: moveRight, duration: TimeInterval(duration))
            } else {
                movement = SCNAction.move(by: moveLeft, duration: TimeInterval(duration))
            }
        case 2: // down
            if canNodeMove(nodePosition: nodePosition, newPosition: moveDown, moveDirection: Movement.down) {
                movement = SCNAction.move(by: moveDown, duration: TimeInterval(duration))
            } else {
                movement = SCNAction.move(by: moveUp, duration: TimeInterval(duration))
            }
        case 3: // up
            if canNodeMove(nodePosition: nodePosition, newPosition: moveUp, moveDirection: Movement.up) {
                movement = SCNAction.move(by: moveUp, duration: TimeInterval(duration))
            } else {
                movement = SCNAction.move(by: moveDown, duration: TimeInterval(duration))
            }
        case 4: // backwards
            if canNodeMove(nodePosition: nodePosition, newPosition: moveBackwards, moveDirection: Movement.backwards) {
                movement = SCNAction.move(by: moveBackwards, duration: TimeInterval(duration))
            } else {
                movement = SCNAction.move(by: moveForwards, duration: TimeInterval(duration))
            }
        case 5: // forwards
            if canNodeMove(nodePosition: nodePosition, newPosition: moveForwards, moveDirection: Movement.forwards) {
                movement = SCNAction.move(by: moveForwards, duration: TimeInterval(duration))
            } else {
                movement = SCNAction.move(by: moveBackwards, duration: TimeInterval(duration))
            }
        default:
            movement = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: TimeInterval(duration))
        }
        
        let moveSequence = SCNAction.sequence([movement])
        return moveSequence
    }
    
    // This is called if a node goes out of bounds - as We don't want the nodes to go out of bounds
    func canNodeMove(nodePosition: SCNVector3, newPosition: SCNVector3, moveDirection: Movement) -> Bool {
        
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
        case .noneSet:
            nodeCanMove = false
            
        }
        return nodeCanMove
        
    }
    
    // Node might be out of bounds, move to random position.
    func moveNodetoRandomPosition(node: SCNNode) {
        // This creates a new random position
        let newPosition = createRandomPosition()
        let move = SCNAction.move(to: newPosition, duration: gameSpeed)
        node.runAction(move)
        
    }
    
    // After Nodes have collided they go off in different directions
    // *** METHOD NOT IN USE
    func moveNodesAfterCollision(moveNodeLeft: Bool) -> SCNAction {
        // Get both directions
        let moveLeft = getDirection(movement: .left, amountToMove: -3)
        let moveRight = getDirection(movement: .right, amountToMove: 3)
        let moveUp = getDirection(movement: .up, amountToMove: -3)
        let moveDown = getDirection(movement: .down, amountToMove: 3)
        
        let duration = 1.2
                
        var move1: SCNAction
        var move2: SCNAction
        
        // One node goes one way, the other goes the other.
        if moveNodeLeft {
            move1 = SCNAction.move(by: moveLeft, duration: duration)
            move2 = SCNAction.move(by: moveUp, duration: duration)
        } else {
            move1 = SCNAction.move(by: moveRight, duration: duration)
            move2 = SCNAction.move(by: moveDown, duration: duration)
        }
        
        let moveSequence = SCNAction.sequence([move1, move2])

        return moveSequence
    }
    
    // Check If InBounds, just in case it goes off screen.
    func checkIfInBounds(nodePosition: SCNVector3) -> Bool {
        
        var isInBounds = true
        
        if Int(nodePosition.x) < kMinX || Int(nodePosition.x) > kMaxX
        || Int(nodePosition.y) < kMinY || Int(nodePosition.y) > kMaxY
        || Int(nodePosition.z) > kMinZ || Int(nodePosition.z) < kMaxZ {
            // Node it out of bounds
            isInBounds = false
        }
        return isInBounds
    }
    
    // If node is out of bounds we need to move it
    func createRandomPosition() -> SCNVector3 {
        
        let x = Float(Int.random(in: kMinX...kMaxX))
        let y = Float(Int.random(in: kMinY...kMaxY))
        let z = Float(Int.random(in: kMaxZ...kMinZ))
        let randomPosition = SCNVector3(x, y, z)
        
        return randomPosition
    }
    
    //MARK: Helper methods
    // Random Numbers flost
    func randomNumbers(numA: CGFloat, numB: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(numA - numB) + min(numA, numB)
    }
    
    func randomNonWholeNumbers(numA: CGFloat, numB: CGFloat) -> CGFloat {
        let randomNumber =  CGFloat(arc4random()) / CGFloat(UINT32_MAX) * (numA - numB) + min(numA, numB)
        let roundedNumber = (randomNumber*100).rounded()/100
//        // print(roundedNumber)  // 1.57
        return roundedNumber
    }
    
    // To check to see if user is facing the wrong way
    func checkIfPhoneNotInPosition() {
        
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        // print("Position = \(position)")
        
        // If user needs to turn the device around, let them know
        if position.z > 0.0 {
            loadNewMessage(newMessage: NSLocalizedString("Turn Device Around", comment: "In Game Message"))
            notifiedUserToTurnPhoneAround = true // We don't want to keep on sending this message, so set it to true and only call this method when false
        }
        
        if notifiedUserToTurnPhoneAround {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                self!.notifiedUserToTurnPhoneAround = false // Can notify user again
            }
        }
    }
    
    // MARK: - Session functions
    func session(_ session: ARSession, didFailWithError error: Error) {

        // print("SESSION ERROR didFailWithError - \(error)")
        abortApp(abortType: "Session")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        // print("Session was interrupted")
        abortApp(abortType: "Session")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
        // print("Need to add an Exit Game and leave")

    }
    
    // If need to abort function
    func abortApp(abortType: String) {
        
        // Get the type we are aborting, i.e. Core Data, retrieve it from the Helper function
        let alertSheet = abortDueToIssues(type: abortType)
        
        self.present(alertSheet, animated: true, completion: nil)

    }
    
    /*
    @available(iOS 11.3, *)
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // print("adjust frame")
        
        guard let currentFrame = sceneView.session.currentFrame?.camera else { return }
        let transform = currentFrame.transform
        sceneView.session.setWorldOrigin(relativeTransform: transform)
        
    }*/
}

//MARK:- SceneView Delegate
extension GameController: ARSCNViewDelegate {
    
//MARK:- Renders
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // print("update renderer node")
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
//        let currentPosition = sceneView.scene.sess
       // // print("World Position ")
        if !gameStarted || gameIsPaused {
            return // Won't start the updates until all started and uptodate
        }

        if !gameFinished {
            
            // In case if the phone is turned, but no point if already notified user.
            if !notifiedUserToTurnPhoneAround {
                checkIfPhoneNotInPosition()

            }
            
            // If coming out of Backgrond interription
            if gameHasBecomeActive {
                // We have to make sure that we reset previous time
                previousTime = time
                gameHasBecomeActive = false
                return
            }
            
            // If default value, then set to the same as time
            if previousTime == 0.0 {

                previousTime = time
                DispatchQueue.main.async { [weak self] in
                    // 3
                    self?.timerLabel.text = String(format: "%.2f", self!.currentTime)
                    }
                    return //
            }

            // Work out current time minus previous time for countdown
            let elapsedTime = time - previousTime
            previousTime = time
            currentTime = currentTime - elapsedTime
            
//            // print("Current time = \(currentTime)")
            
            DispatchQueue.main.async { [weak self] in
                // 3
                self?.timerLabel.text = String(format: "%.2f", self!.currentTime)
            }
            
            // Check if we have reached zero
            if currentTime <= 0.0  {
                // set game as finished & stop the timer
                gameFinished = true
                
                DispatchQueue.main.async { [weak self] in
                    self?.timerLabel.text = String(format: "%.2f", 00.00)
                }
                
                message = kGameMsgTime
               // Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                self.endGame(message: self.message)
                return
                //}
            }

            // If all friends are killed
            if friends == 0 && kills >= 0 {
                gameFinished = true
              //  Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                self.message = kGameMsgWon
                self.endGame(message: self.message)
                return
               // }
            }
            
            
            // The friends haven't loaded up properly
            if friends == 0 {
                gameFinished = true
              //  Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    self.message = NSLocalizedString("Game Exiting. Try Again!", comment: "In Game Message")
                    self.endGame(message: self.message)
               // }
            }
            
            // Enumerate through all the Friend nodes to see if we can move or not
            sceneView.scene.rootNode.childNodes.filter({
                $0.physicsBody?.categoryBitMask == 4  && !$0.hasActions}).forEach({
                
                let isInBounds = checkIfInBounds(nodePosition: $0.position)
                
                if isInBounds {
                    // Can mve node
                    weak var action = setNodeToMove(node: $0)
                    $0.runAction(action!)
                                    
                } else {
                    // Move node to random position
                    moveNodetoRandomPosition(node: $0)
                    
                }
            })
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

// To clean up the nodes
extension SCNNode {
    func cleanup() {
        // print("Child Called")

        for child in childNodes {
            // print("Child - \(child)")
            child.removeFromParentNode()
            child.cleanup()
        }
        // print("Child - End of loop")

        geometry = nil
    }
}
