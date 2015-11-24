//
//  Level.swift
//  Robot Test
//
//  Created by Clement Gires on 4/28/15.
//  Copyright (c) 2015 test. All rights reserved.
//

import Foundation
import SpriteKit


class Level {
    
    var scene: GameScene
    var tileSize: Int
    var tileArray: [[[Tile]]] //now has different levels
    var node: SKNode
    var tileWidth: Int
    var tileHeight: Int
    var maxHeight: Int //define how far up the grid goes
    var minHeight: Int //define how far down the grid goes
    var currentFloor=0
    
    var futureEnnemyPositions=[[Robot]]()
    
    var numberOfFloors=1
    
    var numberOfHorizontalTilesPerScreen: Int
    var numberOfVerticalTilesPerScreen: Int
    
    var cameraX: CGFloat
    var cameraY: CGFloat
    var playerArray: [Robot]
    var robotArray: [Robot]
    var gameScene: SKScene!
    
    var difficultyLevel: Int
    
    var pacManModeDuration=20
    
    var numberOfHorizontalRooms=1
    var numberOfVerticalRooms=1
    var pacmanMode=false
    var secondLineDisplay=""
    
    var ennemySpeed:Float=0.5
    
    var lengthProba:Float=0.05 //Higher means shorter corridors. Harder. standard= 0.05
    var switchProba:Float=0.4  //Higher means more tortuous corridors. Easier. standard=0.4
    var ennemyProba:Float=0.3  //Higher means more ennemies. harder. standard=0.03. Hard=0.3
    var maxEnnemiesPerCorridor=1 //Higher means more ennemies. harder. Standard=1
    
    
    init(scene: GameScene,tileSize: Int, difficultyLevel: Int) {
        self.scene = scene
        self.difficultyLevel=difficultyLevel
        self.tileSize = tileSize
        self.node = SKNode()
        self.cameraX = CGFloat((Int(scene.frame.width) % tileSize)/2)
        self.cameraY = CGFloat((Int(scene.frame.height) % tileSize)/2)
        
        //self.numberOfHorizontalTilesPerScreen = (Int(scene.frame.width) - (Int(scene.frame.width) % tileSize))/tileSize
        self.numberOfHorizontalTilesPerScreen = Int(scene.frame.width)/tileSize
        self.numberOfVerticalTilesPerScreen = Int(scene.frame.height)/tileSize
        self.tileArray = [[[Tile]]]()
        
        self.tileWidth=self.numberOfHorizontalTilesPerScreen*self.numberOfHorizontalRooms
        self.tileHeight=self.numberOfVerticalTilesPerScreen*self.numberOfVerticalRooms
        self.maxHeight=self.tileHeight
        self.minHeight=0
        scene.addChild(self.node)
        self.node.position = CGPoint(x:self.node.position.x+cameraX,y:self.node.position.y+cameraY)
        //to center the array on the screen
        
        self.robotArray=[Robot]()
        self.playerArray=[Robot]()

    
        //createBlankArray()
        self.initForDifficulty(self.difficultyLevel)
        
        //self.player.nextTile = tileArray[0][0]
        
        //self.player.nextMove()

    }

    func initLevelDisplay() {
        //displays name of the level at the beginning, then erases after 3 seconds
        
        var labelBackground = SKSpriteNode(color: SKColor.blackColor(), size: CGSize(width: self.scene.frame.width*2, height: 100))
        labelBackground.zPosition=2
        labelBackground.position = CGPoint(x: self.scene.frame.width/2, y: self.scene.frame.height/2)

        
        var displaySprite = SKLabelNode(text: "Level \(self.difficultyLevel)")
        displaySprite.zPosition=3
        displaySprite.fontSize=20
        displaySprite.position = CGPoint(x: 0, y: 0)
        displaySprite.verticalAlignmentMode=SKLabelVerticalAlignmentMode.Center
        
        var secondLine = SKLabelNode(text: self.secondLineDisplay)
        secondLine.position = CGPoint(x: 0, y: -30)
        secondLine.zPosition=3
        secondLine.fontSize=20
        //secondLine.verticalAlignmentMode=SKLabelVerticalAlignmentMode.Center
        

        labelBackground.addChild(displaySprite)
        labelBackground.addChild(secondLine)
        
        var firstAction = SKAction.waitForDuration(3)
        var secondAction = SKAction.removeFromParent()
        labelBackground.runAction(SKAction.sequence([firstAction,secondAction]))
        
        self.node.addChild(labelBackground)
        
    }
    
