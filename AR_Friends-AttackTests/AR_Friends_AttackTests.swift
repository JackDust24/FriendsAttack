//
//  AR_Friends_AttackTests.swift
//  AR_Friends-AttackTests
//
//  Created by JasonMac on 24/9/2562 BE.
//  Copyright © 2562 JasonMac. All rights reserved.
//

import XCTest
import SceneKit
@testable import FriendsAttack


class AR_Friends_AttackTests: XCTestCase {
    
    var gameController = GameController()
    
    let moveDown = SCNVector3(0, -2, 0)
    let moveUp = SCNVector3(0, 2, 0)
    let moveLeft = SCNVector3(-2, 0, 0)
    let moveRight = SCNVector3(2,0,0)
    let moveForwards = SCNVector3(0, 0, 2)
    let moveBackwards = SCNVector3(0,0, -2)


    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPassMoveLeft() {
        
        let passPosition = SCNVector3(-2, 0, 0)
        print(passPosition)
        
        _ = gameController.testCall()
        print(Movement.left.rawValue)
        print(Movement.left)
        let result = gameController.canNodeMove(nodePosition: passPosition, newPosition: moveLeft, moveDirection: Movement.left)
        XCTAssertEqual(result, true, "testPassMoveLeft is a success")
    }

    func testPassMoveRight() {
        
        let passPosition = SCNVector3(2, 0, 0)
        print(passPosition)
        
        let result = gameController.canNodeMove(nodePosition: passPosition, newPosition: moveRight, moveDirection: Movement.right)
        XCTAssertEqual(result, true, "testPassMoveRight is a success")
    }
    
    func testPassMoveUp() {
        
        let passPosition = SCNVector3(0, 2, 0)
        print(passPosition)

        let result = gameController.canNodeMove(nodePosition: passPosition, newPosition: moveUp, moveDirection: Movement.up)
        XCTAssertEqual(result, true, "testPassMoveUp is a success")
    }
    
    func testPassMoveDown() {
        
        let passPosition = SCNVector3(0, -2, 0)
        print(passPosition)

        let result = gameController.canNodeMove(nodePosition: passPosition, newPosition: moveDown, moveDirection: Movement.down)
        XCTAssertEqual(result, true, "testPassMoveDown is a success")
    }

    func testPassMoveForwards() {
        
        let passPosition = SCNVector3(0, 0, -3)
        print("Forwards - \(passPosition)")
        let test = Int(passPosition.z) + Int(moveForwards.z)
        print("Forwards - \(test)")

        let result = gameController.canNodeMove(nodePosition: passPosition, newPosition: moveForwards, moveDirection: Movement.forwards)
        XCTAssertEqual(result, true, "testPassMoveForwards is a success")
    }

    func testPassMoveBackwards() {
        
        let passPosition = SCNVector3(0, 0, -2)
        print(passPosition)

        let result = gameController.canNodeMove(nodePosition: passPosition, newPosition: moveBackwards, moveDirection: Movement.backwards)
        XCTAssertEqual(result, true, "testPassMoveBackwards is a success")
    }

    /* FAIL TESTS */
    func testFailMoveLeft() {
        
        let failPosition = SCNVector3(-6, 0, 0)
        print(failPosition)

        let result = gameController.canNodeMove(nodePosition: failPosition, newPosition: moveLeft, moveDirection: Movement.left)
        XCTAssertEqual(result, false, "testFailMoveLeft is a failure")
    }

    func testFailMoveRight() {
        
     let failPosition = SCNVector3(6, 0, 0)
     print(failPosition)

        let result = gameController.canNodeMove(nodePosition: failPosition, newPosition: moveRight, moveDirection: Movement.right)
     XCTAssertEqual(result, false, "testFailMoveRight is a failure")
    }

    func testFailMoveUp() {
        
     let failPosition = SCNVector3(0, 6, 0)
     print(failPosition)

        let result = gameController.canNodeMove(nodePosition: failPosition, newPosition: moveUp, moveDirection: Movement.up)
     XCTAssertEqual(result, false, "testFailMoveUp is a failure")
    }

    func testFailMoveDown() {
        
     let failPosition = SCNVector3(0, -6, 0)
     print(failPosition)

        let result = gameController.canNodeMove(nodePosition: failPosition, newPosition: moveDown, moveDirection: Movement.down)
     XCTAssertEqual(result, false, "testFailMoveDown is a failure")
    }

    func testFailMoveForwards() {
        
     let failPosition = SCNVector3(0, 0, -2)
     print(failPosition)

        let result = gameController.canNodeMove(nodePosition: failPosition, newPosition: moveForwards, moveDirection: Movement.forwards)
     XCTAssertEqual(result, false, "testFailMoveForwards is a failure")
    }

    func testFailMoveBackwards() {
        
     let failPosition = SCNVector3(0, 0, -4)
     print(failPosition)

        let result = gameController.canNodeMove(nodePosition: failPosition, newPosition: moveBackwards, moveDirection: Movement.backwards)
        XCTAssertEqual(result, false, "testFailMoveBackwards is a failure")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
