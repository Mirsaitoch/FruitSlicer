//
//  BladeItem.swift
//  Fruit Slicer
//
//  Created by Мирсаит Сабирзянов on 15.03.2025.
//

import Foundation
import UIKit

struct BladeItem {
    let imageName: String
    let price: Int
    var isOwned: Bool
    var isSelected: Bool
    var color: UIColor
    
    static private let userDefaults = UserDefaults.standard
    
    static private let ownedBlades = userDefaults.array(forKey: "ownedBlades") as? [Int] ?? [0]
    
    static let selectedBladeIndex = userDefaults.integer(forKey: "selectedBladeIndex")
    
    static var bladeItems = [
        BladeItem(imageName: "white", price: 0, isOwned: ownedBlades.contains(0), isSelected: selectedBladeIndex == 0, color: .white),
        BladeItem(imageName: "black", price: 100, isOwned: ownedBlades.contains(1), isSelected: selectedBladeIndex == 1, color: .black),
        BladeItem(imageName: "red", price: 250, isOwned: ownedBlades.contains(2), isSelected: selectedBladeIndex == 2, color: .red),
        BladeItem(imageName: "green", price: 500, isOwned: ownedBlades.contains(3), isSelected: selectedBladeIndex == 3, color: .green),
        BladeItem(imageName: "blue", price: 1000, isOwned: ownedBlades.contains(4), isSelected: selectedBladeIndex == 4, color: .blue),
        BladeItem(imageName: "purple", price: 1000, isOwned: ownedBlades.contains(5), isSelected: selectedBladeIndex == 5, color: .purple)
    ]
}