    func initForDifficulty(difficulty:Int) {
        self.difficultyLevel=difficulty
        self.cleanLevelSprites()
        self.robotArray=[Robot]()
        self.playerArray=[Robot]()
        
        switch difficulty {
            case 1:
                numberOfHorizontalRooms=1
                numberOfVerticalRooms=1
                numberOfFloors=1
                self.currentFloor=0
                maxHeight=7
                minHeight=6
                ennemyProba=0
                self.secondLineDisplay="Tap to jump gaps. Reach the flag"
                createRandomArray()
                self.addAPlayer(tileArray[0][minHeight][0], speed: 2,type:0)
                self.addARobot(tileArray[tileWidth-1][maxHeight-1][0], speed: 0, type: 2) //add a flag to finish the level.
            
        case 2:
            numberOfHorizontalRooms=1
            numberOfVerticalRooms=1
            numberOfFloors=1
            self.currentFloor=0
            maxHeight=10
            minHeight=2
            ennemyProba=0
            self.secondLineDisplay="When possible, you'll always turn right"
            createRandomArray()
            self.addAPlayer(tileArray[0][minHeight][0], speed: 2,type:0)
            self.addARobot(tileArray[tileWidth-1][maxHeight-1][0], speed: 0, type: 2) //add a flag to finish the level.
        
        case 3:
            numberOfHorizontalRooms=1
            numberOfVerticalRooms=1
            numberOfFloors=1
            self.currentFloor=0
            maxHeight=15
            minHeight=0
            ennemyProba=0
            self.secondLineDisplay="Good timing will let you jump twice in a row"
            createRandomArray()
            self.addAPlayer(tileArray[0][0][0], speed: 2,type:0)
            self.addARobot(tileArray[tileWidth-1][maxHeight-1][0], speed: 0, type: 2) //add a flag to finish the level.
            
        case 4:
            numberOfHorizontalRooms=1
            numberOfVerticalRooms=1
            numberOfFloors=1
            self.currentFloor=0
            maxHeight=tileHeight
            minHeight=0
            ennemyProba=0
            self.secondLineDisplay="Let's go a bit faster"
            createRandomArray()
            self.addAPlayer(tileArray[0][0][0], speed: 2.5,type:0)
            self.addARobot(tileArray[tileWidth-1][maxHeight-1][0], speed: 0, type: 2) //add a flag to finish the level.
            
       
            
        case 5:
            numberOfHorizontalRooms=1
            numberOfVerticalRooms=1
            numberOfFloors=1
            self.currentFloor=0
            maxHeight=tileHeight
            minHeight=0
            ennemyProba=0.05
            self.secondLineDisplay="Avoid ennemies or start over"
            createRandomArray()
            self.addAPlayer(tileArray[0][0][0], speed: 2.5,type:0)
            self.addARobot(tileArray[tileWidth-1][maxHeight-1][0], speed: 0, type: 2) //add a flag to finish the level.
            
        case 6:
            numberOfHorizontalRooms=1
            numberOfVerticalRooms=1
            numberOfFloors=1
            self.currentFloor=0
            maxHeight=tileHeight
            minHeight=0
            ennemyProba=0.07
            self.secondLineDisplay="Ennemies are generated randomly"
            createRandomArray()
            self.addAPlayer(tileArray[0][0][0], speed: 2.5,type:0)
            self.addARobot(tileArray[tileWidth-1][maxHeight-1][0], speed: 0, type: 2) //add a flag to finish the level.
            
        case 7:
            numberOfHorizontalRooms=1
            numberOfVerticalRooms=1
            numberOfFloors=1
            self.currentFloor=0
            maxHeight=tileHeight
            minHeight=0
            ennemyProba=0.12
            self.secondLineDisplay="Things are starting to heat up"
            createRandomArray()
            self.addAPlayer(tileArray[0][0][0], speed: 2.5,type:0)
            self.addARobot(tileArray[tileWidth-1][maxHeight-1][0], speed: 0, type: 2) //add a flag to finish the level.
        
        
            default:
                numberOfHorizontalRooms=1
                numberOfVerticalRooms=1
                numberOfFloors=1
                self.currentFloor=0
                maxHeight=tileHeight
                minHeight=0
                ennemyProba=0.3
                self.secondLineDisplay="Tap to jump gaps. Reach the flag"
                createRandomArray()
                self.addAPlayer(tileArray[0][0][0], speed: 3,type:0)
                self.addARobot(tileArray[tileWidth-1][maxHeight-1][0], speed: 0, type: 2) //add a flag to finish the level.
            self.addAPlayer(tileArray[0][0][0], speed: 1.5,type:0)
            self.playerArray[1].computerControlled=true
        }

        initLevelDisplay()
    }
    
    
    func updateFloor() {
        for z in 0...self.numberOfFloors-1 {
            for i in 0...(self.tileWidth)-1 {
                for j in 0...(self.tileHeight)-1 {
                    self.tileArray[i][j][z].updateWalls()
                }
            }
        }
        //hide the robots that don't belong to the right floot
        for robot in self.robotArray {
            robot.updateFloor()
        }
        for player in self.playerArray {
            player.updateFloor()
        }
    }
    
