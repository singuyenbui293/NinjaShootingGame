//
//  GameScene.swift
//  NIP
//
//  Created by admin on 5/5/16.
//  Copyright (c) 2016 NguyenBui. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let badMonster   : UInt32 = 0b1 // 1
    static let goodMonster : UInt32 = 0b10
    static let Projectile: UInt32 = 0b100      // 2
    static let wall : UInt32 = 0b1000
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "player")
    var score  = 0
    var HP = 5
    let myLabel = SKLabelNode(fontNamed:"Chalkduster")
    let wall = SKSpriteNode()
    var HPLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor.grayColor()
        player.position = CGPoint(x: self.frame.width * 0.5 , y: self.frame.height * 0.1)
        addChild(player)
       
       
        myLabel.text = "\(score)"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2 + self.frame.height / 2.5)
        
        self.addChild(myLabel)
        
        HPLabel.text = "\(HP)"
        HPLabel.fontSize = 45
        HPLabel.position = CGPoint(x: self.frame.width / 2 - self.frame.width / 2.5, y: self.frame.height / 2 + self.frame.height / 2.5)
        self.addChild(HPLabel)
        
        
        wall.size = CGSize(width: 0, height: self.frame.height)
        wall.color = SKColor.redColor()
        wall.position = CGPoint(x: 5 , y: self.frame.height / 2 )
        
        wall.physicsBody = SKPhysicsBody(rectangleOfSize: wall.size)
        wall.physicsBody?.dynamic = true
        wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        wall.physicsBody?.contactTestBitMask = PhysicsCategory.badMonster
        wall.physicsBody?.collisionBitMask = PhysicsCategory.None
        self.addChild(wall)
        

        
        
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        
        
        //MARK: Monster Configure ***************************************************************************************
        
        
        func addMonster() {
            // Create sprite
            let badmonster = SKSpriteNode(imageNamed: "BadMonster")
            // Determine where to spawn the monster along the Y axis
            badmonster.physicsBody = SKPhysicsBody(rectangleOfSize: badmonster.size) // 1
            badmonster.physicsBody?.dynamic = true // 2
            badmonster.physicsBody?.categoryBitMask = PhysicsCategory.badMonster // 3
            badmonster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
            badmonster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
            
            
            let actualY = random(min: badmonster.size.height * 2, max: size.height - badmonster.size.height * 2)
            // Position the monster slightly off-screen along the right edge,
            // and along a random position along the Y axis as calculated above
            badmonster.position = CGPoint(x: size.width + badmonster.size.width/2, y: actualY)
            // Add the monster to the scene
            addChild(badmonster)
            // Determine speed of the monster
            let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
            let actualDurationForGoodMonster = random(min: CGFloat(2.0), max: CGFloat(4.0))
            // Create the actions
            let actionMove = SKAction.moveTo(CGPoint(x: -badmonster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
            let actionMoveDone = SKAction.removeFromParent()
            badmonster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
        
        func addGoodMonster() {
            let goodmonster = SKSpriteNode(imageNamed: "GoodMonster")
            
            goodmonster.physicsBody = SKPhysicsBody(rectangleOfSize: goodmonster.size) // 1
            goodmonster.physicsBody?.dynamic = true // 2
            goodmonster.physicsBody?.categoryBitMask = PhysicsCategory.goodMonster // 3
            goodmonster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
            goodmonster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5

            
            let goodactualY = random(min: goodmonster.size.height * 2, max: size.height - goodmonster.size.height * 2)
            goodmonster.position = CGPoint(x: size.width + goodmonster.size.width/2, y: goodactualY)
            addChild(goodmonster)
            let actualDurationForGoodMonster = random(min: CGFloat(2.0), max: CGFloat(4.0))
            
            let GoodactionMove = SKAction.moveTo(CGPoint(x: -goodmonster.size.width/2, y: goodactualY), duration: NSTimeInterval(actualDurationForGoodMonster))
            let actionMoveDone = SKAction.removeFromParent()
            goodmonster.runAction(SKAction.sequence([GoodactionMove, actionMoveDone]))
            
        }

        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.0)
                ])
            ))
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addGoodMonster),
                SKAction.waitForDuration(1.0)
                ])
            ))
        
        
        
        
        //MARK: *************************************************************************************************************
        
        
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.goodMonster
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.badMonster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.y < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
        HP -= 1
        self.HPLabel.text = "\(HP)"
        
        
        if HP == 0 {
        
            _ = SKTransition.flipHorizontalWithDuration(0.5)
            let scene = gameOverScene(size: (view?.bounds.size)!)
            self.view?.presentScene(scene)
            
        }
        

    
    }
    
    func badmonsterMiss (monster: SKSpriteNode, wall : SKSpriteNode) {
        print("miss")
        monster.removeFromParent()
       
       
        HP -= 1
        HPLabel.text = "\(HP)"
        if HP == 0 {
            _ = SKTransition.flipHorizontalWithDuration(0.5)
            let scene = gameOverScene(size: (view?.bounds.size)!)
            self.view?.presentScene(scene)
        }
    }
    
    func projectileCollideWitbadMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("Ohh NO")
        projectile.removeFromParent()
        monster.removeFromParent()
        score += 1
        print(score)
        myLabel.text = "\(score)"
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.goodMonster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            
            if let firstBody = firstBody.node , let secondBody = secondBody.node  {
                projectileDidCollideWithMonster(firstBody as! SKSpriteNode, monster: secondBody as! SKSpriteNode)
            } else {
                
            }
            
        }
        
        
        if ((firstBody.categoryBitMask & PhysicsCategory.badMonster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            
            if let firstBody = firstBody.node , let secondBody = secondBody.node  {
                projectileCollideWitbadMonster(firstBody as! SKSpriteNode, monster: secondBody as! SKSpriteNode)
            } else {
                
            }
            
        }
        
        
        if ((firstBody.categoryBitMask & PhysicsCategory.badMonster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.wall != 0)) {
            
            if let firstBody = firstBody.node , let secondBody = secondBody.node  {
                badmonsterMiss(firstBody as! SKSpriteNode, wall: secondBody as! SKSpriteNode)
            } else {
                
            }
            
        }

    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}


func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}



func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

