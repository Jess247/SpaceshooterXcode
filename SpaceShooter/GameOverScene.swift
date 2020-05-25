//
//  gameOverScene.swift
//  SpaceShooter
//
//  Created by jessica Singletary  on 21.05.20.
//  Copyright © 2020 jessica Singletary . All rights reserved.
//

import GameKit

class GameOverScene: SKScene {
    
    let background1 = SKSpriteNode(imageNamed: "bg2")
    let background2 = SKSpriteNode(imageNamed: "bg2")
    
    let gameOverLable = SKSpriteNode(imageNamed: "Menu Screen/exit_buttons")
    
    override func didMove(to view: SKView) {
        //backgound
               background1.anchorPoint = CGPoint.zero
               background1.position = CGPoint.zero
               background1.size = self.size
               background1.zPosition = -1
               addChild(background1)
               
               background2.anchorPoint = CGPoint.zero
               background2.position.x = 0
               background2.position.y = background1.size.height - 5
               background2.size = self.size
               background2.zPosition = -1
               addChild(background2)
    }
}