    func addAPlayer(tile:Tile,speed:Float,type:Int) {
        self.playerArray.append(Robot(level:self,tile: tile, speed: speed,type:type))
    }
    
    func addARobot(tile:Tile,speed:Float,type:Int) {
        self.robotArray.append(Robot(level:self,tile: tile, speed: speed,type:type))
    }
    
    func createFutureEnnemyPositions(depth:Int) {
        //used for the recursive AI
        futureEnnemyPositions=[[Robot]]()
        var ennemyArray=[Robot]()
        var newEnnemyArray=[Robot]()
        for robot in self.robotArray {
            if (robot.type==1) {
                ennemyArray.append(Robot(robot: robot))
            }
        }
        var step=CGFloat(self.tileSize)/CGFloat(playerArray[0].speed)
        for i in 0...depth {
            futureEnnemyPositions.append(ennemyArray)
            newEnnemyArray=[Robot]()
            for ennemy in ennemyArray {
                var newEnnemy=Robot(robot:ennemy)
                newEnnemy.moveByStep(false, step: step)
                newEnnemyArray.append(newEnnemy)
            }
            ennemyArray=newEnnemyArray
        }
    }
    
    func createRandomArray() {
        //create a new Array with the given difficulty
        self.tileWidth=self.numberOfHorizontalTilesPerScreen*self.numberOfHorizontalRooms
        self.tileHeight=self.numberOfVerticalTilesPerScreen*self.numberOfVerticalRooms
        createBlankArray()
        //resetArray()
        for z in 0...self.numberOfFloors-1 {
            for i in 0...(self.tileWidth)-1 {
                for j in minHeight...(maxHeight)-1 {
                    var t=self.tileArray[i][j][z]
                    var randomType=Int(arc4random_uniform(2))+1
                    var maxRobot=maxEnnemiesPerCorridor
                    if (i==0 && j==0) {
                        maxRobot=0
                    }
                    createPath(t, lengthProba: lengthProba,ennemyProba: ennemyProba, switchProba: switchProba, currentDirection: 0, currentType: randomType, currentLength: 0,maxRobot:maxRobot)
                    t.updateWalls()
                }
            }
        }
        
    }
    
    var minimumLength=2
    
