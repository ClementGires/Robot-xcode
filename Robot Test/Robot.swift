//
//  Robot.swift
//  Robot Test
//
//  Created by Clement Gires on 4/29/15.
//  Copyright (c) 2015 test. All rights reserved.
//

import Foundation
import SpriteKit



class Robot {
    var sprite: SKSpriteNode!
    //var sprite: SKShapeNode!
    var level: Level!
    var speed: Float
    var nextTile: Tile! //One step away
    var direction=0 //0=right, 1=up, 2=left, 3=down
    var currentlyJumping=false
    var jumpingScale: CGFloat=1.3
    var invincible=false
    var invicibleTimer=10
    var computerControlled=false
    var type: Int //0 is a player, 1 is an ennemy, 2 is a flag, 3 is a bomb, 4 is a hole, 5 is a ladder, 6 is invicibility, 7 is pacman mode, 8 is u-turn, 9 is turtleBomb
    var backPack=[Robot]() //Players can collect items
    var distanceToNextTile:CGFloat=0 //distance between the robot and next tile (how far from the next decision point)
    var virtualRobot:Bool=false
    var verticalMovement=0 //used to go down or up
    var canJump=true //used to prevent two jumps in a row
    
    var forPickup=false
    
    var modeDuration=0 //How long a given mode will last
    
    var pacmanMode=false
    let robotRadius:CGFloat=8
    
    var canReallyJumpInARow=false
    
    let maxBombRadius:CGFloat=200
    
    /*
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Player   : UInt32 = 0b1       // 0
        static let Ennemy: UInt32 = 0b10      // 1
        static let Flag: UInt32 = 0b11      // 2
        static let Bomb: UInt32 = 0b100      // 3
    }
*/

    

    init(level:Level,tile:Tile,speed:Float,type:Int) {
        //self.level=level
        //self.sprite = SKSpriteNode(imageNamed: "monster")
        self.level=level
        //self.sprite = SKShapeNode(circleOfRadius: robotRadius)
        
        //var spriteTest = SKSpriteNode(imageNamed: "projectile")
        //spriteTest.position=CGPoint(x: 30, y: 0)
        //self.sprite.addChild(spriteTest)
        //self.sprite.fillColor=SKColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)
        //self.sprite.strokeColor=SKColor.clearColor()
        /*
        if (type==1) {
            self.sprite.fillColor=SKColor.blueColor()
        }
        else if (type==2) {
            self.sprite.fillColor=SKColor.blackColor()
        }
        else if (type==3) {
            self.sprite.fillColor=SKColor.yellowColor()
        }
*/
        var s=self.level.tileSize
        self.speed = speed
        self.nextTile=tile
        self.type=type
        self.sprite = SKSpriteNode(imageNamed: "firstPlayer")
        self.sprite = spriteForType(type)
        self.sprite.zPosition=1
        self.sprite.position=CGPoint(x:s*tile.i+s/2,y:s*tile.j+s/2)
        //self.distanceToNextTile=CGFloat(self.level.tileSize)
        self.updateFloor()
        if (self.type==6) {
            self.modeDuration=15
            self.forPickup=true
        }
        else if (self.type==7) {
            self.modeDuration=25
            self.forPickup=true
        }
        
        if (self.type==3 || self.type==8 || self.type==9) {
            self.forPickup=true
        }

        //self.level.node.addChild(self.sprite)
        /*
        //now set-up collision detection
        self.sprite.physicsBody = SKPhysicsBody(circleOfRadius: robotRadius) // 1
        self.sprite.physicsBody?.dynamic = true // 2
        if (type==0) {
            self.sprite.physicsBody?.categoryBitMask = PhysicsCategory.Player // 3
            self.sprite.physicsBody?.contactTestBitMask = PhysicsCategory.Ennemy | PhysicsCategory.Flag
        }
        else if (type==1){
            self.sprite.physicsBody?.categoryBitMask = PhysicsCategory.Ennemy // 3
            self.sprite.physicsBody?.contactTestBitMask = PhysicsCategory.None

        }
        else if (type==2) {
            self.sprite.physicsBody?.categoryBitMask = PhysicsCategory.Flag // 3
            self.sprite.physicsBody?.contactTestBitMask = PhysicsCategory.None
        }
        else if (type==3) {
            self.sprite.physicsBody?.categoryBitMask = PhysicsCategory.Bomb // 3
            self.sprite.physicsBody?.contactTestBitMask = PhysicsCategory.None
        }
         // 4
        self.sprite.physicsBody?.collisionBitMask = PhysicsCategory.None // doesn't responde to collisions
        */
        
        self.nextMove()
    }
    
