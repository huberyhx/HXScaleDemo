//
//  ViewController.swift
//  HXScaleDemo
//
//  Created by hubery on 2017/5/25.
//  Copyright © 2017年 hubery. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var sliderView: UISlider!
    
    //刻度表懒加载
    lazy var progressView: HXScaleView = {
        let proView = HXScaleView.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 300))
        proView.backgroundColor = UIColor.lightGray
        return proView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //添加刻度表View
        view.addSubview(progressView)
    }

    //拖动值
    @IBAction func ValueChange(_ sender: UISlider) {
        progressView.progress = CGFloat(sender.value)
    }

    //随机值
    @IBAction func arcValue() {
        let value = arc4random_uniform(100)
        let floatValue = CGFloat(value)*0.01
        progressView.progress = floatValue
        sliderView.setValue(Float(floatValue), animated: true)
    }
}

