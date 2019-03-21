//
//  SoundManager.swift
//  BallEscape
//
//  Created by Liqiu Li on 2019/3/21.
//  Copyright © 2019年 xxx. All rights reserved.
//

import UIKit
import AVFoundation

enum GameLevel: String {
    case easy = "easy"
    case mid = "mid"
    case diff = "diff"
}

let gameMusic = "isGameMusic"
let gameSound = "isGameSound"
let chooseLevel = "gameLevel"

class SoundManager: NSObject {
    
//    static let shared = SoundManager()
//
//    var gameLevel: GameLevel = (UserDefaults.standard.string(forKey: chooseLevel) != nil) ? GameLevel(rawValue: UserDefaults.standard.string(forKey: chooseLevel)!)! : .easy {
//        didSet {
//            UserDefaults.standard.set(gameLevel.rawValue, forKey: chooseLevel)
//            UserDefaults.standard.synchronize()
//        }
//    }
//
//    var isGameMusic = UserDefaults.standard.object(forKey: gameMusic) as? Bool ?? true {
//        didSet {
//            UserDefaults.standard.set(isGameMusic, forKey: gameMusic)
//            UserDefaults.standard.synchronize()
//        }
//    }
//    var isGameSound = UserDefaults.standard.object(forKey: gameSound) as? Bool ?? true {
//        didSet {
//            UserDefaults.standard.set(isGameSound, forKey: gameSound)
//            UserDefaults.standard.synchronize()
//        }
//    }
    
    //申明一个播放器
    var bgMusicPlayer: AVAudioPlayer?
    var winMusic: AVAudioPlayer?
    //播放点击的动作音效
    lazy var gameOver: AVAudioPlayer = {
        do {
            if let fileURL = Bundle.main.path(forResource: "Die", ofType: "mp3") {
                winMusic = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
        
        return winMusic!
    }()
    
    //播放背景音乐的音效
    lazy var backGround: AVAudioPlayer = {
        do {
            if let fileURL = Bundle.main.path(forResource: "Game", ofType: "wav") {
                bgMusicPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                bgMusicPlayer?.numberOfLoops = -1
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
        return bgMusicPlayer!
    }()
    
    //播放点击音效动作的方法
    func playOverSound(){
        gameOver.play()
    }
    func playBackGroundSound(){
        backGround.play()
    }
    func stopBackGroundSound() {
        backGround.stop()
    }
}
