//
//  Tile.swift
//  Robot Test
//
//  Created by Clement Gires on 4/28/15.
//  Copyright (c) 2015 test. All rights reserved.
//

import Foundation
import SpriteKit

class Tile {
    
    var wallColor = SKColor(red: 149/255, green: 165/255, blue: 166/255, alpha: 1.0)
    
    //rgb(149, 165, 166)

    var hardWallWidth = 4
    var softWallWidth = 2
    var level: Level
    var sprite: SKNode
    var upWall: Int //0=no wall, 1=soft wall, 2=hard wall
    var upSprite: SKSpriteNode!
    var downWall: Int
    var downSprite: SKSpriteNode!
    var rightWall: Int
    var rightSprite: SKSpriteNode!
    var leftWall: Int
    var leftSprite: SKSpriteNode!
    var visited=false
    var i: Int
    var j: Int
    var z: Int
    var color: UIColor
    var type = 0 //0 means that it is not filled up. 4 means that it is a bridge between two rooms
    
    init(level: Level,i:Int,j:Int,z:Int) {
        self.level = level
        self.i = i
        self.j = j
        self.z = z
        self.downWall = 1;
        self.rightWall = 1;
        self.leftWall = 1;
        self.upWall = 1;
        self.color = UIColor.blackColor()
        self.sprite=SKNode()
        //self.sprite = SKSpriteNode(color: color, size: CGSize(width:level.tileSize,height:level.tileSize))
        self.sprite.position=CGPoint(x:level.tileSize/2+level.tileSize*i,y:level.tileSize/2+level.tileSize*j)
        self.level.node.addChild(self.sprite)
        
        //Need to add the walls
        if (i==0) {
           leftWall = 2
        }
        else if (i==level.tileWidth-1) {
            rightWall = 2
        }
        if (j==0) {
            downWall = 2
        }
        else if (j==level.tileHeight-1) {
            upWall = 2
        }
        self.updateWalls()
    
    }
    
    func removeFromParent() {
        self.sprite.removeFromParent()
    }
    
    func equalTo(tile:Tile) -> Bool {
        return (self.i==tile.i && self.j==tile.j && self.z==tile.z)
    }

    func eliminateEnnemiesFromCorridor() {
        //first reset all visited cells
        for indexI in 0...level.tileWidth-1 {
            for indexJ in 0...level.tileHeight-1 {
                for indexZ in 0...level.numberOfFloors-1 {
                    level.tileArray[indexI][indexJ][indexZ].visited=false
                }
            }
        }
        //then call the rec function
        self.eliminateEnnemiesFromCorridorRec()
    }
    

    
    func eliminateEnnemiesFromCorridorRec() {
         //eliminate all ennemies from the current corridor. Call with 100 (safe bet)
        //Could be done more cleanly by counting the places that have already been visited
        if (!self.visited) {
            self.visited=true
            //first eliminate ennemies that are here
            var index=0
            while (index<level.robotArray.count) {
                var ennemy=level.robotArray[index]
                if ((ennemy.type==1) && (ennemy.nextTile.equalTo(self))) {
                    //need to delete ennemy
                    level.robotArray.removeAtIndex(index)
                    ennemy.sprite.removeFromParent()
                    ennemy.sprite.removeAllActions()
                    index = index-1
                }
                index++
            }
            //then call the function
            if (self.upWall==0) {
                level.tileArray[self.i][self.j+1][self.z].eliminateEnnemiesFromCorridorRec()
            }
            if (self.downWall==0) {
                level.tileArray[i][j-1][z].eliminateEnnemiesFromCorridorRec()
            }
            if (self.rightWall==0) {
                level.tileArray[i+1][j][z].eliminateEnnemiesFromCorridorRec()
            }
            if (self.leftWall==0) {
                level.tileArray[i-1][j][z].eliminateEnnemiesFromCorridorRec()
            }
        }
    }
    
    func changeType(type: Int) {
        self.type=type
        switch type {
        case 0:
            self.color = UIColor.whiteColor()
        case 1:
            self.color = UIColor.redColor()
        case 2:
            self.color = UIColor.orangeColor()
        default:
            self.color = UIColor.blueColor()
        }
       // self.sprite.color=self.color
    }
    