    init(robot:Robot) {

        self.level=robot.level
        self.speed = robot.speed
        self.nextTile = robot.nextTile
        self.type = robot.type
        self.direction=robot.direction
        if ((robot.sprite) != nil) {
            let a=robot.nextTile.sprite.position.x-robot.sprite.position.x
            let b=robot.nextTile.sprite.position.y-robot.sprite.position.y
            self.distanceToNextTile=sqrt(a*a+b*b)
        }
        else {
            self.distanceToNextTile=robot.distanceToNextTile
        }
        self.virtualRobot=true
    }
    
    func spriteForType(type:Int) -> SKSpriteNode {
        //need to return the right shape
        if (self.type==0) {
            return SKSpriteNode(imageNamed: "firstPlayer")
        }
        else if (self.type==1) {
            return SKSpriteNode(imageNamed: "ennemy")
        }
        else if (self.type==2) {
            return SKSpriteNode(imageNamed: "flag")
        }
        else if (self.type==3) {
            return SKSpriteNode(imageNamed: "bomb")
        }
        else if (self.type==4) {
            return SKSpriteNode(imageNamed: "ladderDown")
        }
        else if (self.type==5) {
            return SKSpriteNode(imageNamed: "ladderUp")
        }
        else if (self.type==6) {
            return SKSpriteNode(imageNamed: "cape")
        }
        else if (self.type==7) {
            return SKSpriteNode(imageNamed: "pacman")
        }
        else if (self.type==8) {
            return SKSpriteNode(imageNamed: "uturn")
        }
        else if (self.type==9) {
            return SKSpriteNode(imageNamed: "turtle")
        }
        return SKSpriteNode(imageNamed: "firstPlayer")

        
        //return SKShapeNode(circleOfRadius: self.robotRadius)
    }
    
    func endInvicible() {
        self.invincible=false
    }
    
    func initialTrigger(robot:Robot) {
        if (robot.type==1) {
            
        }
    }
    
    func endTrigger(robot:Robot) {
        
    }
    
    
    func pickup(robot:Robot, atIndex:Int) {
        self.level.robotArray.removeAtIndex(atIndex)
        //when a player picks-up a robot and puts it in the backpack
        if (self.backPack.count>0 && (self.backPack[self.backPack.count-1].modeDuration != 0)) {
            //last item was a cape. You loose the cape. Same thing with Pacman.
            self.releaseFirstFromBackpack()
        }
        self.backPack.append(robot)
        //need to remove robot from robotArray
        //self.level.robotArray.removeAtIndex(atIndex)
        
        robot.sprite.removeFromParent()
        robot.sprite.removeAllActions()
        //var sprite = spriteForType(robot.type)

        //robot.sprite=sprite
        self.sprite.addChild(robot.sprite)
        robot.sprite.runAction(SKAction.scaleTo(0.8, duration: NSTimeInterval(1)))
        
        if (robot.type==6) {
            //just picked-up a cape
            self.invincible=true
            var firstAction = SKAction.scaleTo(1, duration: NSTimeInterval(0))
            var secondAction = SKAction.scaleTo(0, duration: NSTimeInterval(robot.modeDuration))
            var actionEnd = SKAction.runBlock(self.releaseFirstFromBackpack)
            robot.sprite.runAction(SKAction.sequence([firstAction,secondAction,actionEnd]))
        }
        
        else if (robot.type==7) {
            //picked-up pacman mode
            self.pacmanMode=true
            var firstAction = SKAction.scaleTo(1, duration: NSTimeInterval(0))
            var secondAction = SKAction.scaleTo(0, duration: NSTimeInterval(robot.modeDuration))
            var actionEnd = SKAction.runBlock(self.releaseFirstFromBackpack)
            robot.sprite.runAction(SKAction.sequence([firstAction,secondAction,actionEnd]))
        }

        //robot.sprite.position=CGPoint(x: 0, y: 20*self.backPack.count)

        robot.sprite.position=CGPoint(x: 0, y:0)

        
        //robot.sprite=sprite

        //self.sprite.addChild(robot.sprite)
        //robot.sprite.position=CGPoint(x: 50, y: -50)
        //robot.sprite.runAction(SKAction.moveTo(CGPoint(x: -100, y: -100), duration: NSTimeInterval(0)))
    }
    
