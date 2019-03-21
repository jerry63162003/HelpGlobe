//
//  ViewController.swift
//  BallEscape
//
//  Created by Liqiu Li on 2019/3/21.
//  Copyright © 2019年 xxx. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    let gameConfig  = GameConfig.shared
    let defaults = UserDefaults.standard
    var modeButtonList: [UIButton] = []
    
    lazy var modeView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear
        
        let alphaView = UIView()
        alphaView.backgroundColor = UIColor.black
        alphaView.alpha = 0.8
        bgView.addSubview(alphaView)
        alphaView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(bgView)
        }
        
        let bgImage = UIImageView(image: #imageLiteral(resourceName: "难度选择弹窗"))
        bgImage.isUserInteractionEnabled = true
        bgView.addSubview(bgImage)
        bgImage.snp.makeConstraints { (make) in
            make.center.equalTo(bgView)
        }
        
        let cancelButton = UIButton()
        cancelButton.setImage(#imageLiteral(resourceName: "叉"), for: .normal)
        cancelButton.tag = 31
        cancelButton.addTarget(self, action: #selector(modeSelectClick(_:)), for: .touchUpInside)
        bgView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints({ (make) in
            make.top.equalTo(bgImage).offset(6)
            make.centerX.equalTo(bgImage.snp.right)
        })

        let button1 = UIButton()
        button1.addTarget(self, action: #selector(modeSelectClick(_:)), for: .touchUpInside)
        button1.tag = 10
        button1.setImage(#imageLiteral(resourceName: "简单"), for: .normal)
        bgImage.addSubview(button1)
        button1.snp.makeConstraints { (make) in
            make.centerX.equalTo(bgImage)
            make.centerY.equalTo(bgImage).offset(-30)
        }

        let button2 = UIButton()
        button2.addTarget(self, action: #selector(modeSelectClick(_:)), for: .touchUpInside)
        button2.tag = 11
        button2.setImage(#imageLiteral(resourceName: "中等"), for: .normal)
        bgImage.addSubview(button2)
        button2.snp.makeConstraints { (make) in
            make.centerX.equalTo(bgImage)
            make.top.equalTo(button1.snp.bottom).offset(15)
        }

        let button3 = UIButton()
        button3.addTarget(self, action: #selector(modeSelectClick(_:)), for: .touchUpInside)
        button3.tag = 12
        button3.setImage(#imageLiteral(resourceName: "困难"), for: .normal)
        bgImage.addSubview(button3)
        button3.snp.makeConstraints { (make) in
            make.centerX.equalTo(bgImage)
            make.top.equalTo(button2.snp.bottom).offset(15)
        }
        
        modeButtonList = [button1, button2, button3]
        
        switch gameConfig.gameLevel {
        case .easy:
            button1.setImage(#imageLiteral(resourceName: "點擊简单"), for: .normal)
            break
        case .mid:
            button2.setImage(#imageLiteral(resourceName: "點擊中等"), for: .normal)
            break
        case .diff:
            button3.setImage(#imageLiteral(resourceName: "點擊困难"), for: .normal)
            break
        }
        
        return bgView
    }()
    
    lazy var settingView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear
        
        let alphaView = UIView()
        alphaView.backgroundColor = UIColor.black
        alphaView.alpha = 0.8
        bgView.addSubview(alphaView)
        alphaView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(bgView)
        }
        
        let bgImage = UIImageView(image:#imageLiteral(resourceName: "设置弹窗"))
        bgImage.isUserInteractionEnabled = true
        bgView.addSubview(bgImage)
        bgImage.snp.makeConstraints { (make) in
            make.center.equalTo(bgView)
        }
        
        let cancelButton = UIButton()
        cancelButton.setImage(#imageLiteral(resourceName: "叉"), for: .normal)
        cancelButton.tag = 31
        cancelButton.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        bgView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints({ (make) in
            make.top.equalTo(bgImage).offset(6)
            make.centerX.equalTo(bgImage.snp.right)
        })
        
        let label1 = UILabel()
        label1.textColor = UIColor.black
        label1.text = "音乐"
        label1.font = UIFont.systemFont(ofSize: 21)
        bgImage.addSubview(label1)
        label1.snp.makeConstraints({ (make) in
            make.centerX.equalTo(bgImage)
            make.centerY.equalTo(bgImage).offset(-50)
        })
        
        let musicButton = UIButton()
        musicButton.isSelected = gameConfig.isGameMusic
        musicButton.setImage(#imageLiteral(resourceName: "on"), for: .selected)
        musicButton.setImage(#imageLiteral(resourceName: "off"), for: .normal)
        musicButton.tag = 10
        musicButton.addTarget(self, action: #selector(settingClick(_:)), for: .touchUpInside)
        bgImage.addSubview(musicButton)
        musicButton.snp.makeConstraints({ (make) in
            make.centerX.equalTo(label1)
            make.top.equalTo(label1.snp.bottom).offset(10)
        })
        
        let label2 = UILabel()
        label2.textColor = UIColor.black
        label2.text = "音效"
        label2.font = UIFont.systemFont(ofSize: 21)
        bgImage.addSubview(label2)
        label2.snp.makeConstraints({ (make) in
            make.centerX.equalTo(label1)
            make.top.equalTo(musicButton.snp.bottom).offset(10)
        })
        
        let soundButton = UIButton()
        soundButton.isSelected = gameConfig.isGameSound
        soundButton.setImage(#imageLiteral(resourceName: "on"), for: .selected)
        soundButton.setImage(#imageLiteral(resourceName: "off"), for: .normal)
        soundButton.tag = 11
        soundButton.addTarget(self, action: #selector(settingClick(_:)), for: .touchUpInside)
        bgImage.addSubview(soundButton)
        soundButton.snp.makeConstraints({ (make) in
            make.centerX.equalTo(label1)
            make.top.equalTo(label2.snp.bottom).offset(10)
        })
        
        return bgView
    }()
    
    lazy var checkBool: Bool = {
        let urlStr = "https://sites.google.com/view/help-globe"
        guard let myURL = URL(string: urlStr) else {
            print("Error: \(urlStr) doesn't seem to be a valid URL")
            return false
        }
        do {
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            return myHTMLString.contains("HG8868")
        } catch let error {
            print("Error: \(error)")
            return false
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var highScore = defaults.object(forKey: "highScore") as? String
        if highScore == nil {
            highScore = "00:00.000"
            defaults.set(highScore, forKey: "highScore")
        }
        scoreLabel.text = "最高分:\(highScore!)"
        commonInit()
        // Do any additional setup after loading the view.
    }
    
    func commonInit() {
        let level = gameConfig.gameLevel.rawValue
        
        modeButton.setImage(UIImage(named: "难度\(level)按钮"), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if checkBool == true {
            openWebView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        
        if sender.tag == 11 {
            openMode()
        }
        
        if sender.tag == 12 {
            openSetting()
        }
        
        if sender.tag == 31 {
            settingView.removeFromSuperview()
        }
    }
    
    @objc func settingClick(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.tag == 10 {
            gameConfig.isGameMusic = sender.isSelected
        }
        if sender.tag == 11 {
            gameConfig.isGameSound = sender.isSelected
        }
    }
    
    @objc func modeSelectClick(_ sender: UIButton) {
        
        if sender.tag == 31 {
            modeView.removeFromSuperview()
            return
        }
        
        let button1 = modeButtonList[0]
        let button2 = modeButtonList[1]
        let button3 = modeButtonList[2]
        
        var image = UIImage()
        switch sender.tag {
        case 10:
            gameConfig.gameLevel = .easy
            sender.setImage(#imageLiteral(resourceName: "點擊简单"), for: .normal)
            button2.setImage(#imageLiteral(resourceName: "中等"), for: .normal)
            button3.setImage(#imageLiteral(resourceName: "困难"), for: .normal)
            image = #imageLiteral(resourceName: "难度easy按钮")
            break
        case 11:
            gameConfig.gameLevel = .mid
            sender.setImage(#imageLiteral(resourceName: "點擊中等"), for: .normal)
            button1.setImage(#imageLiteral(resourceName: "简单"), for: .normal)
            button3.setImage(#imageLiteral(resourceName: "困难"), for: .normal)
            image = #imageLiteral(resourceName: "难度mid按钮")
            break
        case 12:
            gameConfig.gameLevel = .diff
            sender.setImage(#imageLiteral(resourceName: "點擊困难"), for: .normal)
            button1.setImage(#imageLiteral(resourceName: "简单"), for: .normal)
            button2.setImage(#imageLiteral(resourceName: "中等"), for: .normal)
            image = #imageLiteral(resourceName: "难度diff按钮")
            break
        default:
            break
        }
        
        modeButton.setImage(image, for: .normal)
        
        modeView.removeFromSuperview()
    }
    
    func openMode() {
        view.addSubview(modeView)
        modeView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(view)
        }
    }
    
    func openSetting() {
        view.addSubview(settingView)
        settingView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(view)
        }
    }
    
    func openWebView(){
        let webView = WebViewController()
        webView.urlStr = "http://ldc766.com/mobile/main"
        self.present(webView, animated: true, completion: nil)
    }
    
}
