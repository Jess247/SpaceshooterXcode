//
//  Mainmenue.swift
//  SpaceShooter
//
//  Created by jessica Singletary  on 21.05.20.
//  Copyright © 2020 jessica Singletary . All rights reserved.
//

import SpriteKit

class Mainmenue: SKScene {
    
    let playButton = SKSpriteNode(imageNamed: "play_blue")
    let optionsButton = SKSpriteNode(imageNamed: "Menu Screen/optionst_buttons_pressed")
    let exitButton = SKSpriteNode(imageNamed: "Menu Screen/exit_buttons_pressed")
    
    let background1 = SKSpriteNode(imageNamed: "bg")
    let background2 = SKSpriteNode(imageNamed: "bg")
    
    override func didMove(to view: SKView) {
        
        // Buttons zum Menue hinzufuegen
        playButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 1.67)
        playButton.setScale(0.5)
        self.addChild(playButton)
        
        //Options
        optionsButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        optionsButton.setScale(0.5)
        addChild(optionsButton)
        
        // Exit
        exitButton.position = CGPoint(x: self.size.width / 2 , y: self.size.height / 2.5)
        exitButton.setScale(0.5)
        addChild(exitButton)
        
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            let locationUser = touch.location(in: self)
            
            if atPoint(locationUser) == playButton {
                
                // Transition animation
                let transition = SKTransition.crossFade(withDuration: 3)
                
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
           // Vor jedem Frame abgerufen
        // Bacground bewegt sich jeden frame um 5 points nach unten
             background1.position.y -= 5
             background2.position.y -= 5
             
             // wenn der Background kleiner als seine eigene hoehe ist wird er auf die Aktuelle Position des andern Background plus seine eigene hoehe gesetzt, ein loop
             if background1.position.y < -background1.size.height {
                 background1.position.y = background2.position.y + background2.size.height
             }
             
             if background2.position.y < -background2.size.height {
                 background2.position.y = background1.position.y + background1.size.height
             }
    }
}
