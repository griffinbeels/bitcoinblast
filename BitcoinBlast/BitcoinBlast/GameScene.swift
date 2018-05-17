//
//  GameScene.swift
//  BitcoinBlast
//
//  Created by Griffin Beels on 1/27/18.
//  Copyright © 2018 Griffin Beels. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?

    override func didMove(to view: SKView) {
        // Get label node from scene and store it for use later
    }
    
    func touchDown(atPoint pos : CGPoint) {
        print("hey")
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
