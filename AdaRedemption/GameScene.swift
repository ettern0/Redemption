//
//  GameScene.swift
//  AdaRedemption
//
//  Created by Евгений Сердюков on 10.10.2021.
//

import SpriteKit

enum CollisionType: UInt32 {
    case player = 1
    case road = 2
    case ada = 4
    
}

class GameScene: SKScene {
    
let player = SKSpriteNode(imageNamed: "umbrellaMan")
    
    override func didMove(to view: SKView) {
        if let rainParticles = SKEmitterNode(fileNamed: "RainParticles") {
            rainParticles.position = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
            rainParticles.zPosition = -20
            addChild(rainParticles)
        }
        if let cloudParticles = SKEmitterNode(fileNamed: "CloudParticles") {
            cloudParticles.position = CGPoint(x: 0, y: UIScreen.main.bounds.height/2 - cloudParticles.frame.size.height)
            cloudParticles.zPosition = -1
            addChild(cloudParticles)
        }
        lightningStrike()
    
        player.name = "player"
        player.position.x = frame.minX + player.frame.width * 2
        player.position.y = childNode(withName: "roadPB")!.position.y + player.frame.height/2
        player.zPosition = 1
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.ada.rawValue | CollisionType.road.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.ada.rawValue | CollisionType.road.rawValue
        player.physicsBody?.isDynamic = false
        
    }
    
   
    
    
    
    
    
    
    
    
    /* LightningGenerator
     https://github.com/artturijalli/Lightning-Generator
     */
    
    let darkBackgroundColor = UIColor(red: 15/255, green: 25/255, blue: 25/255, alpha: 1)
    let litUpBackgroundColor = UIColor.gray
    let flickerInterval = TimeInterval(0.04)
    
    func thunderClap() {
        self.run(SKAction.playSoundFileNamed("thunderClap.mp3", waitForCompletion: false))
    }

    func lightningStrike(maxFlickeringTimes: Int = 5, previosArrayOfLightnin: [SKShapeNode]? = nil) {
        
         let throughPath = getRandomLightningPath()
        
        if let removeNodes = previosArrayOfLightnin {
            self.removeChildren(in: removeNodes)
        }
        
        let fadeTime = TimeInterval(CGFloat.random(in: 0.005 ... 0.03))
        let waitAction = SKAction.wait(forDuration: flickerInterval)

        let reduceAlphaAction = SKAction.fadeAlpha(to: 0.0, duration: fadeTime)
        let increaseAlphaAction = SKAction.fadeAlpha(to: 1.0, duration: fadeTime)
        let flickerSeq = [waitAction, reduceAlphaAction, increaseAlphaAction]

        var seq: [SKAction] = []

        let numberOfFlashes = Int.random(in: 1 ... maxFlickeringTimes)

        for _ in 1 ... numberOfFlashes {
            seq.append(contentsOf: flickerSeq)
        }

        for line in throughPath {
            seq.append(SKAction.fadeAlpha(to: 0, duration: 0.25))
            seq.append(SKAction.removeFromParent())

            line.run(SKAction.sequence(seq))
            self.addChild(line)
        }
        
        flashTheScreen(nTimes: numberOfFlashes)
        //thunderClap()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(Int.random(in: 5...20))) {
            self.lightningStrike(maxFlickeringTimes: 5, previosArrayOfLightnin: throughPath)
        }
    }
    
    func flashTheScreen(nTimes: Int) {
        let lightUpScreenAction = SKAction.run { self.backgroundColor = self.litUpBackgroundColor }
        let waitAction = SKAction.wait(forDuration: flickerInterval)
        let dimScreenAction = SKAction.run { self.backgroundColor = self.darkBackgroundColor }

        var flashActionSeq: [SKAction] = []
        for _ in 1 ... nTimes + 1 {
            flashActionSeq.append(contentsOf: [lightUpScreenAction, waitAction, dimScreenAction, waitAction])
        }
        
        self.run(SKAction.sequence(flashActionSeq))
    }
    
    func getRandomLightningPath (startPoint: CGPoint? = nil, startAngle: CGFloat? = nil, isBranch: Bool = false) -> [SKShapeNode] {
        
        
        let startingFrom = startPoint ?? CGPoint(
            x: Double.random(in: -UIScreen.main.bounds.width/2...UIScreen.main.bounds.width/2),
            y: UIScreen.main.bounds.height / 2)
        let angle = startAngle ?? 0
        
        func createLine(pointA: CGPoint, pointB: CGPoint) -> SKShapeNode {
            let pathToDraw = CGMutablePath()
            pathToDraw.move(to: pointA)
            pathToDraw.addLine(to: pointB)
            
            let line = SKShapeNode()
            line.path = pathToDraw
            line.glowWidth = 1
            line.strokeColor = UIColor(red: 255/255, green: 212/255, blue: 251/255, alpha: 1)
            line.zPosition = -10
            
            return line
        }
        
        var strikePath: [SKShapeNode] = []
        
        var startPoint = startingFrom
        var endPoint = CGPoint(x: startingFrom.x, y: startingFrom.y)
        
        let numberOfLines = isBranch ? 50 : 120
        
        var idx = 0
        while idx < numberOfLines {
            strikePath.append(createLine(pointA: startPoint, pointB: endPoint))
            startPoint = endPoint
            
            let r = CGFloat(10)
            endPoint.y -= r * cos(angle) + CGFloat.random(in: -10 ... 10)
            endPoint.x += r * sin(angle) + CGFloat.random(in: -10 ... 10)
            
            if Int.random(in: 0 ... 100) == 1 {
                let branchingStartPoint = endPoint
                let branchingAngle = CGFloat.random(in: -CGFloat.pi / 4 ... CGFloat.pi / 4)
                
                strikePath.append(contentsOf: getRandomLightningPath(startPoint: branchingStartPoint, startAngle: branchingAngle, isBranch: true))
            }
            idx += 1
        }
        
        return strikePath
        
    }

}




