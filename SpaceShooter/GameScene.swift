//
//  GameScene.swift
//  SpaceShooter
//
//  Created by jessica Singletary  on 20.05.20.
//  Copyright © 2020 jessica Singletary . All rights reserved.
//
import UIKit
import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    // ---------------------------------------------Global ------------------------------------------------
    
    // Physicsbody not working let spaceshipTexture = SKTexture(imageNamed: "ship")
    var spaceShip = SKSpriteNode(imageNamed: "ship")
    let backgroundScene1 = SKSpriteNode(imageNamed: "background")
    let backgroundScene2 = SKSpriteNode(imageNamed: "background")
    
    // ---------------------------------------------Audio ------------------------------------------------
    // mediaplayer muss optional falls keine Audiodatai vorhanden ist stuerzt die App nicht ab sonder audioplayer = nil
    var audioPlayer = AVAudioPlayer()
    var backgroundAudio: URL?
    // user soll sounds ausstellen koennen
    let soundOn = SKShapeNode(circleOfRadius: 20)
    let soundOff = SKShapeNode(circleOfRadius: 20)
    
    // Timer fur die Enemys
    var timerEnemy = Timer()
     
    // ---------------------------------------------Lables ------------------------------------------------

    var highscoreLable = SKLabelNode(fontNamed: "Arial")
    var currentScoreLable = SKLabelNode(fontNamed: "Arial")
    var currentScore = 0
    var highScore = UserDefaults.standard.integer(forKey: "HIGHSCORE")
    
    // ---------------------------------------------contactNo----------------------------------------------
    struct physicsBodyNumbers {
        static let spaceshipNumber: UInt32 = 0b1 // Binaere nummer 1
        static let bulletNumber: UInt32 = 0b10 // 2
        static let enemyNumber: UInt32 = 0b100 // 4
        static let emptyNumber: UInt32 = 0b1000 // 8
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // wer delegiert die Methode did begin bei contact zwischen elementen
        self.physicsWorld.contactDelegate = self
        
    // ---------------------------------------------Background----------------------------------------------
        self.backgroundColor = SKColor(red: 0, green: 104 / 255, blue: 139 / 255, alpha: 1.0)
        backgroundScene1.anchorPoint = CGPoint.zero // x0 y0 also links unten in der Ecke
        backgroundScene1.position = CGPoint.zero
        backgroundScene1.size = self.size // groesse entspricht der Scene auf jeden geraet gleich
        backgroundScene1.zPosition = -1 // Ebene des Backgrounds
        self.addChild(backgroundScene1)
        backgroundScene2.anchorPoint = CGPoint.zero
        backgroundScene2.position.x = 0
        backgroundScene2.position.y = backgroundScene1.size.height - 5
        backgroundScene2.size = self.size
        backgroundScene2.zPosition = -1
        self.addChild(backgroundScene2)
    // ---------------------------------------------Spaceship----------------------------------------------
        // Part of the physics not workint // spaceShip = SKSpriteNode(texture: spaceshipTexture)
        spaceShip.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 200)
        // groesse festlegen
        spaceShip.setScale(0.2)
        spaceShip.zPosition = 1
        // Physicsbody
        spaceShip.physicsBody = SKPhysicsBody(circleOfRadius: spaceShip.size.width / 2)
        spaceShip.physicsBody?.affectedByGravity = false
        spaceShip.physicsBody?.categoryBitMask = physicsBodyNumbers.spaceshipNumber
        spaceShip.physicsBody?.collisionBitMask = physicsBodyNumbers.emptyNumber
        spaceShip.physicsBody?.contactTestBitMask = physicsBodyNumbers.enemyNumber
        self.addChild(spaceShip)
    
    // ---------------------------------------------AudioPlayer---------------------------------------------
        backgroundAudio = Bundle.main.url(forResource: "Background", withExtension: "mp3")
        // Audioplayer error handling, App sturzt nicht ab bei Audiofehler
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: backgroundAudio!)
        }catch {
            print("Datei nicht gefunden")
        }
        // Backgroundmusic soll solange die applaeuf gespielt werden
        audioPlayer.numberOfLoops = -1
        audioPlayer.prepareToPlay() // verbesser die performance
        audioPlayer.play()
        // Musik an oder aus stellen
        soundOn.fillColor = SKColor.green
        soundOn.strokeColor = SKColor.clear
        soundOn.position = CGPoint(x: self.size.width - soundOn.frame.size.width, y: soundOn.frame.size.height)
        self.addChild(soundOn)
        soundOff.fillColor = SKColor.red
        soundOff.strokeColor = SKColor.clear
        soundOff.position = CGPoint(x: soundOff.frame.size.width, y: soundOff.frame.size.height)
        self.addChild(soundOff)
        
        // Enemy hinzufuegen
        timerEnemy = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(GameScene.addEnemy), userInfo: nil, repeats: true)
        
        // Herzen hinzufuegen
        addLifeToSpaceship(lifenum: 3)
        
        //--------------------------------------------Lables------------------------------------------
        highscoreLable.fontSize = 20
        highscoreLable.text = "Highscore: \(UserDefaults.standard.integer(forKey: "HIGHSCORE"))"
        highscoreLable.zPosition = 1
        highscoreLable.position = CGPoint(x: self.size.width - highscoreLable.frame.size.width - 10, y: self.size.height - highscoreLable.frame.size.height - 30)
        self.addChild(highscoreLable)
        
        currentScoreLable.fontSize = 20
        currentScoreLable.text = "Score: \(currentScore)"
        currentScoreLable.zPosition = 1
        currentScoreLable.position = CGPoint(x: highscoreLable.position.x, y: highscoreLable.position.y - currentScoreLable.frame.size.height - 10)
        self.addChild(currentScoreLable)
        
    }
    // ---------------------------------------------Highscore---------------------------------------------
    func saveHighScore()  {
        UserDefaults.standard.set(currentScore, forKey: "HIGHSCORE")
        highscoreLable.text = "Highscore: \(UserDefaults.standard.integer(forKey: "HIGHSCORE"))"
        
    }

    // ---------------------------------------------Life---------------------------------------------

    
    func addLifeToSpaceship(lifenum: Int)  {
        // Index beginnt bei null daher muss eins Herz abgezogen werden
        let lifeCount = lifenum - 1
        // Schleife lauft solage bis die Herzen aufgefuellt werden
        for index in 0...lifeCount {
            let lifeNode = SKSpriteNode(imageNamed: "heart")
            lifeNode.setScale(1.2)
            // Anchorpoint wird links in die Ecke gesetzt, x position ist der Index mal der Bild breite und die hoehe ist Screen hoehe minus die hoehe des Nodes (* 2 um mehr raum nach oben zu haben)
            // Default Anchorpont ist in der mitte vom Sprite
            lifeNode.anchorPoint = CGPoint(x: -1, y: 0)
            lifeNode.position.x = CGFloat(index) * lifeNode.size.width
            lifeNode.position.y = self.size.height - lifeNode.size.height * 2
            lifeNode.zPosition = 3
            addChild(lifeNode)
            
    
        }
       
    
    }
    
    

    
        // ---------------------------------------------Attac---------------------------------------------
    func addBulletToSpaceship(){
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.position = spaceShip.position
        bullet.setScale(0.3)
        bullet.zPosition = 0 // unter dem Spaceship
        bullet.name = "bullet"
        // Physiks
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.isDynamic = false
        bullet.physicsBody?.categoryBitMask = physicsBodyNumbers.bulletNumber
        bullet.physicsBody?.contactTestBitMask = physicsBodyNumbers.enemyNumber
        self.addChild(bullet)
        
        // action
        let moveTo = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 3)
        // Bullets sollen nach austreten aus dem View geloescht werden
        let delete = SKAction.removeFromParent()
        // nach dem die sequenz move to erreicht wurde, folgt delete
        bullet.run(SKAction.sequence([moveTo, delete]))
        
        
    }
    // ---------------------------------------------Enemy----------------------------------------------

    @objc func addEnemy() {
        // speichert nur bildinfomation ohne rendering besser fuer die Performance
        var enemyArray = [SKTexture]()
        // Enemybilder durchlaufen
        for index in 1...8 {
            enemyArray.append(SKTexture(imageNamed: "\(index)"))
        }
        let enemyTexture = SKTexture(imageNamed: "spaceship_enemy_start")
        let enemy = SKSpriteNode(texture: enemyTexture)
        enemy.setScale(0.2)
        // Enemys erhalten eine zufaellige Position auf der x Achse
        enemy.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(self.size.width))) + 20, y: self.size.height)
        //nicht in grad sonder Radien pi Formel (M_PI / 180)
        enemy.zRotation = CGFloat(((Double.pi / 180) * 180))
        enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemy.size.width / 2, height: enemy.size.height / 2))
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = physicsBodyNumbers.enemyNumber
        enemy.physicsBody?.collisionBitMask = physicsBodyNumbers.emptyNumber
        enemy.physicsBody?.contactTestBitMask =  physicsBodyNumbers.bulletNumber
        
        self.addChild(enemy)
        
        // Animation
        enemy.run(SKAction.repeatForever(SKAction.animate(with: enemyArray, timePerFrame: 0.1)))
        
        // Bewegung des Raumschiffs
        let moveDown = SKAction.moveTo(y: -enemy.size.height, duration: 3)
        let delete = SKAction.removeFromParent()
        
        enemy.run(SKAction.sequence([moveDown,delete]))
    }
    // ---------------------------------------------Contacts----------------------------------------------

    // Auch Actionsounds sollen im mute modus abgestellt sein
    var enemyHitSound: Bool = true
    
    // Explosions animation mit emitter file
    func getContactBulletVSEnemy(bullet: SKSpriteNode, enemy: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "enemyFire.sks")
        
        explosion?.position = enemy.position
        explosion?.zPosition = 2
        self.addChild(explosion!)
        
        // nach explosion Nodes loeschen
        self.run(SKAction.wait(forDuration: 2)) {
            explosion?.removeFromParent()
        }
        bullet.removeFromParent()
        enemy.removeFromParent()
        
        if enemyHitSound == true {
        self.run(SKAction.playSoundFileNamed("explosion", waitForCompletion: true))
        }
        
        currentScore += 1
        currentScoreLable.text = "Score: \(currentScore)"
                
    }
    
    // Enemy Vs Spaceship Kontakt
    func getContactSpaceshipVsEnemy(enemy: SKSpriteNode, spaceship: SKSpriteNode) {
        
        let explosion = SKEmitterNode(fileNamed: "enemyFire.sks")
               
        explosion?.position = enemy.position
        explosion?.zPosition = 2
        self.addChild(explosion!)
               
        // nach explosion Nodes loeschen
        self.run(SKAction.wait(forDuration: 2)) {
            explosion?.removeFromParent()
        }
        enemy.removeFromParent()
        
               
        if enemyHitSound == true {
            self.run(SKAction.playSoundFileNamed("explosion", waitForCompletion: true))
        }
        // Wenn das Spaceship getroffen wird, soll es faden und wieder sichtbar werden 10 x wieder holen
        spaceship.run(SKAction.repeat(SKAction.sequence([SKAction.fadeAlpha(to: 0.1, duration: 0.1), SKAction.fadeAlpha(to: 1.0, duration: 0.1)]), count: 10))
        

    }
    
    
    // enemy kann nur einmal explodieren
    var contactBegin: Bool = true
    
    // Wenn Kontakt zwischen Ship und elemys besteht
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
       
        
        switch contactMask {
        case physicsBodyNumbers.bulletNumber | physicsBodyNumbers.enemyNumber:
            // Pruefen ob ein node vorhanden ist
            guard let node1 = contact.bodyA.node else {
                       print("Couldn't find a node")
                       return
            }
            guard let node2 = contact.bodyB.node else {
                       print("Couldn't find a node")
                       return
            }
            // kontakt bullet vs enemy
            if contactBegin {
            getContactBulletVSEnemy(bullet: node1 as! SKSpriteNode, enemy: node2 as! SKSpriteNode)
                contactBegin =  false
            }
            
        case physicsBodyNumbers.spaceshipNumber | physicsBodyNumbers.enemyNumber:
            // Pruefund ob bodyA und bodyB nil ist
            guard let node1 = contact.bodyA.node else {
                       print("Couldn't find a node")
                       return
            }
            guard let node2 = contact.bodyB.node else {
                       print("Couldn't find a node")
                       return
            }
            // spaceship vs enemy
          getContactSpaceshipVsEnemy(enemy: node1 as! SKSpriteNode, spaceship: node2 as! SKSpriteNode)
            
            
        default:
        break
            }
        }
    
    // wenn der Kontakt yuende ist soll contact wieder true sein
    func didEnd(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "bullet" || contact.bodyB.node?.name == "bullet"{
            contactBegin = true
        }
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // touch position vom user ermittlen
        for touch in touches {
            
            let locationUser = touch.location(in: self)
            spaceShip.position.x = locationUser.x
            spaceShip.position.y = locationUser.y
            
        }
    }
    
    let bulletSound = SKAction.playSoundFileNamed("beam", waitForCompletion: true)
    var soundBulletOnOff: Bool = true

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let locationUser = touch.location(in: self)
            
            // nur wenn der user aufs spaceship drueckt schiessen
            if atPoint(locationUser) == spaceShip{
                addBulletToSpaceship()
                
                if soundBulletOnOff == true {
                self.run(bulletSound, withKey: "bulletSound")
                }
            }
            
            if atPoint(locationUser) == soundOff {
                audioPlayer.pause()
                self.removeAction(forKey: "bulletsound")
                soundBulletOnOff = false
                enemyHitSound = false
            }
            
            if atPoint(locationUser) ==  soundOn {
                audioPlayer.play()
                soundBulletOnOff = true
                enemyHitSound = true
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Vor jedem Frame abgerufen
        backgroundScene1.position.y -= 5
        backgroundScene2.position.y -= 5
        
        // wenn der Background kleiner als seine eigene hoehe ist wird er auf die Aktuelle Position des andern Background plus seine eigene hoehe gesetzt, ein loop
        if backgroundScene1.position.y < -backgroundScene1.size.height {
            backgroundScene1.position.y = backgroundScene2.position.y + backgroundScene2.size.height
        }
        
        if backgroundScene2.position.y < -backgroundScene2.size.height {
            backgroundScene2.position.y = backgroundScene1.position.y + backgroundScene1.size.height
        }
        // Jeden frame soll geoprueft werden, ob sich der Highscore veraendert hat
        if currentScore > UserDefaults.standard.integer(forKey: "HIGHSCORE"){
            saveHighScore()
        }
    }
}