    func weakCollision(robot:Robot) -> Bool {
        if (self.nextTile.z != robot.nextTile.z) {
            return false
        }
        var dx:CGFloat
        var dy:CGFloat
        if (!virtualRobot) {
            dx=abs(robot.sprite.position.x-self.sprite.position.x)
            dy=abs(robot.sprite.position.y-self.sprite.position.y)
        }
        else {
            let (ax,ay)=self.actualPosition()
            let (bx,by)=robot.actualPosition()
            dx=abs(ax-bx)
            dy=abs(ay-by)
            
        }
        var rad=self.robotRadius+robot.robotRadius
        return (dx<rad && dy<rad)
    }
    
    func actualPosition() -> (CGFloat,CGFloat) {
        if (direction==1) {
            return (self.nextTile.sprite.position.x,self.nextTile.sprite.position.y-self.distanceToNextTile)
        }
        else if (direction==2) {
            return (self.nextTile.sprite.position.x+self.distanceToNextTile,self.nextTile.sprite.position.y)
        }
        else if (direction==3) {
            return (self.nextTile.sprite.position.x,self.nextTile.sprite.position.y+self.distanceToNextTile)
        }
        else {
            return (self.nextTile.sprite.position.x-self.distanceToNextTile,self.nextTile.sprite.position.y)

        }
        
    }
    
    func strongCollision(robot:Robot) -> Bool {
        return (self.distanceTo(robot)<self.robotRadius+robot.robotRadius)
    }
    
    func moveByStep(jumping:Bool, step:CGFloat) {
        //Moves the robot by one tiny step. Changes direction if passes beyond a tile
        self.distanceToNextTile-=step*CGFloat(self.speed)
        if (self.distanceToNextTile<=0) {
            self.direction=self.nextDirection(jumping, currentDirection: direction, tile: nextTile)
            self.nextTile=self.nextTileToGoTo(nextTile, currentDirection: self.direction)
            self.distanceToNextTile=CGFloat(level.tileSize)+distanceToNextTile
        }
    }
    
    
    func aINextWithEnnemies(ennemies:[Robot],depth:Int, distance:Int, step:CGFloat) -> (Bool,Int) {
        //recursive function looking for the best path including ennemies. Returns wether you should be jumping or not and the score for the best path.
        if (nextTile.i==level.tileWidth-1 && nextTile.j==level.tileHeight-1 && distanceToNextTile<self.robotRadius*2) {
            //we are at the flag
            return (false,1000/distance)
        }
        
        if (depth==0) {
            //stop iterating to save calculation time
            return (false,nextTile.i+nextTile.j/distance)
        }
        
        for robot in ennemies {
            if (self.weakCollision(robot) && self.strongCollision(robot)) {
                //there is a collision with an ennemy. Return 0 it should not be a good option
                return (false,0)
            }
        }
        
        var canJump=true
        if ((direction==0 && nextTile.rightWall==2) || (direction==1 && nextTile.upWall==2) || (direction==2 && nextTile.leftWall==2) || (direction==3 && nextTile.downWall==2)) {
            //facing a hard wall
            canJump=false
        }
        
        //update all positions
        for robot in ennemies {
            robot.moveByStep(false,step:step)
        }
        
        if (distanceToNextTile>step*CGFloat(self.speed) || !canJump || nextDirection(false, currentDirection: direction, tile: nextTile)==direction) {
            //not turning. Easy
            self.moveByStep(false,step:step)
            let (aa,bb) = self.aINextWithEnnemies(ennemies,depth:depth, distance:distance+1, step:step)
            return (false,bb)
        }
        else {
            //First assume you turn
            //self.distanceToNextTile+=step*CGFloat(self.speed)
            self.moveByStep(false,step:step)
            let (a,b) = self.aINextWithEnnemies(ennemies, depth: depth-1, distance: distance+1, step: step)
            
            //Then assume you jump. Create a different set of ennemies
            var newEnnemies = [Robot]()
            for robot in ennemies {
                newEnnemies.append(Robot(robot:robot))
            }
            var newPlayer=Robot(robot:self)
            newPlayer.moveByStep(true, step: step)
            let (c,d) = newPlayer.aINextWithEnnemies(newEnnemies, depth: depth-1, distance: distance+1, step: step)
            
            
            if (b>d) {
                //shouldn't jump
                return (false,b)
            }
            else {
                //should jump
                return (true,d)
            }
            
        }
    }
    
    
    
    
    func restartLevel() {
        self.resetPosition(self.level.tileArray[0][0][0])
        //empty the backpack
        
        for item in self.backPack {
            item.sprite.removeFromParent()
        }
        self.backPack=[Robot]()
        self.invincible=false
        
        //update all floors
        self.level.currentFloor=0
        self.level.updateFloor()
        
    }
    
