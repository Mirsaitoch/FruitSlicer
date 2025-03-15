//
//  GameViewController.swift
//  Fruit Slicer
//
//  Created by Мирсаит Сабирзянов on 12.03.2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.register(defaults: [
            "currentLevel": 1
        ])
        if let view = self.view as? SKView {
            let scene = MainMenuScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            
        }
    }
}
