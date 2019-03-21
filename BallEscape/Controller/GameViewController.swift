//
//  GameViewController.swift
//  BallEscape
//
//  Created by Liqiu Li on 2019/3/21.
//  Copyright © 2019年 xxx. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    // MARK: - enum
    fileprivate enum ScreenEdge: Int {
        case top = 0
        case right = 1
        case bottom = 2
        case left = 3
    }
    
    fileprivate enum GameState {
        case ready
        case playing
        case gameOver
    }
    
    // MARK: - Constants
    fileprivate let radius: CGFloat = 25
    fileprivate let playerAnimationDuration = 5.0
    fileprivate var enemySpeed: CGFloat = 60 // points per second
    fileprivate let colors = ["大红","浅灰","浅黄","粉红","荧光绿","绿","紫","紫红","蓝","蓝绿","橘黄","橙"]
    
    // MARK: - fileprivate
    fileprivate var playerView = UIView(frame: .zero)
    fileprivate var playerAnimator: UIViewPropertyAnimator?
    
    fileprivate var enemyViews = [UIView]()
    fileprivate var enemyAnimators = [UIViewPropertyAnimator]()
    fileprivate var enemyTimer: Timer?
    
    fileprivate var displayLink: CADisplayLink?
    fileprivate var beginTimestamp: TimeInterval = 0
    fileprivate var elapsedTime: TimeInterval = 0
    
    fileprivate var gameState = GameState.ready
    let gameConfig = GameConfig.shared
    let sound = SoundManager()
    var interval = Int()
    let defaults = UserDefaults.standard
    // MARK: - IBOutlets
    @IBOutlet weak var clockLabel: UILabel!
    //  @IBOutlet weak var startLabel: UILabel!
    //  @IBOutlet weak var bestTimeLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        prepareGame()
        startGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // First touch to start the game
        //    if gameState == .ready {
        //      startGame()
        //    }
        
        if let touchLocation = event?.allTouches?.first?.location(in: view) {
            // Move the player to the new position
            movePlayer(to: touchLocation)
            
            // Move all enemies to the new position to trace the player
            moveEnemies(to: touchLocation)
        }
    }
    
    // MARK: - Selectors
    @objc func generateEnemy(timer: Timer) {
        // Generate an enemy with random position
        let screenEdge = ScreenEdge.init(rawValue: Int(arc4random_uniform(4)))
        let screenBounds = UIScreen.main.bounds
        var position: CGFloat = 0
        
        switch screenEdge! {
        case .left, .right:
            position = CGFloat(arc4random_uniform(UInt32(screenBounds.height)))
        case .top, .bottom:
            position = CGFloat(arc4random_uniform(UInt32(screenBounds.width)))
        }
        
        // Add the new enemy to the view
        let enemyView = UIView(frame: .zero)
        enemyView.bounds.size = CGSize(width: radius, height: radius)
        let bgImage = UIImageView(image: UIImage.init(named: getRandomColor()))
        bgImage.isUserInteractionEnabled = true
        enemyView.addSubview(bgImage)
        bgImage.snp.makeConstraints { (make) in
            make.center.equalTo(enemyView)
        }
        //    enemyView.backgroundColor = getRandomColor()
        
        switch screenEdge! {
        case .left:
            enemyView.center = CGPoint(x: 0, y: position)
        case .right:
            enemyView.center = CGPoint(x: screenBounds.width, y: position)
        case .top:
            enemyView.center = CGPoint(x: position, y: screenBounds.height)
        case .bottom:
            enemyView.center = CGPoint(x: position, y: 0)
        }
        
        view.addSubview(enemyView)
        
        // Start animation
        let duration = getEnemyDuration(enemyView: enemyView)
        let enemyAnimator = UIViewPropertyAnimator(duration: duration,
                                                   curve: .linear,
                                                   animations: { [weak self] in
                                                    if let strongSelf = self {
                                                        enemyView.center = strongSelf.playerView.center
                                                    }
            }
        )
        enemyAnimator.startAnimation()
        enemyAnimators.append(enemyAnimator)
        enemyViews.append(enemyView)
    }
    
    @objc func tick(sender: CADisplayLink) {
        updateCountUpTimer(timestamp: sender.timestamp)
        checkCollision()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGameOver" {
            let vc = segue.destination as! GameOverViewController
            vc.score = clockLabel.text!
        }
    }
}