    func collide(robot:Robot,atIndex:Int) {
        if (self.type==0 && robot.type==1 && !self.invincible) {
            //collision with ennemy
            if (self.pacmanMode) {
               level.robotArray.removeAtIndex(atIndex)
                robot.sprite.removeAllActions()
                robot.sprite.removeFromParent()
            }
            else {
               self.restartLevel()
            }
        }
        else if (self.type==0 && robot.type==2) {
            //collision with Flag
            self.level.nextLevelDifficulty()
        }
        else if (self.type==0 && robot.forPickup) {
            //pick-up the item
            self.pickup(robot, atIndex:atIndex)

        }
        else if (self.type==0 && robot.type==4 && self.level.currentFloor>0) {
            //collision with a hole. Going down
            var firstAction = SKAction.scaleTo(0.6, duration: NSTimeInterval(0.3/self.speed))
            var secondAction = SKAction.scaleTo(1, duration: NSTimeInterval(0))
            var thirdAction = SKAction.runBlock(self.level.updateFloor)
            self.level.currentFloor--
            self.nextTile=level.tileArray[self.nextTile.i][self.nextTile.j][self.nextTile.z-1]
            self.sprite.runAction(SKAction.sequence([firstAction,secondAction,thirdAction]))

            
        }
        else if (self.type==0 && robot.type==5 && self.level.currentFloor<self.level.numberOfFloors-1) {
            //collision with a ladder. Going up.
            var firstAction = SKAction.scaleTo(1.4, duration: NSTimeInterval(0.3/self.speed))
            var secondAction = SKAction.scaleTo(1, duration: NSTimeInterval(0))
            var thirdAction = SKAction.runBlock(self.level.updateFloor)
            self.level.currentFloor++
            self.nextTile=level.tileArray[self.nextTile.i][self.nextTile.j][self.nextTile.z+1]
            self.sprite.runAction(SKAction.sequence([firstAction,secondAction,thirdAction]))
            
        }
    }
    
    func updateFloor() {
        self.sprite.removeFromParent()
        if (self.nextTile.z == self.level.currentFloor) {
            self.level.node.addChild(self.sprite)
        }
    }
    
    func distanceTo(robot:Robot) -> CGFloat {
        var dx:CGFloat
        var dy:CGFloat
        
        if (!self.virtualRobot) {
            dx=robot.sprite.position.x-self.sprite.position.x
            dy=robot.sprite.position.y-self.sprite.position.y
        }
        else {
            let (ax,ay)=self.actualPosition()
            let (bx,by)=robot.actualPosition()
            dx=ax-bx
            dy=ay-by
            
        }
        return sqrt(dx*dx+dy*dy)
        
    }
    
