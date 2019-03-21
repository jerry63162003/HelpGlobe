//
//  GameConfig.swift
//  BallEscape
//
//  Created by Liqiu Li on 2019/3/21.
//  Copyright © 2019年 xxx. All rights reserved.
//

import UIKit

enum GameMode: String {
    case easy = "easy"
    case mid = "mid"
    case diff = "diff"
}

let uGameMusic = "isGameMusic"
let uGameSound = "isGameSound"
let uGameLevel = "gameLevel"

class GameConfig: NSObject {
    static let shared = GameConfig()
    
    var gameLevel: GameMode = (UserDefaults.standard.string(forKey: uGameLevel) != nil) ? GameMode(rawValue: UserDefaults.standard.string(forKey: uGameLevel)!)! : .easy {
        didSet {
            UserDefaults.standard.set(gameLevel.rawValue, forKey: uGameLevel)
            UserDefaults.standard.synchronize()
        }
    }
    
    var isGameMusic = UserDefaults.standard.object(forKey: uGameMusic) as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(isGameMusic, forKey: uGameMusic)
            UserDefaults.standard.synchronize()
        }
    }
    var isGameSound = UserDefaults.standard.object(forKey: uGameSound) as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(isGameSound, forKey: uGameSound)
            UserDefaults.standard.synchronize()
        }
    }
}