fileprivate extension GameViewController {
    func setupPlayerView() {
        let bgImage = UIImageView(image:#imageLiteral(resourceName: "球球"))
        bgImage.isUserInteractionEnabled = true
        playerView.addSubview(bgImage)
        bgImage.snp.makeConstraints { (make) in
            make.center.equalTo(playerView)
        }
        view.addSubview(playerView)
    }
    
    func startEnemyTimer() {
        enemyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(generateEnemy(timer:)), userInfo: nil, repeats: true)
    }
    
    func stopEnemyTimer() {
        guard let enemyTimer = enemyTimer,
            enemyTimer.isValid else {
                return
        }
        enemyTimer.invalidate()
    }
    
    func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(tick(sender:)))
        displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }
    
    func stopDisplayLink() {
        displayLink?.isPaused = true
        displayLink?.remove(from: RunLoop.main, forMode: RunLoop.Mode.default)
        displayLink = nil
    }
    
    func getRandomColor() -> String {
        let index = arc4random_uniform(UInt32(colors.count))
        return colors[Int(index)]
    }
    
    func getEnemySpeed() {
        switch gameConfig.gameLevel {
        case .easy:
            enemySpeed = 60
        case .mid:
            enemySpeed = 100
        case .diff:
            enemySpeed = 120
        }
    }
    
    func getEnemyDuration(enemyView: UIView) -> TimeInterval {
        let dx = playerView.center.x - enemyView.center.x
        let dy = playerView.center.y - enemyView.center.y
        return TimeInterval(sqrt(dx * dx + dy * dy) / enemySpeed)
    }
    
    func gameOver() {
        stopGame()
        
        guard let highStr = defaults.object(forKey: "highScore") as? String else {
            return
        }
        
        guard var start = highStr.index(of: ":") else {
            return
        }
        
        start = highStr.index(after: start)
        
        guard let end = highStr.index(of: ".") else {
            return
        }
        
        let highMin = highStr.prefix(2)
        let highSec = highStr[start..<end]
        
        if interval / 60 % 60 > Int(highMin)! {
            defaults.set(clockLabel.text, forKey: "highScore")
        } else if interval % 60 > Int(highSec)! {
            defaults.set(clockLabel.text, forKey: "highScore")
        }
        
        performSegue(withIdentifier: "toGameOver", sender: clockLabel.text)
        //    displayGameOverAlert()
    }
    
    func stopGame() {
        removeEnemies()
        stopEnemyTimer()
        stopDisplayLink()
        stopAnimators()
        gameState = .gameOver
        sound.stopBackGroundSound()
        if gameConfig.isGameSound {
            sound.playOverSound()
        }
    }
    
    func prepareGame() {
        removeEnemies()
        centerPlayerView()
        getEnemySpeed()
        popPlayerView()
        gameState = .ready
    }
    
    func startGame() {
        print(enemySpeed)
        startEnemyTimer()
        startDisplayLink()
        beginTimestamp = 0
        gameState = .playing
        if gameConfig.isGameMusic {
            sound.playBackGroundSound()
        }
    }
    
    func removeEnemies() {
        enemyViews.forEach {
            $0.removeFromSuperview()
        }
        enemyViews = []
    }
    
    func stopAnimators() {
        playerAnimator?.stopAnimation(true)
        playerAnimator = nil
        enemyAnimators.forEach {
            $0.stopAnimation(true)
        }
        enemyAnimators = []
    }
    
    func updateCountUpTimer(timestamp: TimeInterval) {
        if beginTimestamp == 0 {
            beginTimestamp = timestamp
        }
        elapsedTime = timestamp - beginTimestamp
        clockLabel.text = format(timeInterval: elapsedTime)
    }
    
    func format(timeInterval: TimeInterval) -> String {
        interval = Int(timeInterval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let milliseconds = Int(timeInterval * 1000) % 1000
        return String(format: "%02d:%02d.%03d", minutes, seconds, milliseconds)
    }
    
    func checkCollision() {
        enemyViews.forEach {
            guard let playerFrame = playerView.layer.presentation()?.frame,
                let enemyFrame = $0.layer.presentation()?.frame,
                playerFrame.intersects(enemyFrame) else {
                    return
            }
            gameOver()
        }
    }
    
    func movePlayer(to touchLocation: CGPoint) {
        playerAnimator = UIViewPropertyAnimator(duration: playerAnimationDuration,
                                                dampingRatio: 0.5,
                                                animations: { [weak self] in
                                                    self?.playerView.center = touchLocation
        })
        playerAnimator?.startAnimation()
    }
    
    func moveEnemies(to touchLocation: CGPoint) {
        for (index, enemyView) in enemyViews.enumerated() {
            let duration = getEnemyDuration(enemyView: enemyView)
            enemyAnimators[index] = UIViewPropertyAnimator(duration: duration,
                                                           curve: .linear,
                                                           animations: {
                                                            enemyView.center = touchLocation
            })
            enemyAnimators[index].startAnimation()
        }
    }
    
    func centerPlayerView() {
        // Place the player in the center of the screen.
        playerView.center = view.center
    }
    
    // Copy from IBAnimatable
    func popPlayerView() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [0, 0.2, -0.2, 0.2, 0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = CFTimeInterval(0.7)
        animation.isAdditive = true
        animation.repeatCount = 1
        animation.beginTime = CACurrentMediaTime()
        playerView.layer.add(animation, forKey: "pop")
    }
    
    func setBestTime(with time:String){
        defaults.set(time, forKey: "bestTime")
    }
    
    func getBestTime() -> String{
        let time = defaults.value(forKey: "bestTime") as? String
        return time!
    }
    
}
