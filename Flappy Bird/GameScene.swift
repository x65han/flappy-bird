//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Johnson Han on 2017-06-29.
//  Copyright © 2017 Johnson Han. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?

    var bird = SKSpriteNode()
    var ground = SKNode()
    var background = SKSpriteNode()
    var gameOver = false
    var gameStart = false
    var timer = Timer()
    var gameOverLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var score = 0

    enum ColliderType: UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }

    func makePipes() {
        print("making pipes")
        // obstacles animation
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        // obstacles
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.height) / 2
        let pipeOffset = CGFloat(movementAmount) - self.frame.height / 4
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: self.frame.width, y: self.frame.midY + pipeTexture.size().height / 2 + gapHeight / 2 + pipeOffset)
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipe1.physicsBody!.isDynamic = false;
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        pipe1.run(movePipes)
        self.addChild(pipe1)
        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        let pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: self.frame.width, y: self.frame.midY - pipe2Texture.size().height / 2 - gapHeight / 2 + pipeOffset)
        pipe2.run(movePipes)
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipe2.physicsBody!.isDynamic = false;
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        self.addChild(pipe2)
        
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture.size().width, height: gapHeight))
        gap.physicsBody!.isDynamic = false
        gap.run(movePipes)
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        self.addChild(gap)
    }

    func didBegin(_ contact: SKPhysicsContact) {
//        contact.bodyB.contactTestBitMask = ColliderType.Bird.rawValue
//        contact.bodyB.categoryBitMask = ColliderType.Object.rawValue
//        contact.bodyB.collisionBitMask = ColliderType.Bird.rawValue
//        contact.bodyB.applyImpulse(CGVector(dx: 2, dy: 50))
//        ground.physicsBody = nil
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            score += 1
            scoreLabel.text = String(score)
        } else {
            self.speed = 0
            gameOver = true
            print("Game Over")
            timer.invalidate()
            gameOverLabel.text = "Game over! Tap to play again"
        }
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        setup()
    }
    
    func setup() {
        // load background image & move background
        let backgroundTexture = SKTexture(imageNamed: "background.png")
        // set background animation
        let moveBackgroundAnimation = SKAction.move(by: CGVector(dx: -backgroundTexture.size().width, dy: 0), duration: 7)
        let shiftBackground = SKAction.move(by: CGVector(dx: backgroundTexture.size().width, dy: 0), duration: 0)
        let moveBackgroundForever = SKAction.repeatForever(SKAction.sequence([moveBackgroundAnimation, shiftBackground]))
        for i in 0...2 {
            background = SKSpriteNode(texture: backgroundTexture)
            background.position = CGPoint(x: backgroundTexture.size().width * CGFloat(i), y: self.frame.midY)
            background.size.height = self.frame.height
            background.run(moveBackgroundForever)
            background.zPosition = -1
            self.addChild(background)
        }
        // load bird image
        let birdTexture1 = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        // bird animation
        let animation = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        bird = SKSpriteNode(texture: birdTexture1)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.run(makeBirdFlap)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture1.size().height / 2)
        bird.physicsBody!.isDynamic = false
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        // The contactTestBitMask property is a number defining which collisions we want to be notified about.
        // The categoryBitMask property is a number defining the type of object this is for considering collisions.
        // The collisionBitMask property is a number defining what categories of object this node should collide with,
        bird.zPosition = 1;
        self.addChild(bird)
        // ground
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic = false;
        ground.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        self.addChild(ground)
        
        self.speed = 1
        gameOver = false
        gameStart = false
        
        gameOverLabel.fontName = "Helvetica"
        gameOverLabel.fontSize = 30
        gameOverLabel.text = "Tap anywhere to begin"
        gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 70)
        self.addChild(gameOverLabel)
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        score = 0
        scoreLabel.text = String(score)
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        self.addChild(scoreLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStart == false {
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
            timer.fire()
            gameStart = true
            gameOverLabel.text = ""
        }
        if gameOver == false {
            bird.physicsBody!.isDynamic = true
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
        } else {
            self.removeAllChildren()
            setup()
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

    }
}
