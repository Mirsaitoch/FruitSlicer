//
//  LevelSelectionScene.swift
//  Fruit Slicer
//
//  Created by Мирсаит Сабирзянов on 12.03.2025.
//

import Foundation
import SpriteKit
import GameplayKit

class LevelSelectionScene: SKScene {
    private var scrollNode = SKNode()
    private var lastTouchPosition: CGPoint?
    private var touchStartTime: TimeInterval = 0
    private var maxLevel: Int = {
        UserDefaults.standard.integer(forKey: "maxLevel").clamped(min: 1, max: 100)
    }()
    
    private var backButton: SKSpriteNode!
    private var playButton: SKSpriteNode!
    private var totalStarsNode: SKNode!
    private var isDragging = false
    private var touchMoved = false
    private var currentSelectedLevel = 1
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupScrollContainer()
        createLevels()
        createBackButton()
        createPlayButton()
        createTotalStarsDisplay()
        currentSelectedLevel = maxLevel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.scrollToLevel(self?.maxLevel ?? 1, animated: true)
        }
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "gameBg")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size
        background.zPosition = -10
        addChild(background)
    }
    
    private func setupScrollContainer() {
        scrollNode.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(scrollNode)
    }
    
    private func createLevels() {
        let levelSpacing: CGFloat = 40
        let levelWidth: CGFloat = 200
        var totalWidth: CGFloat = 0
        
        for level in 1...50 {
            let levelNode = createLevelCard(number: level, isLocked: level > maxLevel)
            
            levelNode.position = CGPoint(x: totalWidth, y: 0)
            scrollNode.addChild(levelNode)
            
            totalWidth += levelWidth + levelSpacing
        }
        
        scrollNode.position.x = frame.width / 2
    }
    
    private func createLevelCard(number: Int, isLocked: Bool) -> SKNode {
        let cardSize = CGSize(width: 200, height: 200)
        let card = SKNode()
        
        let background = SKSpriteNode(imageNamed: isLocked ? "lock_level_cell" : "level_cell")
        background.size = cardSize
        background.zPosition = 0
        card.addChild(background)
        
        let numberLabel = SKLabelNode(text: "\(number)")
        numberLabel.fontName = "AvenirNext-Bold"
        numberLabel.fontSize = 50
        numberLabel.fontColor = SKColor.white
        numberLabel.position = CGPoint(x: 0, y: 20)
        numberLabel.zPosition = 5
        numberLabel.verticalAlignmentMode = .center
        card.addChild(numberLabel)
        
        if isLocked {
            let lockIcon = SKSpriteNode(imageNamed: "lock")
            lockIcon.size = CGSize(width: 50, height: 50)
            lockIcon.position = CGPoint(x: 0, y: -40)
            lockIcon.zPosition = 10
            card.addChild(lockIcon)
        } else if number <= maxLevel {
            let starsEarned = getStarsForLevel(number)
            let starsNode = SKNode()
            starsNode.position = CGPoint(x: 0, y: -60)
            starsNode.zPosition = 5
            
            let starSpacing: CGFloat = 35
            let startX = -starSpacing
            
            for i in 0..<3 {
                let starX = startX + CGFloat(i) * starSpacing
                let starImageName = i < starsEarned ? "star" : "star_gray"
                let starSprite = SKSpriteNode(imageNamed: starImageName)
                starSprite.size = CGSize(width: 40, height: 40)
                starSprite.position = CGPoint(x: starX, y: 0)
                starsNode.addChild(starSprite)
            }
            
            card.addChild(starsNode)
        }
        
      
        if !isLocked {
            let pulseAction = SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 1.0),
                SKAction.scale(to: 1.0, duration: 1.0)
            ])
            card.run(SKAction.repeatForever(pulseAction))
        }
        
        card.name = "level_\(number)"
        
        return card
    }
    
    private func getStarsForLevel(_ level: Int) -> Int {
        return UserDefaults.standard.integer(forKey: "stars_level_\(level)")
    }
    
    private func createBackButton() {
        backButton = SKSpriteNode(imageNamed: "back")
        backButton.name = "back_button"
        backButton.position = CGPoint(x: 60, y: frame.maxY - 100)
        backButton.zPosition = 100
        backButton.size = CGSize(width: 80, height: 60)
        
        addChild(backButton)
    }
    
    private func createPlayButton() {
        playButton = SKSpriteNode(imageNamed: "play")
        playButton.name = "play_button"
        playButton.position = CGPoint(x: frame.midX, y: 100)
        playButton.zPosition = 100
        playButton.size = CGSize(width: 317, height: 100)
        
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        playButton.run(SKAction.repeatForever(pulseAction))
        
        addChild(playButton)
    }
    
    
    private func createTotalStarsDisplay() {
        let totalStars = UserDefaults.standard.integer(forKey: "totalStars")

        let background = SKSpriteNode(imageNamed: "cell")
        background.size = CGSize(width: 150, height: 60)
        background.zPosition = 1000
        background.position = CGPoint(x: frame.maxX - 80, y: frame.maxY - 100)
        
        let starIcon = SKSpriteNode(imageNamed: "star")
        starIcon.size = CGSize(width: 30, height: 30)
        starIcon.position = CGPoint(x: 25, y: 0)
        background.addChild(starIcon)
        
        let starsLabel = SKLabelNode(text: "\(totalStars)")
        starsLabel.fontName = "AvenirNext-Bold"
        starsLabel.fontSize = 30
        starsLabel.fontColor = SKColor.white
        starsLabel.zPosition = 1000
        starsLabel.position = CGPoint(x: -20, y: 0)
        starsLabel.verticalAlignmentMode = .center
        background.addChild(starsLabel)
        
        addChild(background)
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchPosition = touch.location(in: self)
        touchStartTime = touch.timestamp
        touchMoved = false
        isDragging = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let lastPosition = lastTouchPosition else { return }
        
        let currentPosition = touch.location(in: self)
        let deltaX = currentPosition.x - lastPosition.x
        
        if abs(deltaX) > 10 {
            touchMoved = true
            isDragging = true
        }
        
        scrollNode.position.x += deltaX * 1.5
        
        lastTouchPosition = currentPosition
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            snapToNearestLevel()
            lastTouchPosition = nil
            return
        }
        
        if !touchMoved {
            let location = touch.location(in: self)
            handleTap(at: location)
        }
        
        handleScrollEnd(with: touch)
        
        lastTouchPosition = nil
        isDragging = false
        touchMoved = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        snapToNearestLevel()
        lastTouchPosition = nil
        isDragging = false
        touchMoved = false
    }
    
    private func handleTap(at location: CGPoint) {
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if node.name == "back_button" {
                returnToMainMenu()
                return
            } else if node.name == "play_button" {
                if currentSelectedLevel <= maxLevel {
                    selectLevel(currentSelectedLevel)
                }
                return
            }
        }
    }
    
    private func handleScrollEnd(with touch: UITouch) {
        guard let startPos = lastTouchPosition else {
            snapToNearestLevel()
            return
        }
        
        let endPos = touch.location(in: self)
        let distance = endPos.x - startPos.x
        let touchDuration = touch.timestamp - touchStartTime
        
        if touchDuration > 0 && isDragging {
            let velocity = distance / CGFloat(touchDuration)
            
            if abs(velocity) > 200 {
                let inertiaDistance = velocity * 0.3
                
                scrollNode.removeAllActions()
                
                let inertiaAction = SKAction.moveBy(x: inertiaDistance, y: 0, duration: 0.5)
                scrollNode.run(inertiaAction) { [weak self] in
                    self?.snapToNearestLevel()
                }
            } else {
                snapToNearestLevel()
            }
        } else {
            snapToNearestLevel()
        }
    }
    
    private func selectLevel(_ level: Int) {
        print("Выбран уровень: \(level)")
        
        UserDefaults.standard.set(level, forKey: "selectedLevel")
        UserDefaults.standard.synchronize()
        
        transitionToGameScene()
    }
    
    private func transitionToGameScene() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 1.0)
        view?.presentScene(gameScene, transition: transition)
    }
    
    private func scrollToLevel(_ level: Int, animated: Bool = true) {
        let cardWidth: CGFloat = 240
        let levelIndex = level - 1
        
        let targetX = frame.midX - (cardWidth * CGFloat(levelIndex))
        
        if animated {
            scrollNode.removeAllActions()
            
            let moveAction = SKAction.moveTo(x: targetX, duration: 0.5)
            scrollNode.run(moveAction) { [weak self] in
                self?.updateLevelsYPosition()
            }
        } else {
            scrollNode.position.x = targetX
            updateLevelsYPosition()
        }
    }
    
    private func snapToNearestLevel() {
        let cardWidth: CGFloat = 240
        let currentPosition = scrollNode.position.x
        let normalizedPosition = currentPosition - frame.midX + 1
        let targetIndex = round(-normalizedPosition / cardWidth)
        let targetX = frame.midX - (targetIndex * cardWidth)
        
        scrollNode.removeAllActions()
        let moveAction = SKAction.moveTo(x: targetX, duration: 0.2)
        scrollNode.run(moveAction) {
            self.currentSelectedLevel = Int(targetIndex) + 1
            self.currentSelectedLevel = max(1, min(self.currentSelectedLevel, 50))
            
            print(self.currentSelectedLevel)
            self.updatePlayButtonState()
        }
    }
    
    // MARK: - Update
    
    private func updatePlayButtonState() {
        print(currentSelectedLevel, maxLevel)
        if currentSelectedLevel <= maxLevel {
            playButton.alpha = 1.0
            playButton.colorBlendFactor = 0.0
        } else {
            playButton.alpha = 0.0
        }
    }
    
    private func updateLevelsYPosition() {
        let cardWidth: CGFloat = 240
        let currentPosition = scrollNode.position.x
        let centerX = frame.midX - currentPosition
        let maxOffset: CGFloat = 80.0
        
        for node in scrollNode.children {
            let distanceFromCenter = abs(node.position.x - centerX)
            
            let yOffset = maxOffset * pow(distanceFromCenter / (cardWidth * 2), 2)
            
            let moveAction = SKAction.moveTo(y: -yOffset, duration: 0.2)
            node.run(moveAction)
            
            let scale = 1.0 - (distanceFromCenter / (cardWidth * 4)).clamped(min: 0, max: 0.3)
            node.run(SKAction.scale(to: scale, duration: 0.2))
            
            if let backgroundNode = node.childNode(withName: "background") {
                let fadeAction = SKAction.fadeAlpha(to: scale, duration: 0.2)
                backgroundNode.run(fadeAction)
            }
        }
        
        updatePlayButtonState()
    }
    
    override func update(_ currentTime: TimeInterval) {
        let scrollableWidth = scrollNode.calculateAccumulatedFrame().width
        let minX = frame.width / 2 - scrollableWidth + 200
        let maxX = frame.width / 2
        
        if scrollableWidth > frame.width {
            scrollNode.position.x = scrollNode.position.x.clamped(min: minX, max: maxX)
        }
        
        updateLevelsYPosition()
    }
    
    // MARK: - Navigation
    
    private func returnToMainMenu() {
        let mainScene = MainMenuScene(size: size)
        mainScene.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(mainScene, transition: transition)
    }
}

extension CGFloat {
    func clamped(min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.max(min, Swift.min(max, self))
    }
}

extension Int {
    func clamped(min: Int, max: Int) -> Int {
        return Swift.max(min, Swift.min(max, self))
    }
}
