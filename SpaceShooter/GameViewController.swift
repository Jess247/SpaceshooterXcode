//
//  GameViewController.swift
//  SpaceShooter
//
//  Created by jessica Singletary  on 20.05.20.
//  Copyright © 2020 jessica Singletary . All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Scene soll den der groesse des jeweiligen views des geraetes entspechen
        let scene1 = Mainmenue(size: self.view.bounds.size)//Full screen
        let skView = self.view as! SKView // User view wird als skview gesetzt
        
        // FPS anzeigen (framerate)
        skView.showsFPS = true
        // Nodes anzeigen
        skView.showsNodeCount = true
        
        // ShowPyhsics
        skView.showsPhysics = true
        
        //performance zur einfolge beim rendern
        skView.ignoresSiblingOrder = true
        // Spielinhalt anzeigen
        skView.presentScene(scene1)
    }


}
