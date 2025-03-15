//
//  ShopScene.swift
//  Fruit Slicer
//
//  Created by Мирсаит Сабирзянов on 15.03.2025.
//

import SpriteKit
import GameplayKit

class ShopScene: SKScene {
    
    private var scrollNode = SKNode()
    private var lastTouchPosition: CGPoint?
    private var touchStartTime: TimeInterval = 0
    private var touchMoved = false
    private var isDragging = false
    
    private var totalStarsDisplay: SKNode!
    private var selectedBladeIndex: Int = 0
    private var currentViewingIndex: Int = 0
    private var bladeItems: [BladeItem] = []
    private var backButton: SKSpriteNode!
    private var buyButton: SKSpriteNode!
    
    private let bladeWidth: CGFloat = 200
    private let bladeSpacing: CGFloat = 80
    private let cardWidth: CGFloat = 280
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "gameBg")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
        
        loadBladeItems()
        
        scrollNode = SKNode()
        scrollNode.position = CGPoint(x: frame.midX, y: frame.midY)
        scrollNode.zPosition = 1
        addChild(scrollNode)
        
        createBladeCarousel()
        
        createTotalStarsDisplay()
        
        createBackButton()
        
        createBuyButton()
        
        scrollToIndex(0, animated: false)
        
        updateButtonState()
    }
    
    private func loadBladeItems() {
        let userDefaults = UserDefaults.standard
        let ownedBlades = userDefaults.array(forKey: "ownedBlades") as? [Int] ?? [0]
        let selectedBladeIndex = userDefaults.integer(forKey: "selectedBladeIndex")
        
        bladeItems = [
            BladeItem(imageName: "white", price: 0, isOwned: ownedBlades.contains(0), isSelected: selectedBladeIndex == 0),
            BladeItem(imageName: "black", price: 100, isOwned: ownedBlades.contains(1), isSelected: selectedBladeIndex == 1),
            BladeItem(imageName: "red", price: 250, isOwned: ownedBlades.contains(2), isSelected: selectedBladeIndex == 2),
            BladeItem(imageName: "green", price: 500, isOwned: ownedBlades.contains(3), isSelected: selectedBladeIndex == 3),
            BladeItem(imageName: "blue", price: 1000, isOwned: ownedBlades.contains(4), isSelected: selectedBladeIndex == 4),
            BladeItem(imageName: "purple", price: 1000, isOwned: ownedBlades.contains(5), isSelected: selectedBladeIndex == 5)
        ]
        
        self.selectedBladeIndex = selectedBladeIndex
        self.currentViewingIndex = 0
    }
    
    private func createBladeCarousel() {
        var totalWidth: CGFloat = 0
        
        totalWidth = frame.width / 2 - bladeWidth / 2
        
        for (index, blade) in bladeItems.enumerated() {
            let bladeNode = createBladeCard(index: index, blade: blade)
            bladeNode.position = CGPoint(x: totalWidth + bladeWidth / 2, y: 0)
            scrollNode.addChild(bladeNode)
            
            totalWidth += cardWidth
        }
        
        totalWidth += frame.width / 2 - bladeWidth / 2 - cardWidth
    }
    
    private func createBladeCard(index: Int, blade: BladeItem) -> SKNode {
        let card = SKNode()
        let bladeImage = SKSpriteNode(imageNamed: blade.imageName)
        bladeImage.size = CGSize(width: 250, height: 250)
        bladeImage.position = CGPoint(x: 0, y: 40)
        bladeImage.zPosition = 1
        card.addChild(bladeImage)
        
        
        let statusLabel = SKLabelNode()
        if blade.isOwned {
            statusLabel.text = blade.isSelected ? "Selected" : "Available"
            statusLabel.fontColor = blade.isSelected ? .green : .white
        } else {
            statusLabel.text = "You can buy"
            statusLabel.fontColor = .red
        }
        statusLabel.fontName = "AvenirNext-Bold"
        statusLabel.fontSize = 20
        statusLabel.position = CGPoint(x: 0, y: -50)
        statusLabel.zPosition = 1000
        card.addChild(statusLabel)
        
        if blade.isOwned {
            let pulseAction = SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 1.0),
                SKAction.scale(to: 1.0, duration: 1.0)
            ])
            card.run(SKAction.repeatForever(pulseAction))
        }
        
        card.name = "blade_\(index)"
        
        return card
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
    
    private func createBackButton() {
        backButton = SKSpriteNode(imageNamed: "back")
        backButton.name = "back_button"
        backButton.position = CGPoint(x: 60, y: frame.maxY - 100)
        backButton.zPosition = 100
        backButton.size = CGSize(width: 80, height: 60)
        
        addChild(backButton)
    }
    
    private func createBuyButton() {
        buyButton = SKSpriteNode(imageNamed: "green_button")
        buyButton.size = CGSize(width: frame.width * 0.8, height: 70)
        buyButton.position = CGPoint(x: frame.midX, y: frame.height * 0.15)
        buyButton.zPosition = 10
        buyButton.name = "buyButton"
        
        let buyLabel = SKLabelNode(text: "Buy")
        buyLabel.fontName = "AvenirNext-Bold"
        buyLabel.fontSize = 30
        buyLabel.fontColor = .white
        buyLabel.verticalAlignmentMode = .center
        buyLabel.zPosition = 1
        buyLabel.name = "buyLabel"
        buyButton.addChild(buyLabel)
        
        addChild(buyButton)
        
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        buyButton.run(SKAction.repeatForever(pulseAction))
    }
    
    private func updateTotalStarsDisplay() {
        let totalStars = UserDefaults.standard.integer(forKey: "totalStars")
        if let starsLabel = totalStarsDisplay.children.first(where: { $0 is SKLabelNode }) as? SKLabelNode {
            starsLabel.text = "\(totalStars)"
        }
    }
    
    private func updateButtonState() {
        let blade = bladeItems[currentViewingIndex]
        
        if blade.isOwned {
            if blade.isSelected {
                buyButton.isHidden = true
            } else {
                buyButton.isHidden = false
                buyButton.texture = SKTexture(imageNamed: "green_button")
                if let buyLabel = buyButton.childNode(withName: "buyLabel") as? SKLabelNode {
                    buyLabel.text = "SELECT"
                }
            }
        } else {
            buyButton.isHidden = false
            buyButton.texture = SKTexture(imageNamed: "green_button")
            if let buyLabel = buyButton.childNode(withName: "buyLabel") as? SKLabelNode {
                buyLabel.text = "BUY FOR \(blade.price) stars"
            }
        }
    }
    
    private func buyOrSelectBlade() {
        let blade = bladeItems[currentViewingIndex]
        
        if blade.isOwned {
            selectBlade(at: currentViewingIndex)
        } else {
            buyBlade(at: currentViewingIndex)
        }
    }
    
    private func buyBlade(at index: Int) {
        let blade = bladeItems[index]
        let totalStars = UserDefaults.standard.integer(forKey: "totalStars")
        
        if totalStars >= blade.price {
            UserDefaults.standard.set(totalStars - blade.price, forKey: "totalStars")
            
            var ownedBlades = UserDefaults.standard.array(forKey: "ownedBlades") as? [Int] ?? [0]
            ownedBlades.append(index)
            UserDefaults.standard.set(ownedBlades, forKey: "ownedBlades")
            
            bladeItems[index].isOwned = true
            
            updateCarousel()
            
            updateTotalStarsDisplay()
            updateButtonState()
        } else {
            let notEnoughStarsLabel = SKLabelNode(text: "Not enough stars!")
            notEnoughStarsLabel.fontName = "AvenirNext-Bold"
            notEnoughStarsLabel.fontSize = 30
            notEnoughStarsLabel.fontColor = .red
            notEnoughStarsLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
            notEnoughStarsLabel.zPosition = 100
            addChild(notEnoughStarsLabel)
            
            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([SKAction.wait(forDuration: 1.0), fadeOut, remove])
            notEnoughStarsLabel.run(sequence)
        }
    }
    
    private func selectBlade(at index: Int) {
        UserDefaults.standard.set(index, forKey: "selectedBladeIndex")
        
        for i in 0..<bladeItems.count {
            bladeItems[i].isSelected = (i == index)
        }
        
        updateCarousel()
        updateButtonState()
    }
    
    private func updateCarousel() {
        scrollNode.removeAllChildren()
        createBladeCarousel()
        scrollToIndex(currentViewingIndex, animated: false)
    }
    
    private func scrollToIndex(_ index: Int, animated: Bool = true) {
        let indexOffset = CGFloat(index)
        
        let targetX = -indexOffset * cardWidth
        
        if animated {
            scrollNode.removeAllActions()
            
            let moveAction = SKAction.moveTo(x: targetX, duration: 0.3)
            moveAction.timingMode = .easeInEaseOut
            scrollNode.run(moveAction)
        } else {
            scrollNode.position.x = targetX
        }
        
        currentViewingIndex = index
        updateButtonState()
    }
    
    private func snapToNearestBlade() {
        let currentPosition = scrollNode.position.x
        
        let targetIndex = round(-currentPosition / cardWidth)
        let clampedIndex = max(0, min(targetIndex, CGFloat(bladeItems.count - 1)))
        
        scrollToIndex(Int(clampedIndex))
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
        
        if abs(deltaX) > 5 {
            touchMoved = true
            isDragging = true
        }
        
        scrollNode.position.x += deltaX
        lastTouchPosition = currentPosition
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            snapToNearestBlade()
            lastTouchPosition = nil
            return
        }
        
        if !touchMoved {
            let location = touch.location(in: self)
            handleTap(at: location)
        } else {
            handleScrollEnd(with: touch)
        }
        
        lastTouchPosition = nil
        isDragging = false
        touchMoved = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        snapToNearestBlade()
        lastTouchPosition = nil
        isDragging = false
        touchMoved = false
    }
    
    private func handleTap(at location: CGPoint) {
        if backButton.contains(location) {
            let scene = MainMenuScene(size: size)
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
            return
        }
        
        if !buyButton.isHidden && buyButton.contains(location) {
            buyOrSelectBlade()
            return
        }
    }
    
    private func handleScrollEnd(with touch: UITouch) {
        guard let startPos = lastTouchPosition else {
            snapToNearestBlade()
            return
        }
        
        let endPos = touch.location(in: self)
        let distance = endPos.x - startPos.x
        let touchDuration = touch.timestamp - touchStartTime
        
        if touchDuration > 0 && isDragging {
            let velocity = distance / CGFloat(touchDuration)
            
            if abs(velocity) > 100 {
                let inertiaDistance = velocity * 0.5
                scrollNode.removeAllActions()
                
                let inertiaAction = SKAction.moveBy(x: inertiaDistance, y: 0, duration: 0.8)
                inertiaAction.timingMode = .easeOut
                scrollNode.run(inertiaAction) { [weak self] in
                    self?.snapToNearestBlade()
                }
            } else {
                snapToNearestBlade()
            }
        } else {
            snapToNearestBlade()
        }
    }
}