    func changeColor(newColor: UIColor) {
        self.color=newColor
        //self.sprite.color=newColor
    }
    
    
    func updateWalls() {
        //First deal with up Wall
        self.sprite.removeFromParent()
        if (self.z==self.level.currentFloor) {
            self.level.node.addChild(self.sprite)
        }
        
        var thickness=3
        if (self.upSprite != nil) {
            self.upSprite.removeFromParent()
        }
        
        if (self.upWall == 0 ) {
            self.upSprite = SKSpriteNode(color:wallColor,size:CGSize(width:thickness,height:1+level.tileSize/2))
            //self.upSprite = SKSpriteNode(imageNamed: "verticalWall") //better performance
            self.upSprite.position=CGPoint(x:0,y:level.tileSize/4)
            self.sprite.addChild(self.upSprite)
        }
        
        //Same with Down wall
        if (self.downSprite != nil) {
            self.downSprite.removeFromParent()
        }
        
        if (self.downWall == 0 ) {
            self.downSprite = SKSpriteNode(color:wallColor,size:CGSize(width:thickness,height:1+level.tileSize/2))
            //self.downSprite = SKSpriteNode(imageNamed: "verticalWall") //better performance
            self.downSprite.position=CGPoint(x:0,y:-level.tileSize/4)
            self.sprite.addChild(self.downSprite)
        }
        //Same with right wall
        if (self.rightSprite != nil) {
            self.rightSprite.removeFromParent()
        }
        
        if (self.rightWall == 0 ) {
            self.rightSprite = SKSpriteNode(color:wallColor,size:CGSize(width:1+level.tileSize/2,height:thickness))
            //self.rightSprite = SKSpriteNode(imageNamed: "horizontalWall") //better performance
            self.rightSprite.position=CGPoint(x:level.tileSize/4,y:0)
            self.sprite.addChild(self.rightSprite)
        }
        //Same with left wall
        if (self.leftSprite != nil) {
            self.leftSprite.removeFromParent()
        }
        
        if (self.leftWall == 0 ) {
            self.leftSprite = SKSpriteNode(color:wallColor,size:CGSize(width:1+level.tileSize/2,height:thickness))
            //self.leftSprite = SKSpriteNode(imageNamed: "horizontalWall") //better performance
            self.leftSprite.position=CGPoint(x:-level.tileSize/4,y:0)
            self.sprite.addChild(self.leftSprite)
        }
        
        
    }
    
    func updateWalls2() {
        //First deal with up Wall
        if (self.upSprite != nil) {
            self.upSprite.removeFromParent()
        }
        var thickness = softWallWidth
        if (self.upWall == 2) {
            thickness=hardWallWidth
        }
        
        if (self.upWall != 0 ) {
            self.upSprite = SKSpriteNode(color:wallColor,size:CGSize(width:level.tileSize,height:thickness))
            self.upSprite.position=CGPoint(x:0,y:level.tileSize/2)
            self.sprite.addChild(self.upSprite)
        }
        
        //Same with Down wall
        if (self.downSprite != nil) {
            self.downSprite.removeFromParent()
        }
        thickness = softWallWidth
        if (self.downWall == 2) {
            thickness=hardWallWidth
        }
        
        if (self.downWall != 0 ) {
            self.downSprite = SKSpriteNode(color:wallColor,size:CGSize(width:level.tileSize,height:thickness))
            self.downSprite.position=CGPoint(x:0,y:-level.tileSize/2)
            self.sprite.addChild(self.downSprite)
        }
        
        //Same with Right Wall
        if (self.rightSprite != nil) {
            self.rightSprite.removeFromParent()
        }
        thickness = softWallWidth
        if (self.rightWall == 2) {
            thickness=hardWallWidth
        }
        
        if (self.rightWall != 0 ) {
            self.rightSprite = SKSpriteNode(color:wallColor,size:CGSize(width:thickness,height:level.tileSize))
            self.rightSprite.position=CGPoint(x:level.tileSize/2,y:0)
            self.sprite.addChild(self.rightSprite)
        }
        
        //Same with left Wall
        if (self.leftSprite != nil) {
            self.leftSprite.removeFromParent()
        }
        thickness = softWallWidth
        if (self.leftWall == 2) {
            thickness=hardWallWidth
        }
        
        if (self.leftWall != 0 ) {
            self.leftSprite = SKSpriteNode(color:wallColor,size:CGSize(width:thickness,height:level.tileSize))
            self.leftSprite.position=CGPoint(x:-level.tileSize/2,y:0)
            self.sprite.addChild(self.leftSprite)
        }


    }
    
    
}