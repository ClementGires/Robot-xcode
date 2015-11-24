//
//  GameScene.swift
//  Robot Test
//
//  Created by Clement Gires on 4/28/15.
//  Copyright (c) 2015 test. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
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

class GameScene: SKScene {
    
    var level: Level!
    var savings: Savings!
    var intervalX: CGFloat!
    var intervalY: CGFloat!
    
    var collisionCounter=0
    var maxCollisionCounter=5 //Don't compute collisions at every frame. Performance.
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        //let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        //myLabel.text = "Hello, World!";
        //myLabel.fontSize = 65;
        //myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        //self.addChild(myLabel)
        println("moved to view")
        /*if let data = NSUserDefaults.standardUserDefaults().objectForKey("savings") as? NSData {
            self.savings = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Savings
        }
        else {*/
            //First time that the app is loaded. Start at Level 0
            self.savings = Savings(bestLevel:0)
            saveUserData()
        //}
        
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        //physicsWorld.contactDelegate = self
        
        self.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        //self.backgroundColor = SKColor.yellowColor()
        
        
        self.level = Level(scene: self, tileSize: 30, difficultyLevel: 1)
        self.level.gameScene=self
        //self.level.addARobot(level.tileArray[5][5][0], speed: 0, type: 3)
        //self.level.addARobot(level.tileArray[7][5][0], speed: 0, type: 3)
        //self.level.addAPlayer(level.tileArray[0][0][0], speed: 3,type:0)
        //self.level.addAPlayer(level.tileArray[0][0][0], speed: 1.5,type:0)
        //self.level.playerArray[1].computerControlled=true
        
        //self.level.addARobot(level.tileArray[0][2][0], speed:0.3, type:1) //adding an ennemy for testing purposes
        //self.level.addARobot(level.tileArray[2][0][0], speed:0.3, type:1)
        //self.level.addARobot(level.tileArray[2][2][0], speed:0.3, type:1)
        
        
        //self.level.addARobot(level.tileArray[level.tileWidth-1][level.tileHeight-1][0], speed: 0, type: 2) //flag
        
        //self.level.addARobot(level.tileArray[4][4][0], speed: 0, type: 7)//pacman mode
        
        //self.level.addARobot(level.tileArray[4][4][0], speed: 0, type: 9)//u-turn collection
        
        //self.level.addARobot(level.tileArray[7][7][0], speed:0, type:5) //pathway up
        //self.level.tileArray[7][7][1].eliminateEnnemiesFromCorridor() //make sure you don't fall on an ennemy
        
        //self.level.addARobot(level.tileArray[0][7][1], speed:0, type:4) //pathway down
        //self.level.tileArray[0][7][0].eliminateEnnemiesFromCorridor() //make sure you don't fall on an ennemy

        //self.level.addARobot(level.tileArray[3][5][0], speed:0, type:6)
        
        
        intervalX=CGFloat((Int(self.frame.width) % level.tileSize)/2)
        intervalY=CGFloat((Int(self.frame.height) % level.tileSize)/2)

        //level.createRandomArray()

        
    }
    /*
    func didBeginContact(contact: SKPhysicsContact) {
        var secondBody=contact.bodyB
        if (contact.bodyA.categoryBitMask>contact.bodyB.categoryBitMask) {
            secondBody=contact.bodyA
        }
        
        if (secondBody.categoryBitMask==Robot.PhysicsCategory.Ennemy) {
            level.restartLevel()
        }
        else if (secondBody.categoryBitMask==Robot.PhysicsCategory.Flag) {
            level.nextLevelDifficulty()
        }
    }
*/
    
    func updateSavings(best: Int) {
        self.savings.bestLevel = best
        saveUserData()
    }
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func saveUserData() {
        //Use everytime that the best level is updated
        let data = NSKeyedArchiver.archivedDataWithRootObject(self.savings)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "savings")
    }
    
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            self.level.playerArray[0].startAJump()

        }
    }
    
    func updateCamera() {
        var position=self.level.playerArray[0].sprite.position
        
        //the code below could be heavily optimized. Only calculated once per loop
        var timesToRight=Int(position.x)/(level.tileSize*level.numberOfHorizontalTilesPerScreen)
        var cameraX=intervalX*CGFloat(1+2*timesToRight)-self.frame.width*CGFloat(timesToRight)
        
        var timesDown=Int(position.y)/(level.tileSize*level.numberOfVerticalTilesPerScreen)
        var cameraY=intervalY*CGFloat(1+2*timesDown)-self.frame.height*CGFloat(timesDown)
        
        level.node.position = CGPoint(x:cameraX,y:cameraY)
    }
    
    func checkCollisions() {
        collisionCounter++
        //Need to test collisions
        if (collisionCounter==maxCollisionCounter) {
            var robot:Robot
            collisionCounter=0
            for player in level.playerArray {
                var index=0
                //while (index <level.robotArray.count-1) {
                
                
                for index in 0...level.robotArray.count-1 {
                    robot=level.robotArray[index]
                    if (player.weakCollision(robot) && player.strongCollision(robot)) {
                        //there is a collision
                        player.collide(robot, atIndex:index)
                        return //just test one collision per turn. Help avoid a bug if the level.robotArray changes in the middle of the for loop
                    }
                }
            }
        }

    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        //Need to change the camera here

        self.updateCamera()
        
        //very first stab at some AI for robots
        if (Float(arc4random_uniform(1000))/1000<0.001) {
            //level.robotArray[1].startAJump()
        }
        
        //next check the collisions
        self.checkCollisions()
        
        
        //test
        for player in self.level.playerArray {
            for items in player.backPack {
                //items.sprite.position=CGPoint(x: 10, y: 10)
            }
        }
        
        
        
    }
}
