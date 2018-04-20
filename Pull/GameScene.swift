//
//  GameScene.swift
//  Pull
//
//  Created by Sunny Ouyang on 4/17/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import SpriteKit
import GameplayKit

enum HeroState {
    case normal
    case weakened
}

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
    var tapLocation: CGPoint!
    var lifeNodes = [SKSpriteNode]()
    var ballLayer: SKNode!
    var gameOverLabel: SKNode!

    
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60fps*/
    var blueSpawnTimer: CFTimeInterval = 0
    var redSpawnTimer: CFTimeInterval = 0
    var pullable = true
    var returnAction: SKAction? = nil
    var score = 0
    var heroState: HeroState = .normal
    var force: CGFloat = 1
    var lives: Int = 3
    var gameState: GameState = .active
    
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
        gameOverLabel = self.childNode(withName: "GameOver")
        hero = heroSource.copy() as! SKSpriteNode
        hero.position = CGPoint(x: 375, y: 50)
        physicsWorld.contactDelegate = self
        self.addChild(hero)
    }
    

    func spawnBalls() {
        if gameState == .active {
            spawnRedBall()
            spawnBlueBall()
        }
        
    }
    
    func spawnRedBall() {
        if redSpawnTimer > 1.5 {
            let random = arc4random_uniform(100)
            redSpawnTimer = 0
            let newBallNode = redSource.copy() as! SKSpriteNode
            let positionX: CGFloat!
            let positionY = CGFloat(randomNumber(inRange: 340...960))
            if random <= 50 {
                positionX = -260
                newBallNode.physicsBody?.velocity.dx = CGFloat(575)
            } else {
                positionX = 900
                newBallNode.physicsBody?.velocity.dx = CGFloat(-575)
            }
            let position = CGPoint(x: positionX, y: positionY)
            newBallNode.position = self.convert(position, to: ballLayer)
            ballLayer.addChild(newBallNode)
        }
    }
    
    func spawnBlueBall() {
        let random = randomNumber(inRange: 100...650)
        if blueSpawnTimer > 2 {
            blueSpawnTimer = 0
            
            let newBall = blueSource.copy() as! SKSpriteNode
            let positionY: CGFloat = 1500
            let positionX = CGFloat(random)
            let position = CGPoint(x: positionX, y: positionY)
            newBall.position = self.convert(position, to: ballLayer)
            newBall.physicsBody?.velocity.dy = -400
            ballLayer.addChild(newBall)

        }
        
        
    }
    
    func getHypotenuse(x: CGFloat, y: CGFloat) -> CGFloat {
        return sqrt(pow(x, 2) + pow(y, 2))
    }
    
    func newdX(location: CGPoint) -> CGFloat{
        let dX = location.x - hero.position.x
        let dY = location.y - hero.position.y
        let slope = dY / dX
        let answer = (800 / slope) + dX
        return answer
    }
    
    
    
    func Grab(location: CGPoint) {
        if gameState == .active {
            if pullable {
                pullable = !pullable
                let smalldY = location.y - hero.position.y
                let dX = newdX(location: location) * CGFloat(force)
                let dY: CGFloat = (CGFloat(800) + smalldY) * CGFloat(force)
                let vector = CGVector(dx: dX, dy: dY)
                let angle = atan2f(Float(vector.dx), Float(vector.dy))
                hero.zRotation = CGFloat(angle)
                hero.physicsBody?.applyImpulse(vector)
                
            }
        }
    }
    
    func activateWeaken() {
        if gameState == .active {
            let wait = SKAction.wait(forDuration:3)
            let weaken = SKAction.run {
                self.heroState = .weakened
            }
            let normalize = SKAction.run {
                self.heroState = .normal
            }
            run(SKAction.sequence([weaken, wait, normalize]))
        }
    }
    
    
    func handleHero(state: HeroState) {
        
        if state == .normal {
            force = 1
            hero.alpha = 1
        } else {
            force = 0.3
            hero.alpha = 0.5
        }
        
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
    
    func resetHero() {
    
        hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        let dX = (CGFloat(375) - hero.position.x) * CGFloat(force)
        let dY = (CGFloat(50) - hero.position.y) * CGFloat(force)
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
                score += 1
                //nodeA is the square
                if contactA.categoryBitMask > contactB.categoryBitMask {
                    nodeB.removeFromParent()
                } else { //nodeA is blue
                    nodeA.removeFromParent()
                }
            }
            //Handling redBall contacts
        } else if nodeA.name == "red" || nodeB.name == "red" {
            //if red ball hits the borders
            if contactA.categoryBitMask == 8 || contactB.categoryBitMask == 8 {
                // border is contact A, blue ball contactB
                if contactA.categoryBitMask > contactB.categoryBitMask {
                    nodeB.removeFromParent()
                } else { //nodeA is blue
                    nodeA.removeFromParent()
                }
                //if red ball hits the square
            } else if contactA.categoryBitMask == 5 || contactB.categoryBitMask == 5 {
                activateWeaken()
                resetHero()
                //nodeA is the square
                if contactA.categoryBitMask > contactB.categoryBitMask {
                    nodeB.removeFromParent()
                } else { //nodeA is blue
                    nodeA.removeFromParent()
                }
            }
        }
        
    }
    
    func handleGameOver() {
        if gameState == .gameOver {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if lives <= 0 {
            gameState = .gameOver
            gameOverLabel.isHidden = false
            ballLayer.removeAllChildren()
        }
        blueSpawnTimer += fixedDelta
        redSpawnTimer += fixedDelta
        spawnBalls()
        handleHero(state: heroState)
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
