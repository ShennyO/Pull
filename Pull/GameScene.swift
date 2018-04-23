//
//  GameScene.swift
//  Pull
//
//  Created by Sunny Ouyang on 4/17/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import SpriteKit
import GameplayKit


enum GameState {
    case gameOver
    case active
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var heroSource: SKSpriteNode!
    var hero: SKSpriteNode!
    var blueSource: SKSpriteNode!
    var redSource: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var boomSource: SKSpriteNode!
    var boomTwoSource: SKSpriteNode!
    var boomThreeSource: SKSpriteNode!
    var boomFourSource: SKSpriteNode!
    var boomFiveSource: SKSpriteNode!
    var heartSource: SKSpriteNode!
    var tapLocation: CGPoint!
    var lifeNodes = [SKSpriteNode]()
    var ballLayer: SKNode!
    var gameOverLabel: SKNode!
    var restart: MSButtonNode!

    
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60fps*/
    var blueSpawnTimer: CFTimeInterval = 0
    var ballTimer: CFTimeInterval = 0.5
    var pullable = true
    var score = 0
    var lives: Int = 3
    var gameState: GameState = .active
    var force: CGFloat = 1
    var ballSpeed: CGFloat = 1
    var hitCounter = 0
    var NodesHitCounter = 0
    
    override func didMove(to view: SKView) {
        //Adding our lifeNodes to our array, now we can delete them in order
        if gameState == .active {
            for x in 1...3 {
                let lifeNode = self.childNode(withName: "life\(x)")
                self.lifeNodes.append(lifeNode as! SKSpriteNode)
            }
        }
        ballLayer = self.childNode(withName: "ballLayer")
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        blueSource = self.childNode(withName: "blue") as! SKSpriteNode
        redSource = self.childNode(withName: "red") as! SKSpriteNode
        heroSource = self.childNode(withName: "square") as! SKSpriteNode
        heartSource = self.childNode(withName: "heart") as! SKSpriteNode
        boomSource = self.childNode(withName: "Boom") as! SKSpriteNode
        boomTwoSource = self.childNode(withName: "twoCollision") as! SKSpriteNode
        boomThreeSource = self.childNode(withName: "threeCollision") as! SKSpriteNode
        boomFourSource = self.childNode(withName: "fourCollision") as! SKSpriteNode
        boomFiveSource = self.childNode(withName: "fiveCollision") as! SKSpriteNode
        gameOverLabel = self.childNode(withName: "GameOver")
        restart = self.childNode(withName: "restart") as! MSButtonNode
        restart.isHidden = true
        restart.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene?.scaleMode = .aspectFill
            
            /* Restart game scene */
            skView?.presentScene(scene)
            
        }
        hero = heroSource.copy() as! SKSpriteNode
        hero.position = CGPoint(x: 375, y: 50)
        physicsWorld.contactDelegate = self
        self.addChild(hero)
    }
    
    
    
    func createCollisionBoom(point: CGPoint) {
        let boom: SKSpriteNode!
        let expandingAction: SKAction!
    
        if hitCounter == 1 {
            boom = self.boomSource.copy() as! SKSpriteNode
            expandingAction = SKAction.scale(to: 3.0,                                                        duration: 0.2)
            score += 1
        } else if hitCounter == 2 {
            boom = self.boomTwoSource.copy() as! SKSpriteNode
            expandingAction = SKAction.scale(to: 4.0,                                                        duration: 0.2)
            score += 3
        } else if hitCounter == 3 {
            boom = self.boomThreeSource.copy() as! SKSpriteNode
            expandingAction = SKAction.scale(to: 6.0,                                                        duration: 0.2)
            score += 10
        } else if hitCounter == 4 {
            boom = self.boomFourSource.copy() as! SKSpriteNode
            expandingAction = SKAction.scale(to: 8.0,                                                        duration: 0.2)
            score += 25
        } else if hitCounter >= 5 {
            boom = self.boomFiveSource.copy() as! SKSpriteNode
            expandingAction = SKAction.scale(to: 10,                                                        duration: 0.3)
            score += 100
        } else {
            return
        }
        
        
        boom.position = self.convert(point, to: ballLayer)
        self.addChild(boom)
        let remove = SKAction.run {
            boom.removeFromParent()
        }
        let sequence = SKAction.sequence([expandingAction, remove])
        boom.run(sequence)
    }
    
    //:MARK handle levels in the game
    
    func handleLevel() {
        if NodesHitCounter >= 100 && NodesHitCounter <= 300 {
            force = 1.5
            ballSpeed = 1.5
            ballTimer = 0.375
            
        } else if NodesHitCounter >= 300 {
            ballSpeed = 1.75
            force = 1.75
            ballTimer = 0.3
            hero.color = UIColor.red
        }
    }
    
    func addHealth() {
        let newHealth = self.lifeNodes.first?.copy() as! SKSpriteNode
        let positionY: CGFloat = 1275
        let lastLifeNode = self.lifeNodes.last
        let positionX = (lastLifeNode?.position.x)! - CGFloat(71.444)
        newHealth.position = CGPoint(x: positionX, y: positionY)
        self.addChild(newHealth)
        self.lifeNodes.append(newHealth)
    }
    
    func spawnHearts() {
        let random = randomNumber(inRange: 0...5000)
        if random <= 1 {
            let xSpawnPoint = randomNumber(inRange: 100...650)
            let heart = heartSource.copy() as! SKSpriteNode
            let positionY: CGFloat = 1500
            let positionX = CGFloat(xSpawnPoint)
            let position = CGPoint(x: positionX, y: positionY)
            heart.position = self.convert(position, to: ballLayer)
            heart.physicsBody?.velocity.dy = -600 * ballSpeed
            ballLayer.addChild(heart)
        }
    }
   
    
    
    func spawnBlueBall() {
        if gameState == .active {
            let random = randomNumber(inRange: 100...650)
            if blueSpawnTimer > ballTimer {
                blueSpawnTimer = 0
                
                let newBall = blueSource.copy() as! SKSpriteNode
                let positionY: CGFloat = 1500
                let positionX = CGFloat(random)
                let position = CGPoint(x: positionX, y: positionY)
                newBall.position = self.convert(position, to: ballLayer)
                newBall.physicsBody?.velocity.dy = -500 * ballSpeed
                ballLayer.addChild(newBall)
                
            }
        }
    }
    
    func getHypotenuse(x: CGFloat, y: CGFloat) -> CGFloat {
        return sqrt(pow(x, 2) + pow(y, 2))
    }
    
    func newdX(location: CGPoint) -> CGFloat{
        let dX = location.x - hero.position.x
        let dY = location.y - hero.position.y
        let slope = dY / dX
        let answer = (((1000 * force) - dY) / slope) + dX
        return answer
    }
    
    
    
    func Grab(location: CGPoint) {
        if gameState == .active {
            if pullable {
                hitCounter = 0
                pullable = !pullable
                let dX = newdX(location: location)
                let dY: CGFloat = CGFloat(1000 * force)
                let vector = CGVector(dx: dX, dy: dY)
                let angle = atan2f(Float(vector.dx), Float(vector.dy))
                hero.zRotation = CGFloat(angle)
                hero.physicsBody?.applyImpulse(vector)
                
            }
        }
    }
    
    
    func handleHero() {
        
        if hero.position.y > CGFloat(960) {
            resetHero()
        }
        
        if hero.position.y < -125 {
            hero.removeFromParent()
            hero = heroSource.copy() as! SKSpriteNode
            hero.position = CGPoint(x: 375, y: 50)
            self.addChild(hero)
            pullable = true
        }
        
    }
    
    func resetdX() -> CGFloat {
        let dX = (CGFloat(375) - hero.position.x)
        let dY = (CGFloat(50) - hero.position.y)
        let slope = dY / dX
        let newdX = ((-550 * force) - dY) / slope + dX
        //x will already have a negative/positive position
        return newdX + dX
    }
    
    func resetHero() {
    
        hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        let dX = resetdX()
        let dY = CGFloat(-550 * force) - hero.position.y
        let vector = CGVector(dx: dX, dy: dY)
        hero.physicsBody?.applyImpulse(vector)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            Grab(location: touch.location(in: self))
            
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        //Handling Blue Ball contacts
        if nodeA.name == "blue" || nodeB.name == "blue" {
            //if blue ball hits the borders
            if contactA.categoryBitMask == 8 || contactB.categoryBitMask == 8 {
                
                
                lives -= 1
                let lifeNode = self.lifeNodes.last
                lifeNode?.removeFromParent()
                self.lifeNodes.removeLast()
                
                // border is contact A, blue ball contactB
                if contactA.categoryBitMask > contactB.categoryBitMask {
                    nodeB.removeFromParent()
                } else { //nodeA is blue
                    nodeA.removeFromParent()
                }
                //if blueBall hits the square
            } else if contactA.categoryBitMask == 5 || contactB.categoryBitMask == 5 {
                hitCounter += 1
                NodesHitCounter += 1
                let position = contact.contactPoint
                
                createCollisionBoom(point: position)
                //nodeA is the square
                if contactA.categoryBitMask > contactB.categoryBitMask {
                    nodeB.removeFromParent()
                } else { //nodeA is blue
                    nodeA.removeFromParent()
                }
            }
            //Handling heart contacts
        } else if nodeA.name == "heart" || nodeB.name == "heart" {
            // if heart hits border
            if contactA.categoryBitMask == 8 || contactB.categoryBitMask == 8 {
                // border is contact A, blue ball contactB
                if contactA.categoryBitMask > contactB.categoryBitMask {
                    nodeB.removeFromParent()
                } else { //nodeA is blue
                    nodeA.removeFromParent()
                }
            } else if contactA.categoryBitMask == 5 || contactB.categoryBitMask == 5 {
                lives += 1
                addHealth()
                if contactA.categoryBitMask > contactB.categoryBitMask {
                    nodeB.removeFromParent()
                } else { //nodeA is blue
                    nodeA.removeFromParent()
                }
                
            }
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if lives <= 0 {
            gameState = .gameOver
            gameOverLabel.isHidden = false
            restart.isHidden = false
            ballLayer.removeAllChildren()
        }
        blueSpawnTimer += fixedDelta
        handleLevel()
        spawnBlueBall()
        spawnHearts()
        handleHero()
        scoreLabel.text = "\(score)"
    }
}

extension GameScene {
    public func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
        let length = Int64(range.upperBound - range.lowerBound + 1)
        let value = Int64(arc4random()) % length + Int64(range.lowerBound)
        return T(value)
    }
}
