//
//  MainMenuScene.swift
//  Fruit Slicer
//
//  Created by Мирсаит Сабирзянов on 12.03.2025.
//

import SpriteKit
import GameplayKit
import UIKit

class MainMenuScene: SKScene {
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "gameBg")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
        
        let logo = SKSpriteNode(imageNamed: "fruit_slicer")
        logo.position = CGPoint(x: frame.midX, y: frame.height * 0.7)
        logo.size = CGSize(width: frame.width * 0.8, height: frame.width * 0.6)
        logo.zPosition = 1
        addChild(logo)
        
//        let totalStars = UserDefaults.standard.integer(forKey: "totalStars")
//        let starsLabel = SKLabelNode(text: "\(totalStars) ★")
//        starsLabel.fontName = "AvenirNext-Bold"
//        starsLabel.fontSize = 36
//        starsLabel.fontColor = .white
//        starsLabel.position = CGPoint(x: frame.midX, y: frame.height * 0.85)
//        starsLabel.zPosition = 1
//        addChild(starsLabel)
        
        createTotalStarsDisplay()
        
        let playButton = SKSpriteNode(imageNamed: "play")
        playButton.name = "playButton"
        playButton.position = CGPoint(x: frame.midX, y: frame.height * 0.3)
        playButton.size = CGSize(width: frame.width * 0.8, height: 100)
        playButton.zPosition = 1
        addChild(playButton)
        
        
        let shopButton = SKSpriteNode(imageNamed: "shop")
        shopButton.name = "shopButton"
        shopButton.position = CGPoint(x: frame.midX, y: frame.height * 0.17)
        shopButton.size = CGSize(width: frame.width * 0.8, height: 100)
        shopButton.zPosition = 1
        addChild(shopButton)
    }
    
    private func createTotalStarsDisplay() {
        let totalStars = UserDefaults.standard.integer(forKey: "totalStars")

        let background = SKSpriteNode(imageNamed: "cell")
        background.size = CGSize(width: 150, height: 60)
        background.zPosition = 1000
        background.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if node.name == "playButton" {
                let scene = LevelSelectionScene(size: size)
                scene.scaleMode = .aspectFill
                view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
            } else if node.name == "shopButton" {
                let scene = ShopScene(size: size)
                scene.scaleMode = .aspectFill
                view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
            }
        }
    }
}
