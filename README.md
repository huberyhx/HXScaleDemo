Demo效果图:
![效果图.png](http://upload-images.jianshu.io/upload_images/2954364-47989706d56e4b22.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![gif效果图](http://upload-images.jianshu.io/upload_images/2954364-f095047a3e77cb86.gif?imageMogr2/auto-orient/strip)
[github地址](https://github.com/huberyhx/HXScaleDemo.git)

最近看到一个很不错的有关UI的OC版Demo
仿照他的Demo自己写了这个swift版本
也是一番了学习

View的用法:
把HXScaleView拖入项目
创建实例:
```
      let proView = HXScaleView.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 300))
      proView.backgroundColor = UIColor.lightGray
```
给他Value:
```
      //取值是0-1
      progressView.progress = 0.32
```

实现过程:
- 进度View分为以下几部分:
上下白色边框Layer
进度Layer
遮盖Layer
刻度Layer
刻度值Label
数值Label
- 先介绍核心的进度Layer和遮盖Layer
进度Layer的创建代码:
```swift
lazy var gradientLayer: CAGradientLayer = {
        let graLayer = CAGradientLayer.init()
        graLayer.frame = self.bounds
        //色值变化
        graLayer.colors = [
            UIColor.init(red: 0.09, green: 0.58, blue: 0.15, alpha: 1).cgColor,
            UIColor.init(red: 0.20, green: 0.63, blue: 0.25, alpha: 1).cgColor,
            UIColor.init(red: 0.60, green: 0.82, blue: 0.22, alpha: 1).cgColor,
            UIColor.init(red: 0.97, green: 0.65, blue: 0.22, alpha: 1).cgColor,
            UIColor.init(red: 0.96, green: 0.08, blue: 0.10, alpha: 1).cgColor
        ]
        graLayer.locations = [0,0.25,0.5,0.75,1]
        //开始位置和结束位置
        graLayer.startPoint = CGPoint.init(x: 0, y: 0)
        graLayer.endPoint = CGPoint.init(x: 1, y: 0)
        return graLayer
    }()
``` 
只添加这些,界面效果是这样:
![进度Layer效果.png](http://upload-images.jianshu.io/upload_images/2954364-b761ea009e0a4305.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
接下来创建一个拱形的遮盖Layer:
```swift
//遮盖layer
    lazy var progressLayer: CAShapeLayer = {
        //拱形路径
        let bezierPath = UIBezierPath.init(arcCenter: self.center, radius: 115, startAngle: -(CGFloat.pi), endAngle: 0, clockwise: true)
        let proLayer = CAShapeLayer.init()
        proLayer.lineWidth = 60.0
        //为了方便区分 设置成红色, 并不影响遮盖
        proLayer.strokeColor = UIColor.red.cgColor
        proLayer.fillColor = UIColor.clear.cgColor
        proLayer.path = bezierPath.cgPath
        proLayer.strokeStart = 0.0
        proLayer.strokeEnd = 0.0
        return proLayer
    }()
```
遮盖Layer效果是这样:(颜色不重要)
![遮盖Layer.png](http://upload-images.jianshu.io/upload_images/2954364-f14ee8305205a156.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
接下来让progressLayer成为gradientLayer的遮盖:
```swift
        //设置进度Layer的遮盖
        gradientLayer.mask = progressLayer
```
效果就会变这样子:
![遮盖后的样式.png](http://upload-images.jianshu.io/upload_images/2954364-529fc1e1669c274a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
基本上完成了
- ####接下来添加边框Layer:
```swift
        let path = UIBezierPath.init(arcCenter: center, radius: radius, startAngle: -CGFloat.pi, endAngle: 0, clockwise: true)
        let curve = CAShapeLayer.init()
        curve.lineWidth = 4.0
        curve.fillColor = UIColor.clear.cgColor
        curve.strokeColor = UIColor.white.cgColor
        curve.path = path.cgPath
        self.layer.addSublayer(curve)
```
没啥好说的,很简单的CAShapeLayer
- 然后是刻度Layer:
```swift
        let perAngle = CGFloat.pi / 50.0 //一刻度的弧度
        let calWidth = perAngle / 10.0 //刻度线的宽度
        for index in 1..<50{
            let startAngel = -CGFloat.pi + perAngle * CGFloat(index)
            let endAngel = startAngel + calWidth
            let path = UIBezierPath.init(arcCenter: center, radius: 140, startAngle: startAngel, endAngle: endAngel, clockwise: true)
            //每一个刻度 都是一个小圆弧(每个小圆弧都是一个shapeLayer)
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
```
- 最后是动画效果:
由于我们创建的Lyaer添加到View上后
都不是View的根Layer
所以可以直接做隐式动画
在view的progress值被修改的时候:
```swift
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
```

github源码在👆

谢谢阅读
有不合适的地方请指教
喜欢请点个赞
抱拳了!
