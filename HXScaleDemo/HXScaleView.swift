//
//  HXScaleView.swift
//  HXScaleDemo
//
//  Created by hubery on 2017/5/25.
//  Copyright © 2017年 hubery. All rights reserved.
//

import UIKit

class HXScaleView: UIView {
    
    //刻度值
    var progress : CGFloat = 0.0 {
        didSet{
            print("我要把数据修改成\(progress)")
            //跨度值
            let gapValue = progress - oldValue
            //刻度盘整个跨度设置为3秒, 根据当前跨度来确定需要的动画时间
            let time = fabsf(Float(gapValue * 3.0))
            //刻度盘的隐式动画
            CATransaction.begin()
            CATransaction.setDisableActions(false)
            CATransaction.setAnimationDuration(CFTimeInterval(time))
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear))
            progressLayer.strokeEnd = progress
            CATransaction.commit()
            
            //valueLabel的数值变化
            let anima = CATransition.init()
            anima.duration = 1.0
            valueLabel.text = String(format: "%.1f", progress * 100)
            valueLabel.layer.add(anima, forKey: nil)
        }
    }
    
    //中间的数值label
    lazy var valueLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: self.center.x - 40, y: self.center.y - 50, width: 80, height: 50))
        label.textColor = UIColor.white
        label.text = "0"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: 35)
        return label
    }()
    
    //遮盖layer
    lazy var progressLayer: CAShapeLayer = {
        let bezierPath = UIBezierPath.init(arcCenter: self.center, radius: 115, startAngle: -(CGFloat.pi), endAngle: 0, clockwise: true)
        let proLayer = CAShapeLayer.init()
        proLayer.lineWidth = 60.0
        proLayer.strokeColor = UIColor.red.cgColor
        proLayer.fillColor = UIColor.clear.cgColor
        proLayer.path = bezierPath.cgPath
        proLayer.strokeStart = 0.0
        proLayer.strokeEnd = 0.0
        return proLayer
    }()
    
    //进度layer
    lazy var gradientLayer: CAGradientLayer = {
        let graLayer = CAGradientLayer.init()
        graLayer.frame = self.bounds
        graLayer.colors = [
            UIColor.init(red: 0.09, green: 0.58, blue: 0.15, alpha: 1).cgColor,
            UIColor.init(red: 0.20, green: 0.63, blue: 0.25, alpha: 1).cgColor,
            UIColor.init(red: 0.60, green: 0.82, blue: 0.22, alpha: 1).cgColor,
            UIColor.init(red: 0.97, green: 0.65, blue: 0.22, alpha: 1).cgColor,
            UIColor.init(red: 0.96, green: 0.08, blue: 0.10, alpha: 1).cgColor
        ]
        graLayer.locations = [0,0.25,0.5,0.75,1]
        graLayer.startPoint = CGPoint.init(x: 0, y: 0)
        graLayer.endPoint = CGPoint.init(x: 1, y: 0)
        return graLayer
    }()
    
    //init
    override init(frame : CGRect){
        super.init(frame: frame)
        //添加遮盖Layer
        layer.addSublayer(progressLayer)
        
        //设置进度Layer的遮盖
        gradientLayer.mask = progressLayer
        //添加进度Layer
        layer.addSublayer(gradientLayer)
        
        //添加两条白色边框
        drawCurveRadius(radius: 147.5)
        drawCurveRadius(radius: 82.5)
        
        //添加中间的数值Label
        addSubview(valueLabel)
    }
    
    //上下边框
    func drawCurveRadius(radius : CGFloat){
        let path = UIBezierPath.init(arcCenter: center, radius: radius, startAngle: -CGFloat.pi, endAngle: 0, clockwise: true)
        let curve = CAShapeLayer.init()
        curve.lineWidth = 4.0
        curve.fillColor = UIColor.clear.cgColor
        curve.strokeColor = UIColor.white.cgColor
        curve.path = path.cgPath
        self.layer.addSublayer(curve)
        self.drawScale()
    }
    
    //刻度
    func drawScale(){
        let perAngle = CGFloat.pi / 50.0 //一刻度的弧度
        let calWidth = perAngle / 10.0 //刻度线的宽度
        for index in 1..<50{
            let startAngel = -CGFloat.pi + perAngle * CGFloat(index)
            let endAngel = startAngel + calWidth
            let path = UIBezierPath.init(arcCenter: center, radius: 140, startAngle: startAngel, endAngle: endAngel, clockwise: true)
            let shapeLayer = CAShapeLayer.init()
            if index % 5 == 0 {
                shapeLayer.strokeColor = UIColor.white.cgColor
                shapeLayer.lineWidth = 10.0
                //计算刻度值Label位置
                let labelRadius : CGFloat = 125.0 //label中心点的半径
                let x = labelRadius * cos(-startAngel)
                let y = labelRadius * sin(-startAngel)
                let point = CGPoint.init(x: center.x + x, y: center.y - y)
                //刻度值label
                let scaleLabel = UILabel.init(frame: CGRect.init(x: point.x - 10, y: point.y - 10, width: 20, height: 20))
                scaleLabel.text = "\(index * 2)"
                scaleLabel.font = UIFont.systemFont(ofSize: 10)
                scaleLabel.textColor = UIColor.white
                scaleLabel.textAlignment = NSTextAlignment.center
                self.addSubview(scaleLabel)
            }else{
                shapeLayer.strokeColor = UIColor.white.cgColor
                shapeLayer.lineWidth = 5.0
            }
            shapeLayer.path = path.cgPath
            self.layer.addSublayer(shapeLayer)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