    func nextLevelDifficulty() {
        initForDifficulty(scene.savings.bestLevel+1)
        scene.updateSavings(scene.savings.bestLevel+1)
    }

    
    func createPath(startTile:Tile, lengthProba: Float,ennemyProba:Float, switchProba: Float, currentDirection: Int, currentType: Int, currentLength:Int, maxRobot:Int) {
        //recursive function to create a path
        if (startTile.type != 0) {
            //method has been called on a busy tile
            return
        }
        var maxRobotReturn=maxRobot
        startTile.changeType(currentType)
        var nextDirection=currentDirection
        let i=startTile.i
        let j=startTile.j
        let z=startTile.z
        var stoping=false
        
        if (maxRobot>0 && Float(arc4random_uniform(1000))/1000<ennemyProba && currentLength>2) {
            self.addARobot(startTile, speed: ennemySpeed, type: 1)
            maxRobotReturn--
            
        }
        
        
        //first decide if we stop here or continue
        if (Float(arc4random_uniform(1000))/1000>lengthProba || currentLength<minimumLength ) {
            //println(Float(arc4random_uniform(1000))/1000)
            //we continue
            var switchb=false
            if ((Float(arc4random_uniform(1000))/1000)<switchProba) {
                //we switch if we can
                switchb=true
            }
            if (currentDirection==0 && (i>=self.tileWidth-1 || startTile.rightWall==2 || tileArray[i+1][j][z].type>0 || switchb)) {
                //cannot move to the right as planned
                if (Float(arc4random_uniform(2))<0.5 && j>0 && startTile.downWall != 2 && tileArray[i][j-1][z].type==0) {
                    //move down
                    nextDirection=3
                }
                else if (startTile.upWall != 2 && j<self.tileHeight-1 && tileArray[i][j+1][z].type==0 ) {
                    //move up
                    nextDirection=1
                }
                else if (startTile.downWall != 2 && tileArray[i][j-1][z].type==0) {
                    //move down
                   nextDirection=3
                }
                else {
                    //stop
                    stoping=true
                }
            }
            else if (currentDirection==1 && (j>=self.tileHeight-1 || startTile.upWall==2 || tileArray[i][j+1][z].type>0 || switchb)) {
                //cannot move up as planned
                //println(Float(arc4random_uniform(2)))
                if (Float(arc4random_uniform(2))<0.5 && i<self.tileWidth-1 && startTile.rightWall != 2 && tileArray[i+1][j][z].type==0) {
                    //move right
                    nextDirection=0
                }
                else if (i>0 && startTile.leftWall != 2 && tileArray[i-1][j][z].type==0 ) {
                    //move left
                    nextDirection=2
                }
                else if (i<self.tileWidth-1 && startTile.rightWall != 2 && tileArray[i+1][j][z].type==0) {
                    //move right
                    nextDirection=0
                }
                else {
                    //stop
                    stoping=true
                }
            }
            else if (currentDirection==2 && (i==0 || tileArray[i-1][j][z].type>0 || startTile.leftWall==2 || switchb)) {
                //cannot move to the left as planned
                if (Float(arc4random_uniform(2))<0.5 && j>0 && startTile.downWall != 2 && tileArray[i][j-1][z].type==0) {
                    //move down
                    nextDirection=3
                }
                else if (j<self.tileHeight-1 && startTile.upWall != 2 && tileArray[i][j+1][z].type==0 ) {
                    //move up
                    nextDirection=1
                }
                else if (j>0 && startTile.downWall != 2 && tileArray[i][j-1][z].type==0) {
                    //move down
                    nextDirection=3
                }
                else {
                    //stop
                    stoping=true
                }
            }
            else if (currentDirection==3 && (j==0 || tileArray[i][j-1][z].type>0 || startTile.downWall==2 || switchb)) {
                //cannot move down as planned
                if (Float(arc4random_uniform(2))<0.5 && i<self.tileWidth-1 && startTile.rightWall != 2 && tileArray[i+1][j][z].type==0) {
                    //move right
                    nextDirection=0
                }
                else if (i>0 && startTile.leftWall != 2 && tileArray[i-1][j][z].type==0 ) {
                    //move left
                    nextDirection=2
                }
                else if (i<self.tileWidth-1 && startTile.rightWall != 2 && tileArray[i+1][j][z].type==0) {
                    //move right
                    nextDirection=0
                }
                else {
                    //stop
                    stoping=true
                }
                
                
            }
            
           
            if (!stoping) {
                var nextTile=startTile
                if (nextDirection==0) {
                    nextTile=tileArray[i+1][j][z]
                    startTile.rightWall=0
                    nextTile.leftWall=0
                }
                else if (nextDirection==1) {
                    nextTile=tileArray[i][j+1][z]
                    startTile.upWall=0
                    nextTile.downWall=0
                }
                else if (nextDirection==2) {
                    nextTile=tileArray[i-1][j][z]
                    startTile.leftWall=0
                    nextTile.rightWall=0
                }
                else if (nextDirection==3) {
                    nextTile=tileArray[i][j-1][z]
                    startTile.downWall=0
                    nextTile.upWall=0
                }
                startTile.updateWalls()
                nextTile.updateWalls()
                createPath(nextTile, lengthProba: lengthProba, ennemyProba:ennemyProba, switchProba: switchProba, currentDirection: nextDirection, currentType: currentType, currentLength: currentLength+1,maxRobot:maxRobotReturn)
            }
            else if (currentLength==0) {
                //If a square is lonely
                if (startTile.leftWall != 2 && tileArray[i-1][j][z].type != 4 ) {
                    startTile.leftWall=0
                    tileArray[i-1][j][z].rightWall=0
                    startTile.updateWalls()
                    tileArray[i-1][j][z].updateWalls()
                    startTile.changeType(tileArray[i-1][j][z].type)
                }
                else {
                    startTile.rightWall=0
                    startTile.updateWalls()
                    tileArray[i+1][j][z].leftWall=0
                    tileArray[i+1][j][z].updateWalls()
                    startTile.changeType(tileArray[i+1][j][z].type)
                }
                
            }
            
            
            
            
        }
        
    }
    
