//
//  gameOverScene.swift
//  NIP
//
//  Created by admin on 5/22/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//



import SpriteKit



class gameOverScene: SKScene, SKPhysicsContactDelegate {
    
   
    let myLabel = SKLabelNode(fontNamed:"Chalkduster")
    var restartButton = SKSpriteNode(imageNamed: "restartBTN")
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor.grayColor()
        myLabel.text = "Game Over"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2 )
        
        self.addChild(myLabel)
        
        restartButton.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2 - self.frame.height / 2.5)
        restartButton.name = "restartButton"
        addChild(restartButton)
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches 
        let location = touch.first!.locationInNode(self)
        let node = self.nodeAtPoint(location)
        
        if (node.name == "restartButton") {
            _ = SKTransition.flipHorizontalWithDuration(0.5)
            let scene = GameScene(size: (view?.bounds.size)!)
            self.view?.presentScene(scene)
        }
    }
    

}