    func explode() {
        println("explode")
        
        let firstAction = SKAction.scaleTo(maxBombRadius/self.robotRadius, duration: NSTimeInterval(0.1))
        let secondAction = SKAction.scaleTo(1, duration: NSTimeInterval(0.1))
        self.sprite.runAction(SKAction.sequence([firstAction,secondAction]))
        
        var d:CGFloat
        var robot:Robot
        var i=0
        while (i<level.robotArray.count) {
            robot=level.robotArray[i]
            d=self.distanceTo(robot)
            if (d>0 && d<self.maxBombRadius && robot.type==1 && self.nextTile.z==robot.nextTile.z) {
                //robot needs to go
                level.robotArray.removeAtIndex(i)
                i--
                robot.sprite.removeFromParent()
                robot.sprite.removeAllActions()
                //println("ennemy destroyed")
            }
            i++
        }
        for player in level.playerArray {
            var d=self.distanceTo(player)
            if (d>0 && d<self.maxBombRadius) {
                player.restartLevel()
            }
        }
    }
    
    func distanceFromTile(tile:Tile)->CGFloat {
        let dx=tile.sprite.position.x-self.sprite.position.x
        let dy=tile.sprite.position.y-self.sprite.position.y
        return CGFloat(sqrt(dx*dx+dy*dy))
    }
    
    func uturn() {
        //make your robot do a u-turn
        var i=nextTile.i
        var j=nextTile.j
        var z=nextTile.z
        var distanceToNext=CGFloat(level.tileSize)-self.distanceFromTile(nextTile)
        if (direction == 0) {
            direction=2
            nextTile=level.tileArray[i-1][j][z]
        }
        else if (direction == 1) {
            direction=3
            nextTile=level.tileArray[i][j-1][z]
        }
        else if (direction == 2) {
            direction=0
            nextTile=level.tileArray[i+1][j][z]
        }
        else if (direction == 3) {
            direction=1
            nextTile=level.tileArray[i][j+1][z]
        }
        self.currentlyJumping=false
        self.canJump=true
        self.sprite.removeAllActions()
        let actionMove = SKAction.moveTo(nextTile.sprite.position, duration: NSTimeInterval(Float(distanceToNext)/(self.speed*Float(level.tileSize))))
        //distanceToNextTile=1
        let actionEnd = SKAction.runBlock(self.nextMove)
        self.sprite.runAction(SKAction.sequence([actionMove,actionEnd]))
        
    }
    
    func changeSpeed(newSpeed:Float) {
        self.distanceFromTile(self.nextTile)
        self.speed=newSpeed
    }
    
    func speedUp() {
        self.speed=self.speed*1.2
        println(speed)
    }
    
    func turtleBomb() {
        for player in level.playerArray {
            if (player.sprite.position.x != self.sprite.position.x && player.sprite.position.y != self.sprite.position.y) {
                //not self
                player.speed=player.speed/(1.2*1.2*1.2*1.2*1.2)
                let firstAction = SKAction.waitForDuration(3)
                let action = SKAction.runBlock(player.speedUp)
                let repeatedAction = SKAction.repeatAction(SKAction.sequence([firstAction,action]), count: 5)
                player.sprite.runAction(repeatedAction)
            }
        }
        for robot in level.robotArray {
            println(robot.speed)
            robot.speed=robot.speed/(1.2*1.2*1.2*1.2*1.2)
            let firstAction = SKAction.waitForDuration(3)
            let action = SKAction.runBlock(robot.speedUp)
            let repeatedAction = SKAction.repeatAction(SKAction.sequence([firstAction,action]), count: 5)
            robot.sprite.runAction(repeatedAction)
        }
    }
    
    func releaseFirstFromBackpack() {
        //drop last item added to the backback
        if (self.backPack.count>0) {
            var robotToRelease=self.backPack.removeLast()
            robotToRelease.sprite.removeAllActions()
            robotToRelease.sprite.removeFromParent()
            if (robotToRelease.type==3) {
                //make the bomb explode
                self.explode()
            }
            if (robotToRelease.type==9) {
                //turtleBomb
                self.turtleBomb()
            }
            else if (robotToRelease.type==8) {
                self.uturn()
            }
            else if (robotToRelease.type==6) {
                //loose the invicibility cape
                self.invincible=false
            }
            else if (robotToRelease.type==7) {
                //loose the invicibility cape
                self.pacmanMode=false
            }
        }
    }
    