   /* func resetArray() {
        //Clean array with right type
        for i in 0...self.tileWidth-1 {
            for j in 0...self.tileHeight-1 {
                var t=self.tileArray[i][j]
                t.changeType(0)
                if (t.upWall != 2) {
                    t.upWall=1
                }
                if (t.downWall != 2) {
                    t.downWall=1
                }
                if (t.rightWall != 2) {
                    t.rightWall=1
                }
                if (t.leftWall != 2) {
                    t.leftWall=1
                }
                t.updateWalls()
            }
        }
    }
*/
    
    
    func cleanLevelSprites() {
        if (self.tileArray.count>0) {
        for z  in 0...numberOfFloors-1 {
            for i in 0...(self.tileWidth)-1 {
                for j in 0...(self.tileHeight)-1 {
                    var t=self.tileArray[i][j][z]
                    t.sprite.removeFromParent()
                }
            }
        }
        for player in self.playerArray {
            player.sprite.removeFromParent()
            for robot in player.backPack {
                robot.sprite.removeFromParent()
            }
            
        }
        for robot in self.robotArray {
            robot.sprite.removeFromParent()
            
        }
        }
}
    
    
    func createBlankArray() {
        self.tileArray=[[[Tile]]]()
        //first create the array
        for i in 0...(self.tileWidth)-1 {
            self.tileArray.append([[Tile]]())
            for j in 0...(self.tileHeight)-1 {
                self.tileArray[i].append([Tile]())
                for z in 0...self.numberOfFloors-1 {
                    self.tileArray[i][j].append(Tile(level: self, i: i, j: j,z:z))
                }
                
            }
        }
        for z in 0...self.numberOfFloors-1 {
        for i in 0...(self.tileWidth-1) {
            for j in 0...(self.tileHeight-1) {
                if (j==maxHeight-1) {
                    tileArray[i][j][z].upWall=2
                    tileArray[i][j][z].updateWalls()
                }
                if (j==minHeight) {
                    tileArray[i][j][z].downWall=2
                    tileArray[i][j][z].updateWalls()
                }

                if ((i+1)%self.numberOfHorizontalTilesPerScreen==0) {
                    //On the edge of a room
                    self.tileArray[i][j][z].rightWall=2
                    if (i<self.tileWidth-1) {
                        self.tileArray[i+1][j][z].leftWall=2
                        if (j%self.numberOfVerticalTilesPerScreen==self.numberOfVerticalTilesPerScreen/2) {
                            //need to create a door between the screens
                            var t=self.tileArray[i][j][z]
                            var randomType=4
                            t.rightWall=1
                            t.leftWall=0
                            t.changeType(randomType)
                            t=self.tileArray[i-1][j][z]
                            t.rightWall=0
                            t.leftWall=1
                            t.changeType(randomType)
                            t=self.tileArray[i+1][j][z]
                            t.leftWall=1
                            t.rightWall=0
                            t.changeType(randomType)
                            t=self.tileArray[i+2][j][z]
                            t.leftWall=0
                            t.rightWall=1
                            t.changeType(randomType)
                            
                        }
                        
                    }
                    
                }
                if ((j+1)%self.numberOfVerticalTilesPerScreen==0) {
                    //On the edge of a room
                    self.tileArray[i][j][z].upWall=2
                    if (j<self.tileHeight-1) {
                        self.tileArray[i][j+1][z].downWall=2
                        if (i%self.numberOfVerticalTilesPerScreen==self.numberOfHorizontalTilesPerScreen/2) {
                            //need to create a door between the screens
                            var randomType=4
                            var t=self.tileArray[i][j][z]
                            t.upWall=1
                            t.downWall=0
                            t.changeType(randomType)
                            t=self.tileArray[i][j-1][z]
                            t.upWall=0
                            t.downWall=1
                            t.changeType(randomType)
                            t=self.tileArray[i][j+1][z]
                            t.upWall=0
                            t.downWall=1
                            t.changeType(randomType)
                            t=self.tileArray[i][j+2][z]
                            t.upWall=1
                            t.downWall=0
                            t.changeType(randomType)
                        }
                        
                    }
                    
                }
            }

            }
        }
    }
}