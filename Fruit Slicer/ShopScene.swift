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
    
    // Константы для карусели
    private let bladeWidth: CGFloat = 200
    private let bladeSpacing: CGFloat = 80 // Увеличено расстояние между клинками
    private let cardWidth: CGFloat = 280 // bladeWidth + bladeSpacing
    
    // Структура для хранения информации о клинке
    struct BladeItem {
        let imageName: String
        let price: Int
        var isOwned: Bool
        var isSelected: Bool
    }
    
    override func didMove(to view: SKView) {
        // Создаем фон
        let background = SKSpriteNode(imageNamed: "gameBg")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
        
        // Создаем заголовок магазина
        let titleLabel = SKLabelNode(text: "МАГАЗИН КЛИНКОВ")
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.fontSize = 40
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: frame.midX, y: frame.height * 0.85)
        titleLabel.zPosition = 1
        addChild(titleLabel)
        
        // Загружаем данные о клинках
        loadBladeItems()
        
        // Создаем контейнер для скроллинга
        scrollNode = SKNode()
        scrollNode.position = CGPoint(x: frame.midX, y: frame.midY)
        scrollNode.zPosition = 1
        addChild(scrollNode)
        
        // Создаем карусель клинков
        createBladeCarousel()
        
        // Создаем отображение общего количества звезд
        createTotalStarsDisplay()
        
        // Создаем кнопку возврата
        createBackButton()
        
        // Создаем кнопку покупки/выбора
        createBuyButton()
        
        // Устанавливаем первый элемент в фокус
        scrollToIndex(0, animated: false)
        
        // Обновляем состояние кнопки
        updateButtonState()
    }
    
    private func loadBladeItems() {
        // Получаем данные о купленных и выбранном клинке
        let userDefaults = UserDefaults.standard
        let ownedBlades = userDefaults.array(forKey: "ownedBlades") as? [Int] ?? [0] // По умолчанию первый клинок доступен
        let selectedBladeIndex = userDefaults.integer(forKey: "selectedBladeIndex")
        
        // Заполняем клинки из доступных изображений
        bladeItems = [
            BladeItem(imageName: "blade_white", price: 0, isOwned: ownedBlades.contains(0), isSelected: selectedBladeIndex == 0),
            BladeItem(imageName: "blade_blue", price: 100, isOwned: ownedBlades.contains(1), isSelected: selectedBladeIndex == 1),
            BladeItem(imageName: "blade_red", price: 250, isOwned: ownedBlades.contains(2), isSelected: selectedBladeIndex == 2),
            BladeItem(imageName: "blade_green", price: 500, isOwned: ownedBlades.contains(3), isSelected: selectedBladeIndex == 3),
            BladeItem(imageName: "blade_gold", price: 1000, isOwned: ownedBlades.contains(4), isSelected: selectedBladeIndex == 4)
        ]
        
        // Обновляем выбранный клинок
        self.selectedBladeIndex = selectedBladeIndex
        self.currentViewingIndex = 0
    }
    
    private func createBladeCarousel() {
        var totalWidth: CGFloat = 0
        
        // Сначала добавляем пустое пространство слева, чтобы первый элемент мог центрироваться
        totalWidth = frame.width / 2 - bladeWidth / 2
        
        for (index, blade) in bladeItems.enumerated() {
            let bladeNode = createBladeCard(index: index, blade: blade)
            bladeNode.position = CGPoint(x: totalWidth + bladeWidth / 2, y: 0)
            scrollNode.addChild(bladeNode)
            
            totalWidth += cardWidth
        }
        
        // Добавляем пустое пространство справа, чтобы последний элемент мог центрироваться
        totalWidth += frame.width / 2 - bladeWidth / 2 - cardWidth
    }
    
    private func createBladeCard(index: Int, blade: BladeItem) -> SKNode {
        let cardSize = CGSize(width: bladeWidth, height: 280)
        let card = SKNode()
        
        // Фон карточки клинка
        let background = SKSpriteNode(imageNamed: "cell")
        background.size = cardSize
        background.zPosition = 0
        card.addChild(background)
        
        // Изображение клинка
        let bladeImage = SKSpriteNode(imageNamed: blade.imageName)
        bladeImage.size = CGSize(width: cardSize.width * 0.8, height: cardSize.height * 0.5)
        bladeImage.position = CGPoint(x: 0, y: 40)
        bladeImage.zPosition = 1
        card.addChild(bladeImage)
        
        // Цена клинка
        let priceLabel = SKLabelNode(text: "\(blade.price) ★")
        priceLabel.fontName = "AvenirNext-Bold"
        priceLabel.fontSize = 24
        priceLabel.fontColor = .white
        priceLabel.position = CGPoint(x: 0, y: -30)
        priceLabel.zPosition = 1
        card.addChild(priceLabel)
        
        // Статус клинка
        let statusLabel = SKLabelNode()
        if blade.isOwned {
            statusLabel.text = blade.isSelected ? "ВЫБРАНО" : "ДОСТУПНО"
            statusLabel.fontColor = blade.isSelected ? .green : .white
        } else {
            statusLabel.text = "НЕ КУПЛЕНО"
            statusLabel.fontColor = .red
        }
        statusLabel.fontName = "AvenirNext-Bold"
        statusLabel.fontSize = 20
        statusLabel.position = CGPoint(x: 0, y: -70)
        statusLabel.zPosition = 1
        card.addChild(statusLabel)
        
        // Анимация для карточки
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
        background.zPosition = 10
        background.position = CGPoint(x: frame.maxX - 100, y: frame.maxY - 50)
        
        let starIcon = SKSpriteNode(imageNamed: "star")
        starIcon.size = CGSize(width: 30, height: 30)
        starIcon.position = CGPoint(x: 25, y: 0)
        background.addChild(starIcon)
        
        let starsLabel = SKLabelNode(text: "\(totalStars)")
        starsLabel.fontName = "AvenirNext-Bold"
        starsLabel.fontSize = 30
        starsLabel.fontColor = SKColor.white
        starsLabel.position = CGPoint(x: -20, y: 0)
        starsLabel.verticalAlignmentMode = .center
        background.addChild(starsLabel)
        
        totalStarsDisplay = background
        addChild(totalStarsDisplay)
    }
    
    private func createBackButton() {
        backButton = SKSpriteNode(imageNamed: "back_button")
        backButton.size = CGSize(width: 60, height: 60)
        backButton.position = CGPoint(x: 50, y: frame.maxY - 50)
        backButton.zPosition = 10
        backButton.name = "backButton"
        addChild(backButton)
    }
    
    private func createBuyButton() {
        buyButton = SKSpriteNode(imageNamed: "blue_button")
        buyButton.size = CGSize(width: frame.width * 0.8, height: 70)
        buyButton.position = CGPoint(x: frame.midX, y: frame.height * 0.15)
        buyButton.zPosition = 10
        buyButton.name = "buyButton"
        
        let buyLabel = SKLabelNode(text: "КУПИТЬ")
        buyLabel.fontName = "AvenirNext-Bold"
        buyLabel.fontSize = 30
        buyLabel.fontColor = .white
        buyLabel.position = CGPoint(x: 0, y: -10)
        buyLabel.verticalAlignmentMode = .center
        buyLabel.zPosition = 1
        buyLabel.name = "buyLabel"
        buyButton.addChild(buyLabel)
        
        addChild(buyButton)
        
        // Добавляем пульсацию
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        buyButton.run(SKAction.repeatForever(pulseAction))
    }
    
    private func updateTotalStarsDisplay() {
        // Обновляем отображение количества звезд
        let totalStars = UserDefaults.standard.integer(forKey: "totalStars")
        if let starsLabel = totalStarsDisplay.children.first(where: { $0 is SKLabelNode }) as? SKLabelNode {
            starsLabel.text = "\(totalStars)"
        }
    }
    
    private func updateButtonState() {
        let blade = bladeItems[currentViewingIndex]
        
        if blade.isOwned {
            if blade.isSelected {
                // Если клинок уже выбран, скрываем кнопку
                buyButton.isHidden = true
            } else {
                // Если клинок куплен, но не выбран, показываем кнопку выбора
                buyButton.isHidden = false
                buyButton.texture = SKTexture(imageNamed: "green_button")
                if let buyLabel = buyButton.childNode(withName: "buyLabel") as? SKLabelNode {
                    buyLabel.text = "ВЫБРАТЬ"
                }
            }
        } else {
            // Если клинок не куплен, показываем кнопку покупки
            buyButton.isHidden = false
            buyButton.texture = SKTexture(imageNamed: "blue_button")
            if let buyLabel = buyButton.childNode(withName: "buyLabel") as? SKLabelNode {
                buyLabel.text = "КУПИТЬ ЗА \(blade.price) ★"
            }
        }
    }
    
    private func buyOrSelectBlade() {
        let blade = bladeItems[currentViewingIndex]
        
        if blade.isOwned {
            // Если клинок уже куплен, выбираем его
            selectBlade(at: currentViewingIndex)
        } else {
            // Если клинок не куплен, пытаемся купить
            buyBlade(at: currentViewingIndex)
        }
    }
    
    private func buyBlade(at index: Int) {
        let blade = bladeItems[index]
        let totalStars = UserDefaults.standard.integer(forKey: "totalStars")
        
        // Проверяем, достаточно ли у игрока звезд
        if totalStars >= blade.price {
            // Вычитаем стоимость клинка
            UserDefaults.standard.set(totalStars - blade.price, forKey: "totalStars")
            
            // Обновляем список купленных клинков
            var ownedBlades = UserDefaults.standard.array(forKey: "ownedBlades") as? [Int] ?? [0]
            ownedBlades.append(index)
            UserDefaults.standard.set(ownedBlades, forKey: "ownedBlades")
            
            // Обновляем данные в памяти
            bladeItems[index].isOwned = true
            
            // Обновляем карусель
            updateCarousel()
            
            // Обновляем отображение звезд
            updateTotalStarsDisplay()
            
            // Обновляем состояние кнопки
            updateButtonState()
        } else {
            // Показываем сообщение о недостатке звезд
            let notEnoughStarsLabel = SKLabelNode(text: "Недостаточно звезд!")
            notEnoughStarsLabel.fontName = "AvenirNext-Bold"
            notEnoughStarsLabel.fontSize = 30
            notEnoughStarsLabel.fontColor = .red
            notEnoughStarsLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
            notEnoughStarsLabel.zPosition = 100
            addChild(notEnoughStarsLabel)
            
            // Удаляем сообщение через 2 секунды
            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([SKAction.wait(forDuration: 1.0), fadeOut, remove])
            notEnoughStarsLabel.run(sequence)
        }
    }
    
    private func selectBlade(at index: Int) {
        // Сохраняем выбранный клинок
        UserDefaults.standard.set(index, forKey: "selectedBladeIndex")
        
        // Обновляем данные в памяти
        for i in 0..<bladeItems.count {
            bladeItems[i].isSelected = (i == index)
        }
        
        // Обновляем карусель
        updateCarousel()
        
        // Обновляем состояние кнопки
        updateButtonState()
    }
    
    private func updateCarousel() {
        // Удаляем текущую карусель
        scrollNode.removeAllChildren()
        
        // Создаем новую карусель
        createBladeCarousel()
        
        // Выполняем скролл к текущему просматриваемому элементу
        scrollToIndex(currentViewingIndex, animated: false)
    }
    
    private func scrollToIndex(_ index: Int, animated: Bool = true) {
        let indexOffset = CGFloat(index)
        
        // Вычисляем позицию, учитывая центрирование элемента
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
        
        // Вычисляем ближайший индекс
        let targetIndex = round(-currentPosition / cardWidth)
        let clampedIndex = max(0, min(targetIndex, CGFloat(bladeItems.count - 1)))
        
        // Прокручиваем к этому индексу
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
        
        if abs(deltaX) > 5 { // Уменьшенный порог для определения движения
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
        // Проверяем нажатие на кнопку возврата
        if backButton.contains(location) {
            let scene = MainMenuScene(size: size)
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
            return
        }
        
        // Проверяем нажатие на кнопку покупки
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
            
            if abs(velocity) > 100 { // Снижен порог скорости для более плавного движения
                let inertiaDistance = velocity * 0.5 // Больший коэффициент для более длинного движения
                
                scrollNode.removeAllActions()
                
                let inertiaAction = SKAction.moveBy(x: inertiaDistance, y: 0, duration: 0.8) // Более длительная анимация инерции
                inertiaAction.timingMode = .easeOut // Плавное замедление
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