    func resetPosition(tile:Tile) {
        //cancel all actions
        self.sprite.removeAllActions()
        var s=self.level.tileSize
        self.sprite.position=CGPoint(x:s*tile.i+s/2,y:s*tile.j+s/2)
        self.sprite.runAction(SKAction.moveTo(tile.sprite.position, duration: NSTimeInterval(0)))
        //self.sprite.position=CGPoint(x:s/2,y:s/2)
        //self.sprite.position=CGPointMake(100, 100)
        self.direction=0
        self.currentlyJumping=false
        self.canJump=true
        self.nextTile=tile
        
        self.nextMove()
    }
    
    func nextDirection(jumping:Bool, currentDirection: Int, tile:Tile) -> Int {
        if (currentDirection == 0) {
            //going to the right
            if (jumping && tile.rightWall != 2) {
                return 0
            }
            else {
                if (tile.downWall == 0) {
                    return 3
                }
                else if (tile.rightWall == 0) {
                    return 0
                }
                else if (tile.upWall == 0) {
                    return 1
                }
                else {
                    return 2
                }
            }
        }
            
        else if (currentDirection == 1) {
            //going up
            if (jumping && tile.upWall != 2) {
                return 1
            }
            else {
                if (tile.rightWall == 0) {
                    return 0
                }
                else if (tile.upWall == 0) {
                    return 1
                }
                else if (tile.leftWall == 0) {
                    return 2
                }
                else {
                    return 3
                }
            }
        }
        else if (currentDirection == 2) {
            //going left
            if (jumping && tile.leftWall != 2) {
                return 2
            }
            else {
                if (tile.upWall == 0) {
                    return 1
                }
                else if (tile.leftWall == 0) {
                    return 2
                }
                else if (tile.downWall == 0) {
                    return 3
                }
                else {
                    return 0
                }
            }
        }
        else if (currentDirection == 3) {
            //going down
            if (jumping && tile.downWall != 2) {
                return 3
            }
            else {
                if (tile.leftWall == 0) {
                    return 2
                }
                else if (tile.downWall == 0) {
                    return 3
                }
                else if (tile.rightWall == 0) {
                    return 0
                }
                else {
                    return 1
                }
            }
        }
        return currentDirection
    }
    
    func nextTileToGoTo(tile:Tile,currentDirection:Int) -> Tile {
        var i=tile.i
        var j=tile.j
        var z=tile.z
        
        if (currentDirection==0) {
            return level.tileArray[i+1][j][z]
        }
        else if (currentDirection==1) {
            return level.tileArray[i][j+1][z]
        }
        else if (currentDirection==2) {
            return level.tileArray[i-1][j][z]
        }
        else if (currentDirection==3) {
            return level.tileArray[i][j-1][z]
        }
        return level.tileArray[i+1][j][z]
    }
    
    func previousTile() -> Tile {
        var i=nextTile.i
        var j=nextTile.j
        var z=nextTile.z
        if (direction==1) {
            return level.tileArray[i][j-1][z]
        }
        else if (direction==2) {
            return level.tileArray[i+1][j][z]
        }
        else if (direction==3) {
            return level.tileArray[i][j+1][z]
        }
        return level.tileArray[i-1][j][z]
    }
    
