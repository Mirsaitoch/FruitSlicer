//
//  GameScene.swift
//  Fruit Slicer
//
//  Created by Мирсаит Сабирзянов on 12.03.2025.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var scoreLabel: SKLabelNode!
    var levelLabel: SKLabelNode!
    var scoreBackground: SKSpriteNode!
    var score = 0 {
        didSet { scoreLabel.text = "\(score)" }
    }
    
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let fruit: UInt32 = 0x1 << 0
        static let bomb: UInt32 = 0x1 << 1
    }
    
    private let fruitSize: CGFloat = 75.0
    private let fruitRadius: CGFloat = 37.5
    
    private let fruits = ["apple", "cherry", "lemon", "orange", "plum", "strawberry"]
    var maxLevel = UserDefaults.standard.integer(forKey: "maxLevel")
    var selectedLevel = UserDefaults.standard.integer(forKey: "selectedLevel")

    var fruitCount = 0
    var bombCount = 0
    
    private var initialFruitCount = 0
    private var cutFruitCount = 0
    private var minSuccessPercent: CGFloat = 30.0
    private var bladeItems: [BladeItem] = []
    private var selectedBladeIndex: Int = 0

    private var pauseButton: SKSpriteNode!
    private var isGamePaused = false
    private var pauseOverlay: SKNode?
    
    private var isGameActive = true
    
    private var lastTouchPosition: CGPoint?
    
    override func didMove(to view: SKView) {
        backgroundColor = .cyan
        
        let background = SKSpriteNode(imageNamed: "gameBg")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = CGSize(width: frame.width, height: frame.height)
        background.zPosition = -1
        addChild(background)
        
        addScoreCell()
        
        addLevelLabel()
        
        createPauseButton()
        
        loadBladeItems()
        
        fruitCount = selectedLevel * 5
        bombCount = selectedLevel / 2
        
        initialFruitCount = fruitCount
                
        run(SKAction.repeat(SKAction.sequence([
            SKAction.run(spawnObject),
            SKAction.wait(forDuration: 1.0)
        ]), count: fruitCount + bombCount))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        handleTouchAt(point: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        handleDragAt(point: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    private func addScoreCell() {
        scoreBackground = SKSpriteNode(imageNamed: "score_cell")
        scoreBackground.position = CGPoint(x: frame.maxX - 60, y: frame.maxY - 100)
        scoreBackground.size = CGSize(width: 100, height: 60)
        scoreBackground.zPosition = 100
        addChild(scoreBackground)
        
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = .white
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: 0, y: 0)
        scoreLabel.zPosition = 101
        scoreBackground.addChild(scoreLabel)
    }
    
    private func addLevelLabel() {
        levelLabel = SKLabelNode(text: "\(selectedLevel) LEVEL")
        levelLabel.fontSize = 30
        levelLabel.fontColor = .white
        levelLabel.fontName = "AvenirNext-Bold"
        levelLabel.verticalAlignmentMode = .center
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        levelLabel.zPosition = 101
        addChild(levelLabel)
    }
    
    private func createPauseButton() {
        pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton.name = "pause"
        pauseButton.position = CGPoint(x: 40, y: frame.maxY - 100)
        pauseButton.zPosition = 100
        pauseButton.size = CGSize(width: 60, height: 60)
        
        addChild(pauseButton)
    }
    
    private func showPauseMenu() {
        isGamePaused = true
        
        let overlay = SKNode()
        overlay.name = "pauseOverlay"
        overlay.zPosition = 1000
        
        let background = SKShapeNode(rect: CGRect(origin: .zero, size: frame.size))
        background.fillColor = SKColor.black.withAlphaComponent(0.7)
        background.strokeColor = SKColor.clear
        background.position = CGPoint(x: frame.minX, y: frame.minY)
        overlay.addChild(background)
        
        let pauseLabel = SKLabelNode(text: "PAUSE")
        pauseLabel.fontName = "AvenirNext-Bold"
        pauseLabel.fontSize = 48
        pauseLabel.fontColor = SKColor.white
        pauseLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        overlay.addChild(pauseLabel)
        
        let resumeButton = createMenuButtonWithImage(name: "menu_play", imageName: "menu_play", position: CGPoint(x: frame.midX + 110, y: frame.midY))
        overlay.addChild(resumeButton)
        
        let restartButton = createMenuButtonWithImage(name: "menu_restart", imageName: "menu_restart", position: CGPoint(x: frame.midX, y: frame.midY))
        overlay.addChild(restartButton)
        
        let menuButton = createMenuButtonWithImage(name: "menu_back", imageName: "menu_back", position: CGPoint(x: frame.midX - 110, y: frame.midY))
        overlay.addChild(menuButton)
        
        addChild(overlay)
        pauseOverlay = overlay
        
        scene?.physicsWorld.speed = 0
        
        self.isPaused = true
    }
    
    private func hidePauseMenu() {
        isGamePaused = false
        pauseOverlay?.removeFromParent()
        pauseOverlay = nil
        
        scene?.physicsWorld.speed = 1
        self.isPaused = false
    }
    
    private func loadBladeItems() {
        bladeItems = BladeItem.bladeItems
        self.selectedBladeIndex = BladeItem.selectedBladeIndex
    }
    
    private func createMenuButtonWithImage(name: String, imageName: String, position: CGPoint) -> SKNode {
        let buttonNode = SKNode()
        buttonNode.name = name
        buttonNode.position = position
        
        let buttonSprite = SKSpriteNode(imageNamed: imageName)
        buttonSprite.size = CGSize(width: 100, height: 100)
        buttonNode.addChild(buttonSprite)
        
        let clickAction = SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.05)
        ])
        buttonNode.userData = NSMutableDictionary()
        buttonNode.userData?.setValue(clickAction, forKey: "clickAction")
        
        return buttonNode
    }
    
    func spawnObject() {
        guard isGameActive else { return }
        
        var isBomb = false
        if bombCount > 0 {
            let itemsCount = bombCount + fruitCount
            let randomValue = Int.random(in: 1...itemsCount)
            isBomb = randomValue <= bombCount
        }
        
        let fruitName = fruits.randomElement()!
        let object = SKSpriteNode(imageNamed: isBomb ? "bomb" : fruitName)
        object.name = isBomb ? "bomb" : fruitName
        object.position = CGPoint(x: CGFloat.random(in: frame.minX...frame.maxX), y: frame.minY)
        object.size = CGSize(width: fruitSize, height: fruitSize)
        
        let physicsBody = SKPhysicsBody(circleOfRadius: fruitRadius)
        physicsBody.velocity = CGVector(dx: 0, dy: Int.random(in: 1000...1500))
        physicsBody.angularVelocity = 1.0
        physicsBody.linearDamping = 0
        physicsBody.angularDamping = 0
        
        if isBomb {
            physicsBody.categoryBitMask = PhysicsCategory.bomb
            physicsBody.collisionBitMask = PhysicsCategory.none
        } else {
            physicsBody.categoryBitMask = PhysicsCategory.fruit
            physicsBody.collisionBitMask = PhysicsCategory.none
        }
        
        physicsBody.contactTestBitMask = PhysicsCategory.none
        physicsBody.restitution = 0.8
        physicsBody.allowsRotation = true
        object.physicsBody = physicsBody
        
        
        if isBomb { bombCount -= 1 } else { fruitCount -= 1 }
        
        let activeObjects = children.filter { fruits.contains($0.name ?? "") || $0.name == "bomb" }
        
        let wait = SKAction.wait(forDuration: 3.0)
        let remove = SKAction.removeFromParent()
        let checkCompletion = SKAction.run { [weak self] in
            self?.checkGameCompletion()
        }
        
        object.run(SKAction.sequence([wait, remove, checkCompletion]))
        addChild(object)
    }

    
    private func checkGameCompletion() {
        
        let activeObjects = children.filter { fruits.contains($0.name ?? "") || $0.name == "bomb" }

        if (fruitCount + bombCount) > 0 {
            return
        }
        
        if activeObjects.isEmpty {
            let cutPercent = (CGFloat(cutFruitCount) / CGFloat(initialFruitCount)) * 100.0
            
            if cutPercent >= minSuccessPercent {
                completeLevel()
            } else {
                gameOver(isFailed: true)
            }
        }
    }

    private func calculateStars() -> Int {
        
        let cutPercent = (CGFloat(cutFruitCount) / CGFloat(initialFruitCount)) * 100.0
        if cutPercent >= 90.0 {
            return 3
        } else if cutPercent >= 75.0 {
            return 2
        } else if cutPercent >= minSuccessPercent {
            return 1
        }
        
        return 0
    }
    
    private func handleTouchAt(point: CGPoint) {
        lastTouchPosition = point
        
        let touchedNodes = nodes(at: point)
        for node in touchedNodes {
            if node.name == "pause" {
                if isGamePaused {
                    hidePauseMenu()
                } else {
                    showPauseMenu()
                }
                return
            }
            
            if isGamePaused || !isGameActive {
                if let parentNode = node.parent, (parentNode.name == "menu_play" ||
                                                 parentNode.name == "menu_back" ||
                                                 parentNode.name == "next" ||
                                                 parentNode.name == "menu_restart") {
                    if let clickAction = parentNode.userData?.value(forKey: "clickAction") as? SKAction {
                        parentNode.run(clickAction)
                    }
                    
                    if parentNode.name == "menu_play" {
                        hidePauseMenu()
                        return
                    } else if parentNode.name == "menu_back" {
                        goToMainMenu()
                        return
                    } else if parentNode.name == "next" {
                        goToNextLevel()
                        return
                    } else if parentNode.name == "menu_restart" {
                        restartLevel()
                        return
                    }
                }
                
                if node.name == "menu_play" {
                    hidePauseMenu()
                    return
                } else if node.name == "menu_back" {
                    goToMainMenu()
                    return
                } else if node.name == "next" {
                    goToNextLevel()
                    return
                } else if node.name == "menu_restart" {
                    restartLevel()
                    return
                }
            }
        }
    }
    
    private func handleDragAt(point: CGPoint) {
        if isGamePaused || !isGameActive {
            return
        }
        
        if let previousLocation = lastTouchPosition {
            drawSwipeTrail(from: previousLocation, to: point)
            
            let nodes = nodes(at: point)
            for node in nodes {
                if node.name == "bomb" {
                    gameOver(isFailed: true)
                } else if let name = node.name, fruits.contains(name) {
                    score += 1
                    cutFruitCount += 1
                    performSlice(on: node as! SKSpriteNode, name: name)
                }
            }
        }
        
        lastTouchPosition = point
    }
    
    // MARK: - Swipe line
    
    func drawSwipeTrail(from startPoint: CGPoint, to endPoint: CGPoint) {
        let trail = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        trail.path = path
        trail.strokeColor = bladeItems[selectedBladeIndex].color
        trail.lineWidth = 4.0
        addChild(trail)
        
        let shadow = SKShapeNode(path: path)
        shadow.strokeColor = .black
        shadow.lineWidth = 6.0
        shadow.alpha = 0.3
        shadow.position = CGPoint(x: 2, y: -2)
        addChild(shadow)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        trail.run(SKAction.sequence([fadeOut, remove]))
        shadow.run(SKAction.sequence([fadeOut, remove]))
    }

    // MARK: - Slice
    
    func performSlice(on fruit: SKSpriteNode, name: String) {
        let fruitPosition = fruit.position
        fruit.removeFromParent()
        
        let leftHalf = SKSpriteNode(imageNamed: "\(name)1")
        leftHalf.position = fruitPosition
        leftHalf.size = CGSize(width: fruitSize, height: fruitSize / 2)
        
        let rightHalf = SKSpriteNode(imageNamed: "\(name)2")
        rightHalf.position = fruitPosition
        rightHalf.size = CGSize(width: fruitSize, height: fruitSize / 2)
        
        addChild(leftHalf)
        addChild(rightHalf)
        
        let leftPhysics = SKPhysicsBody(circleOfRadius: fruitRadius / 2)
        leftPhysics.categoryBitMask = PhysicsCategory.none
        leftPhysics.collisionBitMask = PhysicsCategory.none
        leftPhysics.velocity = CGVector(dx: -100, dy: 100)
        leftHalf.physicsBody = leftPhysics
        
        let rightPhysics = SKPhysicsBody(circleOfRadius: fruitRadius / 2)
        rightPhysics.categoryBitMask = PhysicsCategory.none
        rightPhysics.collisionBitMask = PhysicsCategory.none
        rightPhysics.velocity = CGVector(dx: 100, dy: 100)
        rightHalf.physicsBody = rightPhysics
        
        let moveLeft = SKAction.moveBy(x: -50, y: 50, duration: 0.5)
        let moveRight = SKAction.moveBy(x: 50, y: 50, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        leftHalf.run(SKAction.sequence([moveLeft, fadeOut, remove]))
        rightHalf.run(SKAction.sequence([moveRight, fadeOut, remove]))
        
        checkGameCompletion()
                
    }

// MARK: - Loose
    func gameOver(isFailed: Bool = false) {
        isGameActive = false
        
        scene?.physicsWorld.speed = 0
        
        let resultsOverlay = SKNode()
        resultsOverlay.name = "resultsOverlay"
        resultsOverlay.zPosition = 1000
        
        let background = SKShapeNode(rect: CGRect(origin: .zero, size: frame.size))
        background.fillColor = SKColor.black.withAlphaComponent(0.8)
        background.strokeColor = SKColor.clear
        background.position = CGPoint(x: frame.minX, y: frame.minY)
        resultsOverlay.addChild(background)
        
        let defeatImage = SKSpriteNode(imageNamed: "defeat")
        defeatImage.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        defeatImage.size = CGSize(width: frame.width - 50, height: 100)
        resultsOverlay.addChild(defeatImage)
                
        let completionLabel = SKLabelNode(text: "LEVEL \(selectedLevel)")
        completionLabel.fontName = "AvenirNext-Bold"
        completionLabel.fontSize = 40
        completionLabel.fontColor = SKColor.white
        completionLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        resultsOverlay.addChild(completionLabel)
        
        let restartButton = createMenuButtonWithImage(name: "menu_restart", imageName: "menu_restart", position: CGPoint(x: frame.midX + 55, y: frame.midY - 200))
        resultsOverlay.addChild(restartButton)
        
        let menuButton = createMenuButtonWithImage(name: "menu_back", imageName: "menu_back", position: CGPoint(x: frame.midX - 55, y: frame.midY - 200))
        resultsOverlay.addChild(menuButton)
        
        addChild(resultsOverlay)
        pauseOverlay = resultsOverlay
    }

// MARK: - CompleteLevel
    
    func completeLevel() {
        
        isGameActive = false
        
        let starsEarned = calculateStars()
        
        UserDefaults.standard.set(max(selectedLevel + 1, maxLevel), forKey: "maxLevel")
        
        let currentStars = UserDefaults.standard.integer(forKey: "totalStars")
        
        UserDefaults.standard.set(currentStars + cutFruitCount, forKey: "totalStars")
        
        UserDefaults.standard.set(starsEarned, forKey: "stars_level_\(selectedLevel)")

        let completionOverlay = SKNode()
        completionOverlay.name = "completionOverlay"
        completionOverlay.zPosition = 1000
        
        let background = SKShapeNode(rect: CGRect(origin: .zero, size: frame.size))
        background.fillColor = SKColor.black.withAlphaComponent(0.8)
        background.strokeColor = SKColor.clear
        background.position = CGPoint(x: frame.minX, y: frame.minY)
        completionOverlay.addChild(background)
        
        let victoryImage = SKSpriteNode(imageNamed: "victory")
        victoryImage.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        victoryImage.size = CGSize(width: frame.width - 50, height: 100)
        completionOverlay.addChild(victoryImage)
        
        let completionLabel = SKLabelNode(text: "LEVEL \(selectedLevel)")
        completionLabel.fontName = "AvenirNext-Bold"
        completionLabel.fontSize = 40
        completionLabel.fontColor = SKColor.white
        completionLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        completionOverlay.addChild(completionLabel)
                
        let starsNode = SKNode()
        starsNode.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        
        let starSpacing: CGFloat = 80
        
        for i in 0..<3 {
            let starX = CGFloat(i) * starSpacing - 80
            let starNode = SKNode()
            starNode.position = CGPoint(x: starX, y: 0)
            
            let starImageName = i < starsEarned ? "star" : "star_gray"
            let starSprite = SKSpriteNode(imageNamed: starImageName)
            starSprite.size = CGSize(width: 70, height: 70)
            
            if i < starsEarned {
                let scaleUp = SKAction.scale(to: 1.3, duration: 0.3)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
                let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
                let delay = SKAction.wait(forDuration: Double(i) * 0.2) 
                let delayedPulse = SKAction.sequence([delay, pulseSequence])
                starSprite.run(delayedPulse)
            }
            
            starNode.addChild(starSprite)
            starsNode.addChild(starNode)
        }
        
        completionOverlay.addChild(starsNode)
        
        let nextLevelButton = createMenuButtonWithImage(name: "next", imageName: "menu_play", position: CGPoint(x: frame.midX + 70, y: frame.midY - 200))
        completionOverlay.addChild(nextLevelButton)
        
        let menuButton = createMenuButtonWithImage(name: "menu_back", imageName: "menu_back", position: CGPoint(x: frame.midX - 70, y: frame.midY - 200))
        completionOverlay.addChild(menuButton)
        
        addChild(completionOverlay)
        pauseOverlay = completionOverlay
    }
    
    func restartLevel() {
        let newGameScene = GameScene(size: size)
        newGameScene.selectedLevel = selectedLevel
        newGameScene.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(newGameScene, transition: transition)
    }
    
    func goToNextLevel() {
        let newGameScene = GameScene(size: size)
        newGameScene.selectedLevel = selectedLevel + 1
        newGameScene.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(newGameScene, transition: transition)
    }
    
    func goToMainMenu() {
        let mainScene = MainMenuScene(size: size)
        mainScene.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(mainScene, transition: transition)
    }
}

@objc protocol SKTouch {
    @objc func location(in node: SKNode) -> CGPoint
    @objc optional func previousLocation(in node: SKNode) -> CGPoint
}