    func aINext(currentTile:Tile,currentDirection:Int,depth:Int, distance:Int, justJumped:Bool, canJumpInaRow:Bool) -> (Bool,Float) {
        //recursive function looking for the best path. Returns wether you should be jumping or not and the score for the best path.

        //println(distance)
        
        if (depth==0) {
            //stop iterating to save calculation time
            //return (false,Float(currentTile.i+currentTile.j)/Float(distance))
            return (false,Float(currentTile.i+currentTile.j-distance/10))
        }
        
        if (distance<level.futureEnnemyPositions.count) {
            for ennemy in level.futureEnnemyPositions[distance] {
                /*
                if (self.weakCollision(robot) && self.strongCollision(robot)) {
                    //there is a collision with an ennemy. Return 0 it should not be a good option
                    return (false,0)
                }*/
                if (ennemy.nextTile.equalTo(currentTile) || ennemy.previousTile().equalTo(currentTile)) {
                   return (false,0)
                }
            }
        }
        
        if (currentTile.i==level.tileWidth-1 && currentTile.j==level.tileHeight-1) {
            //we are at the flag
            return (false,1000/Float(distance))
        }
        

        var newDirection=nextDirection(false,currentDirection:currentDirection,tile:currentTile)
        var canJump=true;
        if ((currentDirection==0 && currentTile.rightWall==2) || (currentDirection==1 && currentTile.upWall==2) || (currentDirection==2 && currentTile.leftWall==2) || (currentDirection==3 && currentTile.downWall==2) || (justJumped && !canJumpInaRow)) {
            //facing a hard wall
            canJump=false
        }
        
        
        if ((newDirection == currentDirection) || !canJump) {
            //No choice to make. No jump
            let (aa,bb)=aINext(nextTileToGoTo(currentTile, currentDirection: newDirection), currentDirection: newDirection, depth: depth, distance:distance+1,justJumped:false,canJumpInaRow:canJumpInaRow)//don't increase depth because it doesn't get the tree bigger. Single branch.
            return (false,bb)
        }
        else {
            let (a,b)=aINext(nextTileToGoTo(currentTile, currentDirection: newDirection), currentDirection: newDirection, depth: depth-1, distance:distance+1, justJumped:false,canJumpInaRow:canJumpInaRow)//not jumping
            var (c,d)=aINext(nextTileToGoTo(currentTile, currentDirection: currentDirection), currentDirection: currentDirection, depth: depth-1, distance:distance+1,justJumped:true,canJumpInaRow:canJumpInaRow)//jumping
            if (b>=d) {
                //shouldn't jump
                if (distance==0) {
                    println("don't Jump")
                    println(b)
                }
                return (false,b)
            }
            else {
                //should jump
                if (distance==0) {
                    println("jump")
                    println(d)
                }
                return (true,d)
                
            }
        }
        
    }

    func nextMove() {
        //first figure out what the next tile needs to be
        var i=nextTile.i
        var j=nextTile.j
        var z=nextTile.z
       // println("test")
        if (self.computerControlled) {
            //active AI. First figure out if you need to jump
            level.createFutureEnnemyPositions(20)
            
            let (a,b) = aINext(nextTile, currentDirection: direction, depth: 10, distance:0,justJumped:false,canJumpInaRow:self.canReallyJumpInARow)

            if (a) {
                self.startAJump()
            }
        }
        
        self.direction=nextDirection(self.currentlyJumping, currentDirection: self.direction, tile: self.nextTile)
        self.nextTile=nextTileToGoTo(nextTile, currentDirection: direction)
        
        
        //let distance=Float(abs((sprite.position.x-nextTile.sprite.position.x+sprite.position.y-nextTile.sprite.position.y)/CGFloat(level.tileSize))) //only works because no diagonal
        let actionMove = SKAction.moveTo(nextTile.sprite.position, duration: NSTimeInterval(1.0/self.speed))
        //distanceToNextTile=1
        let actionEnd = SKAction.runBlock(self.nextMove)
        self.sprite.runAction(SKAction.sequence([actionMove,actionEnd]))
    }

    
    func startAJump() {
        if (!self.currentlyJumping && self.canJump) {
            self.currentlyJumping=true
            self.canJump=false
            let firstAction = SKAction.scaleTo(jumpingScale, duration: NSTimeInterval(0.4/self.speed))
            let secondAction = SKAction.scaleTo(1, duration: NSTimeInterval(0.4/self.speed))
            var waitDuration:Float=0.4
            if (self.canReallyJumpInARow) {
                waitDuration=0
            }
            let thirdAction = SKAction.runBlock(stopAJump)
            let fourthAction = SKAction.scaleTo(1, duration: NSTimeInterval(waitDuration/self.speed))
            let fifthAction = SKAction.runBlock(canJumpAgain)
            
            self.sprite.runAction(SKAction.sequence([firstAction,secondAction,thirdAction,fourthAction,fifthAction]))
            
            //identify if the backback should be released
            if (self.direction==0 && self.nextTile.rightWall != 1 || self.direction==1 && self.nextTile.upWall != 1 || self.direction==2 && self.nextTile.leftWall != 1 || self.direction==3 && self.nextTile.downWall != 1) {
                if (self.backPack.count>0 && self.backPack[backPack.count-1].modeDuration==0) {
                    self.releaseFirstFromBackpack()
                }

            }
            
        }

    }
    
    func stopAJump() {
        self.currentlyJumping=false
    }
    func canJumpAgain() {
        self.canJump=true
    }
    
    

}