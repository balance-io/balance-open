//
//  SyncCircle.swift
//
//  Code generated using QuartzCode 1.52.0 on 12/7/16.
//  www.quartzcodeapp.com
//

import Cocoa

@IBDesignable
public class SyncCircle: NSView, CAAnimationDelegate {
	
	var layers : Dictionary<String, AnyObject> = [:]
	var completionBlocks : Dictionary<CAAnimation, (Bool) -> Void> = [:]
	var updateLayerValueForCompletedAnimation : Bool = true
	
    var syncCircleColor : NSColor!
	
	//MARK: - Life Cycle
    
    public init(syncCircleColor: NSColor) {
        super.init(frame: NSZeroRect)
        self.syncCircleColor = syncCircleColor
        setupLayers()
    }
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setupProperties()
		setupLayers()
	}
	
	public required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		setupProperties()
		setupLayers()
	}
	
    public func setupProperties(){
        self.syncCircleColor = NSColor(red:0.592, green: 0.663, blue:0.722, alpha:1)
    }
    
    public func setupLayers(){
        self.wantsLayer = true
        
        let spin = CALayer()
        spin.frame = CGRect(x: 5.88, y: 5.83, width: 14.34, height: 14.34)
        self.layer?.addSublayer(spin)
        layers["spin"] = spin
        let circle = CAShapeLayer()
        circle.frame = CGRect(x: 0, y: 0, width: 14.34, height: 14.34)
        circle.path = circlePath().quartzPath
        spin.addSublayer(circle)
        layers["circle"] = circle
        let circle2 = CAShapeLayer()
        circle2.frame = CGRect(x: 0, y: 0, width: 14.34, height: 14.34)
        circle2.path = circle2Path().quartzPath
        spin.addSublayer(circle2)
        layers["circle2"] = circle2
        
        let arrowSpin = CALayer()
        arrowSpin.frame = CGRect(x: 3, y: 8.67, width: 5.76, height: 4.33)
        self.layer?.addSublayer(arrowSpin)
        layers["arrowSpin"] = arrowSpin
        let arrowSpinAgain = CALayer()
        arrowSpinAgain.frame = CGRect(x: 0, y: 0, width: 5.76, height: 4.33)
        arrowSpin.addSublayer(arrowSpinAgain)
        layers["arrowSpinAgain"] = arrowSpinAgain
        let arrowFinalSpin = CALayer()
        arrowFinalSpin.frame = CGRect(x: 0, y: 0, width: 5.76, height: 4.33)
        arrowSpinAgain.addSublayer(arrowFinalSpin)
        layers["arrowFinalSpin"] = arrowFinalSpin
        let arrow = CAShapeLayer()
        arrow.frame = CGRect(x: -0, y: 0, width: 5.76, height: 4.33)
        arrow.path = arrowPath().quartzPath
        arrowFinalSpin.addSublayer(arrow)
        layers["arrow"] = arrow
        let hiddenArrow = CAShapeLayer()
        hiddenArrow.frame = CGRect(x: 0, y: 0, width: 5.76, height: 4.33)
        hiddenArrow.path = hiddenArrowPath().quartzPath
        arrowFinalSpin.addSublayer(hiddenArrow)
        layers["hiddenArrow"] = hiddenArrow
        
        let clock = CALayer()
        clock.frame = CGRect(x: 12.01, y: 10.37, width: 4.44, height: 7.55)
        self.layer?.addSublayer(clock)
        layers["clock"] = clock
        let minuteHand = CAShapeLayer()
        minuteHand.frame = CGRect(x: 0, y: 1.13, width: 2.09, height: 6.41)
        minuteHand.path = minuteHandPath().quartzPath
        clock.addSublayer(minuteHand)
        layers["minuteHand"] = minuteHand
        let hourHand = CAShapeLayer()
        hourHand.frame = CGRect(x: 0, y: 0, width: 4.44, height: 3.22)
        hourHand.path = hourHandPath().quartzPath
        clock.addSublayer(hourHand)
        layers["hourHand"] = hourHand
        
        resetLayerProperties(forLayerIdentifiers: nil)
    }
    
    public func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("circle"){
            let circle = layers["circle"] as! CAShapeLayer
            circle.setValue(-90 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            circle.opacity     = 0
            circle.lineCap     = kCALineCapRound
            circle.fillColor   = nil
            circle.strokeColor = self.syncCircleColor.cgColor
            circle.lineWidth   = 1.5
            circle.strokeStart = 0.25
            circle.fillMode = kCAFillModeRemoved
        }
        if layerIds == nil || layerIds.contains("circle2"){
            let circle2 = layers["circle2"] as! CAShapeLayer
            circle2.setValue(-180 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            circle2.lineCap     = kCALineCapRound
            circle2.fillColor   = nil
            circle2.strokeColor = self.syncCircleColor.cgColor
            circle2.lineWidth   = 1.5
            circle2.strokeEnd   = 0.75
            circle2.fillMode    = kCAFillModeRemoved
        }
        if layerIds == nil || layerIds.contains("arrowSpin"){
            let arrowSpin = layers["arrowSpin"] as! CALayer
            arrowSpin.anchorPoint = CGPoint(x: 1.747, y: 1)
            arrowSpin.frame       = CGRect(x: 3, y: 8.67, width: 5.76, height: 4.33)
            arrowSpin.fillMode    = kCAFillModeRemoved
        }
        if layerIds == nil || layerIds.contains("arrowSpinAgain"){
            let arrowSpinAgain = layers["arrowSpinAgain"] as! CALayer
            arrowSpinAgain.anchorPoint = CGPoint(x: 1.747, y: 1)
            arrowSpinAgain.frame       = CGRect(x: 0, y: 0, width: 5.76, height: 4.33)
            arrowSpinAgain.fillMode    = kCAFillModeRemoved
        }
        if layerIds == nil || layerIds.contains("arrowFinalSpin"){
            let arrowFinalSpin = layers["arrowFinalSpin"] as! CALayer
            arrowFinalSpin.anchorPoint = CGPoint(x: 1.747, y: 1)
            arrowFinalSpin.frame       = CGRect(x: 0, y: 0, width: 5.76, height: 4.33)
            arrowFinalSpin.fillMode    = kCAFillModeRemoved
        }
        if layerIds == nil || layerIds.contains("arrow"){
            let arrow = layers["arrow"] as! CAShapeLayer
            arrow.anchorPoint = CGPoint(x: 0.5, y: 1)
            arrow.frame       = CGRect(x: -0, y: 0, width: 5.76, height: 4.33)
            arrow.fillColor   = self.syncCircleColor.cgColor
            arrow.strokeColor = NSColor.black.cgColor
            arrow.lineWidth   = 0
            arrow.fillMode    = kCAFillModeRemoved
        }
        if layerIds == nil || layerIds.contains("hiddenArrow"){
            let hiddenArrow = layers["hiddenArrow"] as! CAShapeLayer
            hiddenArrow.anchorPoint = CGPoint(x: 1.747, y: 1)
            hiddenArrow.frame       = CGRect(x: 0, y: 0, width: 5.76, height: 4.33)
            hiddenArrow.opacity     = 0
            hiddenArrow.fillColor   = self.syncCircleColor.cgColor
            hiddenArrow.strokeColor = NSColor.black.cgColor
            hiddenArrow.lineWidth   = 0
            hiddenArrow.fillMode    = kCAFillModeRemoved
        }
        if layerIds == nil || layerIds.contains("clock"){
            let clock = layers["clock"] as! CALayer
            clock.anchorPoint = CGPoint(x: 0.25, y: 0.287)
            clock.frame       = CGRect(x: 12.01, y: 10.37, width: 4.44, height: 7.55)
            clock.fillMode    = kCAFillModeRemoved
        }
        if layerIds == nil || layerIds.contains("minuteHand"){
            let minuteHand = layers["minuteHand"] as! CAShapeLayer
            minuteHand.anchorPoint = CGPoint(x: 0.5, y: 0.163)
            minuteHand.frame       = CGRect(x: 0, y: 1.13, width: 2.09, height: 6.41)
            minuteHand.fillColor   = self.syncCircleColor.cgColor
            minuteHand.strokeColor = NSColor.black.cgColor
            minuteHand.lineWidth   = 0
            minuteHand.fillMode   = kCAFillModeRemoved
        }
        if layerIds == nil || layerIds.contains("hourHand"){
            let hourHand = layers["hourHand"] as! CAShapeLayer
            hourHand.anchorPoint = CGPoint(x: 0.234, y: 0.675)
            hourHand.frame       = CGRect(x: 0, y: 0, width: 4.44, height: 3.22)
            hourHand.fillColor   = self.syncCircleColor.cgColor
            hourHand.strokeColor = NSColor.black.cgColor
            hourHand.lineWidth   = 0
            hourHand.fillMode    = kCAFillModeRemoved
        }
        
        CATransaction.commit()
    }
	
	//MARK: - Animation Setup
	
    public func addSyncingAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 1.5
            completionAnim.delegate = self
            completionAnim.setValue("syncing", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer!.add(completionAnim, forKey:"syncing")
            if let anim = layer!.animation(forKey: "syncing"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : String = kCAFillModeRemoved
        
        ////Spin animation
        let spinTransformAnim      = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        spinTransformAnim.values   = [0, 360 * (CGFloat.pi/180)]
        spinTransformAnim.keyTimes = [0, 1]
        spinTransformAnim.duration = 1.5
        
        let spinSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [spinTransformAnim], fillMode:fillMode)
        layers["spin"]?.add(spinSyncingAnim, forKey:"spinSyncingAnim")
        
        ////Circle animation
        let circleStrokeStartAnim            = CAKeyframeAnimation(keyPath:"strokeStart")
        circleStrokeStartAnim.values         = [0.973, 0.25]
        circleStrokeStartAnim.keyTimes       = [0, 1]
        circleStrokeStartAnim.duration       = 0.75
        circleStrokeStartAnim.beginTime      = 0.75
        circleStrokeStartAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        
        let circleTransformAnim            = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        circleTransformAnim.values         = [-190 * (CGFloat.pi/180), -90 * (CGFloat.pi/180)]
        circleTransformAnim.keyTimes       = [0, 1]
        circleTransformAnim.duration       = 0.75
        circleTransformAnim.beginTime      = 0.75
        circleTransformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        
        let circleOpacityAnim       = CAKeyframeAnimation(keyPath:"opacity")
        circleOpacityAnim.values    = [1, 1]
        circleOpacityAnim.keyTimes  = [0, 1]
        circleOpacityAnim.duration  = 0.75
        circleOpacityAnim.beginTime = 0.75
        
        let circleStrokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        circleStrokeEndAnim.values   = [0.998, 0.998, 1]
        circleStrokeEndAnim.keyTimes = [0, 0.5, 1]
        circleStrokeEndAnim.duration = 1.5
        
        let circleSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [circleStrokeStartAnim, circleTransformAnim, circleOpacityAnim, circleStrokeEndAnim], fillMode:fillMode)
        layers["circle"]?.add(circleSyncingAnim, forKey:"circleSyncingAnim")
        
        ////Circle2 animation
        let circle2StrokeEndAnim            = CAKeyframeAnimation(keyPath:"strokeEnd")
        circle2StrokeEndAnim.values         = [0.75, 0.025]
        circle2StrokeEndAnim.keyTimes       = [0, 1]
        circle2StrokeEndAnim.duration       = 0.75
        circle2StrokeEndAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        
        let circle2StrokeStartAnim      = CAKeyframeAnimation(keyPath:"strokeStart")
        circle2StrokeStartAnim.values   = [0, 0]
        circle2StrokeStartAnim.keyTimes = [0, 1]
        circle2StrokeStartAnim.duration = 1.5
        
        let circle2TransformAnim      = CAKeyframeAnimation(keyPath:"transform")
        circle2TransformAnim.values   = [NSValue(caTransform3D: CATransform3DMakeRotation(-180 * (CGFloat.pi/180), 0, 0, 1)),
                                         NSValue(caTransform3D: CATransform3DMakeRotation(-180 * (CGFloat.pi/180), 0, 0, 1))]
        circle2TransformAnim.keyTimes = [0, 1]
        circle2TransformAnim.duration = 1.5
        
        let circle2OpacityAnim       = CAKeyframeAnimation(keyPath:"opacity")
        circle2OpacityAnim.values    = [0, 0]
        circle2OpacityAnim.keyTimes  = [0, 1]
        circle2OpacityAnim.duration  = 0.75
        circle2OpacityAnim.beginTime = 0.75
        
        let circle2SyncingAnim : CAAnimationGroup = QCMethod.group(animations: [circle2StrokeEndAnim, circle2StrokeStartAnim, circle2TransformAnim, circle2OpacityAnim], fillMode:fillMode)
        layers["circle2"]?.add(circle2SyncingAnim, forKey:"circle2SyncingAnim")
        
        ////ArrowSpin animation
        let arrowSpinOpacityAnim      = CAKeyframeAnimation(keyPath:"opacity")
        arrowSpinOpacityAnim.values   = [0, 0]
        arrowSpinOpacityAnim.keyTimes = [0, 1]
        arrowSpinOpacityAnim.duration = 1.5
        
        let arrowSpinSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [arrowSpinOpacityAnim], fillMode:fillMode)
        layers["arrowSpin"]?.add(arrowSpinSyncingAnim, forKey:"arrowSpinSyncingAnim")
	}
	
	public func addFinishSyncingAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
		if completionBlock != nil{
			let completionAnim = CABasicAnimation(keyPath:"completionAnim")
			completionAnim.duration = 2.4
			completionAnim.delegate = self
			completionAnim.setValue("finishSyncing", forKey:"animId")
			completionAnim.setValue(false, forKey:"needEndAnim")
			layer!.add(completionAnim, forKey:"finishSyncing")
			if let anim = layer!.animation(forKey: "finishSyncing"){
				completionBlocks[anim] = completionBlock
			}
		}
		
		let fillMode : String = kCAFillModeForwards
        
        ////Spin animation
        let spinTransformAnim            = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        spinTransformAnim.values         = [0, 360 * (CGFloat.pi/180)]
        spinTransformAnim.keyTimes       = [0, 1]
        spinTransformAnim.duration       = 1.5
        spinTransformAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 0.5, 0.5, 1)
        
        let spinFinishSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [spinTransformAnim], fillMode:fillMode)
        layers["spin"]?.add(spinFinishSyncingAnim, forKey:"spinFinishSyncingAnim")
        
        ////Circle2 animation
        let circle2StrokeEndAnim            = CAKeyframeAnimation(keyPath:"strokeEnd")
        circle2StrokeEndAnim.values         = [0.75, 0.75]
        circle2StrokeEndAnim.keyTimes       = [0, 1]
        circle2StrokeEndAnim.duration       = 1.5
        circle2StrokeEndAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0, 0.2, 1)
        
        let circle2OpacityAnim      = CAKeyframeAnimation(keyPath:"opacity")
        circle2OpacityAnim.values   = [1, 1]
        circle2OpacityAnim.keyTimes = [0, 1]
        circle2OpacityAnim.duration = 1.5
        
        let circle2StrokeStartAnim      = CAKeyframeAnimation(keyPath:"strokeStart")
        circle2StrokeStartAnim.values   = [0, 0]
        circle2StrokeStartAnim.keyTimes = [0, 1]
        circle2StrokeStartAnim.duration = 1.5
        
        let circle2FinishSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [circle2StrokeEndAnim, circle2OpacityAnim, circle2StrokeStartAnim], fillMode:fillMode)
        layers["circle2"]?.add(circle2FinishSyncingAnim, forKey:"circle2FinishSyncingAnim")
        
        ////ArrowSpin animation
        let arrowSpinTransformAnim            = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        arrowSpinTransformAnim.values         = [0,
                                                 360 * (CGFloat.pi/180)]
        arrowSpinTransformAnim.keyTimes       = [0, 1]
        arrowSpinTransformAnim.duration       = 1.5
        arrowSpinTransformAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 0.5, 0.5, 1)
        
        let arrowSpinFinishSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [arrowSpinTransformAnim], fillMode:fillMode)
        layers["arrowSpin"]?.add(arrowSpinFinishSyncingAnim, forKey:"arrowSpinFinishSyncingAnim")
        
        ////Arrow animation
        let arrowTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        arrowTransformAnim.values         = [NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 1)),
                                             NSValue(caTransform3D: CATransform3DIdentity)]
        arrowTransformAnim.keyTimes       = [0, 1]
        arrowTransformAnim.duration       = 1.5
        arrowTransformAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 0.5, 0.5, 1)
        
        let arrowFinishSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [arrowTransformAnim], fillMode:fillMode)
        layers["arrow"]?.add(arrowFinishSyncingAnim, forKey:"arrowFinishSyncingAnim")
        
        ////MinuteHand animation
        let minuteHandTransformAnim            = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        minuteHandTransformAnim.values         = [833 * (CGFloat.pi/180), 0]
        minuteHandTransformAnim.keyTimes       = [0, 1]
        minuteHandTransformAnim.duration       = 1.15
        minuteHandTransformAnim.beginTime      = 1.25
        minuteHandTransformAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.645, 0.045, 0.355, 1)
        
        let minuteHandOpacityAnim       = CAKeyframeAnimation(keyPath:"opacity")
        minuteHandOpacityAnim.values    = [0, 1]
        minuteHandOpacityAnim.keyTimes  = [0, 1]
        minuteHandOpacityAnim.duration  = 0.4
        minuteHandOpacityAnim.beginTime = 1.5
        
        let minuteHandFinishSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [minuteHandTransformAnim, minuteHandOpacityAnim], fillMode:fillMode)
        layers["minuteHand"]?.add(minuteHandFinishSyncingAnim, forKey:"minuteHandFinishSyncingAnim")
        
        ////HourHand animation
        let hourHandTransformAnim            = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        hourHandTransformAnim.values         = [90 * (CGFloat.pi/180), 0]
        hourHandTransformAnim.keyTimes       = [0, 1]
        hourHandTransformAnim.duration       = 1.15
        hourHandTransformAnim.beginTime      = 1.25
        hourHandTransformAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.645, 0.045, 0.355, 1)
        
        let hourHandOpacityAnim       = CAKeyframeAnimation(keyPath:"opacity")
        hourHandOpacityAnim.values    = [0, 1]
        hourHandOpacityAnim.keyTimes  = [0, 1]
        hourHandOpacityAnim.duration  = 0.4
        hourHandOpacityAnim.beginTime = 1.5
        
        let hourHandFinishSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [hourHandTransformAnim, hourHandOpacityAnim], fillMode:fillMode)
        layers["hourHand"]?.add(hourHandFinishSyncingAnim, forKey:"hourHandFinishSyncingAnim")
    }
	
	public func addStartSyncingAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
		if completionBlock != nil{
			let completionAnim = CABasicAnimation(keyPath:"completionAnim")
			completionAnim.duration = 1.5
			completionAnim.delegate = self
			completionAnim.setValue("startSyncing", forKey:"animId")
			completionAnim.setValue(false, forKey:"needEndAnim")
			layer!.add(completionAnim, forKey:"startSyncing")
			if let anim = layer!.animation(forKey: "startSyncing"){
				completionBlocks[anim] = completionBlock
			}
		}
		
		let fillMode : String = kCAFillModeRemoved
		
        ////Spin animation
        let spinTransformAnim      = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        spinTransformAnim.values   = [0, 360 * (CGFloat.pi/180)]
        spinTransformAnim.keyTimes = [0, 1]
        spinTransformAnim.duration = 1.5
        
        let spinStartSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [spinTransformAnim], fillMode:fillMode)
        layers["spin"]?.add(spinStartSyncingAnim, forKey:"spinStartSyncingAnim")
        
        ////Circle animation
        let circleStrokeStartAnim            = CAKeyframeAnimation(keyPath:"strokeStart")
        circleStrokeStartAnim.values         = [0.973, 0.25]
        circleStrokeStartAnim.keyTimes       = [0, 1]
        circleStrokeStartAnim.duration       = 0.75
        circleStrokeStartAnim.beginTime      = 0.75
        circleStrokeStartAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        
        let circleTransformAnim            = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        circleTransformAnim.values         = [-190 * (CGFloat.pi/180), -90 * (CGFloat.pi/180)]
        circleTransformAnim.keyTimes       = [0, 1]
        circleTransformAnim.duration       = 0.75
        circleTransformAnim.beginTime      = 0.75
        circleTransformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        
        let circleStrokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        circleStrokeEndAnim.values   = [0.998, 0.998, 1]
        circleStrokeEndAnim.keyTimes = [0, 0.5, 1]
        circleStrokeEndAnim.duration = 1.5
        
        let circleOpacityAnim       = CAKeyframeAnimation(keyPath:"opacity")
        circleOpacityAnim.values    = [1, 1]
        circleOpacityAnim.keyTimes  = [0, 1]
        circleOpacityAnim.duration  = 0.75
        circleOpacityAnim.beginTime = 0.75
        
        let circleStartSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [circleStrokeStartAnim, circleTransformAnim, circleStrokeEndAnim, circleOpacityAnim], fillMode:fillMode)
        layers["circle"]?.add(circleStartSyncingAnim, forKey:"circleStartSyncingAnim")
        
        ////Circle2 animation
        let circle2StrokeEndAnim            = CAKeyframeAnimation(keyPath:"strokeEnd")
        circle2StrokeEndAnim.values         = [0.75, 0.025]
        circle2StrokeEndAnim.keyTimes       = [0, 1]
        circle2StrokeEndAnim.duration       = 0.75
        circle2StrokeEndAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        
        let circle2StrokeStartAnim      = CAKeyframeAnimation(keyPath:"strokeStart")
        circle2StrokeStartAnim.values   = [0, 0]
        circle2StrokeStartAnim.keyTimes = [0, 1]
        circle2StrokeStartAnim.duration = 1.5
        
        let circle2TransformAnim      = CAKeyframeAnimation(keyPath:"transform")
        circle2TransformAnim.values   = [NSValue(caTransform3D: CATransform3DMakeRotation(-180 * (CGFloat.pi/180), 0, 0, 1)),
                                         NSValue(caTransform3D: CATransform3DMakeRotation(-180 * (CGFloat.pi/180), 0, 0, 1))]
        circle2TransformAnim.keyTimes = [0, 1]
        circle2TransformAnim.duration = 1.5
        
        let circle2OpacityAnim       = CAKeyframeAnimation(keyPath:"opacity")
        circle2OpacityAnim.values    = [0, 0]
        circle2OpacityAnim.keyTimes  = [0, 1]
        circle2OpacityAnim.duration  = 0.75
        circle2OpacityAnim.beginTime = 0.75
        
        let circle2StartSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [circle2StrokeEndAnim, circle2StrokeStartAnim, circle2TransformAnim, circle2OpacityAnim], fillMode:fillMode)
        layers["circle2"]?.add(circle2StartSyncingAnim, forKey:"circle2StartSyncingAnim")
        
        ////ArrowSpin animation
        let arrowSpinTransformAnim      = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        arrowSpinTransformAnim.values   = [0, 360 * (CGFloat.pi/180)]
        arrowSpinTransformAnim.keyTimes = [0, 1]
        arrowSpinTransformAnim.duration = 1.5
        
        let arrowSpinStartSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [arrowSpinTransformAnim], fillMode:fillMode)
        layers["arrowSpin"]?.add(arrowSpinStartSyncingAnim, forKey:"arrowSpinStartSyncingAnim")
        
        ////ArrowSpinAgain animation
        let arrowSpinAgainTransformAnim       = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        arrowSpinAgainTransformAnim.values    = [0, -90 * (CGFloat.pi/180)]
        arrowSpinAgainTransformAnim.keyTimes  = [0, 1]
        arrowSpinAgainTransformAnim.duration  = 0.75
        arrowSpinAgainTransformAnim.beginTime = 0.75
        arrowSpinAgainTransformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        
        let arrowSpinAgainStartSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [arrowSpinAgainTransformAnim], fillMode:fillMode)
        layers["arrowSpinAgain"]?.add(arrowSpinAgainStartSyncingAnim, forKey:"arrowSpinAgainStartSyncingAnim")
        
        ////ArrowFinalSpin animation
        let arrowFinalSpinTransformAnim       = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        arrowFinalSpinTransformAnim.values    = [0, 450 * (CGFloat.pi/180)]
        arrowFinalSpinTransformAnim.keyTimes  = [0, 1]
        arrowFinalSpinTransformAnim.duration  = 0.75
        arrowFinalSpinTransformAnim.beginTime = 0.75
        arrowFinalSpinTransformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        
        let arrowFinalSpinStartSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [arrowFinalSpinTransformAnim], fillMode:fillMode)
        layers["arrowFinalSpin"]?.add(arrowFinalSpinStartSyncingAnim, forKey:"arrowFinalSpinStartSyncingAnim")
        
        ////Arrow animation
        let arrowTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        arrowTransformAnim.values         = [NSValue(caTransform3D: CATransform3DIdentity),
                                             NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 1))]
        arrowTransformAnim.keyTimes       = [0, 1]
        arrowTransformAnim.duration       = 0.75
        arrowTransformAnim.beginTime      = 0.75
        arrowTransformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        
        let arrowStartSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [arrowTransformAnim], fillMode:kCAFillModeForwards)
        layers["arrow"]?.add(arrowStartSyncingAnim, forKey:"arrowStartSyncingAnim")
        
        ////Clock animation
        let clockTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        clockTransformAnim.values         = [NSValue(caTransform3D: CATransform3DIdentity),
                                             NSValue(caTransform3D: CATransform3DMakeScale(0.42, 0.42, 1))]
        clockTransformAnim.keyTimes       = [0, 1]
        clockTransformAnim.duration       = 1.12
        clockTransformAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
        
        let clockStartSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [clockTransformAnim], fillMode:fillMode)
        layers["clock"]?.add(clockStartSyncingAnim, forKey:"clockStartSyncingAnim")
        
        ////MinuteHand animation
        let minuteHandTransformAnim            = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        minuteHandTransformAnim.values         = [0, -1800 * (CGFloat.pi/180)]
        minuteHandTransformAnim.keyTimes       = [0, 1]
        minuteHandTransformAnim.duration       = 1.12
        minuteHandTransformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
        minuteHandTransformAnim.fillMode       = kCAFillModeRemoved
        minuteHandTransformAnim.isRemovedOnCompletion = true
        
        let minuteHandOpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
        minuteHandOpacityAnim.values         = [1, 0]
        minuteHandOpacityAnim.keyTimes       = [0, 1]
        minuteHandOpacityAnim.duration       = 1.5
        minuteHandOpacityAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
        
        let minuteHandStartSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [minuteHandTransformAnim, minuteHandOpacityAnim], fillMode:kCAFillModeForwards)
        layers["minuteHand"]?.add(minuteHandStartSyncingAnim, forKey:"minuteHandStartSyncingAnim")
        
        ////HourHand animation
        let hourHandTransformAnim            = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        hourHandTransformAnim.values         = [0, -360 * (CGFloat.pi/180)]
        hourHandTransformAnim.keyTimes       = [0, 1]
        hourHandTransformAnim.duration       = 1.12
        hourHandTransformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
        hourHandTransformAnim.fillMode       = kCAFillModeRemoved
        hourHandTransformAnim.isRemovedOnCompletion = true
        
        let hourHandOpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
        hourHandOpacityAnim.values         = [1, 0]
        hourHandOpacityAnim.keyTimes       = [0, 1]
        hourHandOpacityAnim.duration       = 1.5
        hourHandOpacityAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
        
        let hourHandStartSyncingAnim : CAAnimationGroup = QCMethod.group(animations: [hourHandTransformAnim, hourHandOpacityAnim], fillMode:kCAFillModeForwards)
        layers["hourHand"]?.add(hourHandStartSyncingAnim, forKey:"hourHandStartSyncingAnim")
    }
	
	//MARK: - Animation Cleanup
	
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool){
        if let completionBlock = completionBlocks[anim]{
            completionBlocks.removeValue(forKey: anim)
            if (flag && updateLayerValueForCompletedAnimation) || anim.value(forKey: "needEndAnim") as! Bool{
                updateLayerValues(forAnimationId: anim.value(forKey: "animId") as! String)
                removeAnimations(forAnimationId: anim.value(forKey: "animId") as! String)
            }
            completionBlock(flag)
        }
    }
    
    public func updateLayerValues(forAnimationId identifier: String){
        if identifier == "syncing"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["spin"] as! CALayer).animation(forKey: "spinSyncingAnim"), theLayer:(layers["spin"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["circle"] as! CALayer).animation(forKey: "circleSyncingAnim"), theLayer:(layers["circle"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["circle2"] as! CALayer).animation(forKey: "circle2SyncingAnim"), theLayer:(layers["circle2"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["arrowSpin"] as! CALayer).animation(forKey: "arrowSpinSyncingAnim"), theLayer:(layers["arrowSpin"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["clock"] as! CALayer).animation(forKey: "clockSyncingAnim"), theLayer:(layers["clock"] as! CALayer))
        }
        else if identifier == "finishSyncing"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["spin"] as! CALayer).animation(forKey: "spinFinishSyncingAnim"), theLayer:(layers["spin"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["circle2"] as! CALayer).animation(forKey: "circle2FinishSyncingAnim"), theLayer:(layers["circle2"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["arrowSpin"] as! CALayer).animation(forKey: "arrowSpinFinishSyncingAnim"), theLayer:(layers["arrowSpin"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["arrow"] as! CALayer).animation(forKey: "arrowFinishSyncingAnim"), theLayer:(layers["arrow"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["clock"] as! CALayer).animation(forKey: "clockFinishSyncingAnim"), theLayer:(layers["clock"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["minuteHand"] as! CALayer).animation(forKey: "minuteHandFinishSyncingAnim"), theLayer:(layers["minuteHand"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["hourHand"] as! CALayer).animation(forKey: "hourHandFinishSyncingAnim"), theLayer:(layers["hourHand"] as! CALayer))
        }
        else if identifier == "startSyncing"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["spin"] as! CALayer).animation(forKey: "spinStartSyncingAnim"), theLayer:(layers["spin"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["circle"] as! CALayer).animation(forKey: "circleStartSyncingAnim"), theLayer:(layers["circle"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["circle2"] as! CALayer).animation(forKey: "circle2StartSyncingAnim"), theLayer:(layers["circle2"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["arrowSpin"] as! CALayer).animation(forKey: "arrowSpinStartSyncingAnim"), theLayer:(layers["arrowSpin"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["arrowSpinAgain"] as! CALayer).animation(forKey: "arrowSpinAgainStartSyncingAnim"), theLayer:(layers["arrowSpinAgain"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["arrowFinalSpin"] as! CALayer).animation(forKey: "arrowFinalSpinStartSyncingAnim"), theLayer:(layers["arrowFinalSpin"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["arrow"] as! CALayer).animation(forKey: "arrowStartSyncingAnim"), theLayer:(layers["arrow"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["clock"] as! CALayer).animation(forKey: "clockStartSyncingAnim"), theLayer:(layers["clock"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["minuteHand"] as! CALayer).animation(forKey: "minuteHandStartSyncingAnim"), theLayer:(layers["minuteHand"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["hourHand"] as! CALayer).animation(forKey: "hourHandStartSyncingAnim"), theLayer:(layers["hourHand"] as! CALayer))
        }
    }
    
    public func removeAnimations(forAnimationId identifier: String){
        if identifier == "syncing"{
            (layers["spin"] as! CALayer).removeAnimation(forKey: "spinSyncingAnim")
            (layers["circle"] as! CALayer).removeAnimation(forKey: "circleSyncingAnim")
            (layers["circle2"] as! CALayer).removeAnimation(forKey: "circle2SyncingAnim")
            (layers["arrowSpin"] as! CALayer).removeAnimation(forKey: "arrowSpinSyncingAnim")
            (layers["clock"] as! CALayer).removeAnimation(forKey: "clockSyncingAnim")
        }
        else if identifier == "finishSyncing"{
            (layers["spin"] as! CALayer).removeAnimation(forKey: "spinFinishSyncingAnim")
            (layers["circle2"] as! CALayer).removeAnimation(forKey: "circle2FinishSyncingAnim")
            (layers["arrowSpin"] as! CALayer).removeAnimation(forKey: "arrowSpinFinishSyncingAnim")
            (layers["arrow"] as! CALayer).removeAnimation(forKey: "arrowFinishSyncingAnim")
            (layers["clock"] as! CALayer).removeAnimation(forKey: "clockFinishSyncingAnim")
            (layers["minuteHand"] as! CALayer).removeAnimation(forKey: "minuteHandFinishSyncingAnim")
            (layers["hourHand"] as! CALayer).removeAnimation(forKey: "hourHandFinishSyncingAnim")
        }
        else if identifier == "startSyncing"{
            (layers["spin"] as! CALayer).removeAnimation(forKey: "spinStartSyncingAnim")
            (layers["circle"] as! CALayer).removeAnimation(forKey: "circleStartSyncingAnim")
            (layers["circle2"] as! CALayer).removeAnimation(forKey: "circle2StartSyncingAnim")
            (layers["arrowSpin"] as! CALayer).removeAnimation(forKey: "arrowSpinStartSyncingAnim")
            (layers["arrowSpinAgain"] as! CALayer).removeAnimation(forKey: "arrowSpinAgainStartSyncingAnim")
            (layers["arrowFinalSpin"] as! CALayer).removeAnimation(forKey: "arrowFinalSpinStartSyncingAnim")
            (layers["arrow"] as! CALayer).removeAnimation(forKey: "arrowStartSyncingAnim")
            (layers["clock"] as! CALayer).removeAnimation(forKey: "clockStartSyncingAnim")
            (layers["minuteHand"] as! CALayer).removeAnimation(forKey: "minuteHandStartSyncingAnim")
            (layers["hourHand"] as! CALayer).removeAnimation(forKey: "hourHandStartSyncingAnim")
        }
    }
    
    public func removeAllAnimations(){
        for layer in layers.values{
            (layer as! CALayer).removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func circlePath() -> NSBezierPath{
        let circlePath = NSBezierPath()
        circlePath.move(to: CGPoint(x: 14.34, y: 7.17))
        circlePath.curve(to: CGPoint(x: 7.17, y: 0), controlPoint1:CGPoint(x: 14.34, y: 3.21), controlPoint2:CGPoint(x: 11.13, y: 0))
        circlePath.curve(to: CGPoint(x: 0, y: 7.17), controlPoint1:CGPoint(x: 3.21, y: 0), controlPoint2:CGPoint(x: 0, y: 3.21))
        circlePath.curve(to: CGPoint(x: 7.17, y: 14.34), controlPoint1:CGPoint(x: 0, y: 11.13), controlPoint2:CGPoint(x: 3.21, y: 14.34))
        circlePath.curve(to: CGPoint(x: 14.34, y: 7.17), controlPoint1:CGPoint(x: 11.13, y: 14.34), controlPoint2:CGPoint(x: 14.34, y: 11.13))
        circlePath.close()
        circlePath.move(to: CGPoint(x: 14.34, y: 7.17))
        
        return circlePath
    }
    
    func circle2Path() -> NSBezierPath{
        let circle2Path = NSBezierPath()
        circle2Path.move(to: CGPoint(x: 14.34, y: 7.17))
        circle2Path.curve(to: CGPoint(x: 7.17, y: 0), controlPoint1:CGPoint(x: 14.34, y: 3.21), controlPoint2:CGPoint(x: 11.13, y: 0))
        circle2Path.curve(to: CGPoint(x: 0, y: 7.17), controlPoint1:CGPoint(x: 3.21, y: 0), controlPoint2:CGPoint(x: 0, y: 3.21))
        circle2Path.curve(to: CGPoint(x: 7.17, y: 14.34), controlPoint1:CGPoint(x: 0, y: 11.13), controlPoint2:CGPoint(x: 3.21, y: 14.34))
        circle2Path.curve(to: CGPoint(x: 14.34, y: 7.17), controlPoint1:CGPoint(x: 11.13, y: 14.34), controlPoint2:CGPoint(x: 14.34, y: 11.13))
        circle2Path.close()
        circle2Path.move(to: CGPoint(x: 14.34, y: 7.17))
        
        return circle2Path
    }
    
    func arrowPath() -> NSBezierPath{
        let arrowPath = NSBezierPath()
        arrowPath.move(to: CGPoint(x: 5.395, y: 4.329))
        arrowPath.curve(to: CGPoint(x: 5.718, y: 4.126), controlPoint1:CGPoint(x: 5.532, y: 4.327), controlPoint2:CGPoint(x: 5.657, y: 4.248))
        arrowPath.curve(to: CGPoint(x: 5.69, y: 3.745), controlPoint1:CGPoint(x: 5.78, y: 4.004), controlPoint2:CGPoint(x: 5.769, y: 3.857))
        arrowPath.line(to: CGPoint(x: 3.174, y: 0.155))
        arrowPath.curve(to: CGPoint(x: 2.879, y: 0), controlPoint1:CGPoint(x: 3.107, y: 0.058), controlPoint2:CGPoint(x: 2.997, y: 0))
        arrowPath.curve(to: CGPoint(x: 2.584, y: 0.155), controlPoint1:CGPoint(x: 2.761, y: 0), controlPoint2:CGPoint(x: 2.651, y: 0.058))
        arrowPath.line(to: CGPoint(x: 0.068, y: 3.745))
        arrowPath.curve(to: CGPoint(x: 0.04, y: 4.126), controlPoint1:CGPoint(x: -0.011, y: 3.857), controlPoint2:CGPoint(x: -0.022, y: 4.004))
        arrowPath.curve(to: CGPoint(x: 0.363, y: 4.329), controlPoint1:CGPoint(x: 0.102, y: 4.248), controlPoint2:CGPoint(x: 0.226, y: 4.327))
        arrowPath.line(to: CGPoint(x: 5.395, y: 4.329))
        arrowPath.close()
        arrowPath.move(to: CGPoint(x: 5.395, y: 4.329))
        
        return arrowPath
    }
    
    func hiddenArrowPath() -> NSBezierPath{
        let hiddenArrowPath = NSBezierPath()
        hiddenArrowPath.move(to: CGPoint(x: 5.395, y: 4.329))
        hiddenArrowPath.curve(to: CGPoint(x: 5.718, y: 4.126), controlPoint1:CGPoint(x: 5.532, y: 4.327), controlPoint2:CGPoint(x: 5.657, y: 4.248))
        hiddenArrowPath.curve(to: CGPoint(x: 5.69, y: 3.745), controlPoint1:CGPoint(x: 5.78, y: 4.004), controlPoint2:CGPoint(x: 5.769, y: 3.857))
        hiddenArrowPath.line(to: CGPoint(x: 3.174, y: 0.155))
        hiddenArrowPath.curve(to: CGPoint(x: 2.879, y: 0), controlPoint1:CGPoint(x: 3.107, y: 0.058), controlPoint2:CGPoint(x: 2.997, y: 0))
        hiddenArrowPath.curve(to: CGPoint(x: 2.584, y: 0.155), controlPoint1:CGPoint(x: 2.761, y: 0), controlPoint2:CGPoint(x: 2.651, y: 0.058))
        hiddenArrowPath.line(to: CGPoint(x: 0.068, y: 3.745))
        hiddenArrowPath.curve(to: CGPoint(x: 0.04, y: 4.126), controlPoint1:CGPoint(x: -0.011, y: 3.857), controlPoint2:CGPoint(x: -0.022, y: 4.004))
        hiddenArrowPath.curve(to: CGPoint(x: 0.363, y: 4.329), controlPoint1:CGPoint(x: 0.102, y: 4.248), controlPoint2:CGPoint(x: 0.226, y: 4.327))
        hiddenArrowPath.line(to: CGPoint(x: 5.395, y: 4.329))
        hiddenArrowPath.close()
        hiddenArrowPath.move(to: CGPoint(x: 5.395, y: 4.329))
        
        return hiddenArrowPath
    }
    
    func minuteHandPath() -> NSBezierPath{
        let minuteHandPath = NSBezierPath()
        minuteHandPath.move(to: CGPoint(x: 2.09, y: 1.045))
        minuteHandPath.curve(to: CGPoint(x: 1.045, y: 0), controlPoint1:CGPoint(x: 2.09, y: 0.468), controlPoint2:CGPoint(x: 1.622, y: 0))
        minuteHandPath.curve(to: CGPoint(x: 0, y: 1.045), controlPoint1:CGPoint(x: 0.468, y: 0), controlPoint2:CGPoint(x: 0, y: 0.468))
        minuteHandPath.curve(to: CGPoint(x: 0.002, y: 1.109), controlPoint1:CGPoint(x: 0, y: 1.067), controlPoint2:CGPoint(x: 0.001, y: 1.088))
        minuteHandPath.curve(to: CGPoint(x: 0.535, y: 5.956), controlPoint1:CGPoint(x: 0, y: 1.11), controlPoint2:CGPoint(x: 0.529, y: 5.897))
        minuteHandPath.curve(to: CGPoint(x: 1.045, y: 6.413), controlPoint1:CGPoint(x: 0.564, y: 6.216), controlPoint2:CGPoint(x: 0.784, y: 6.413))
        minuteHandPath.curve(to: CGPoint(x: 1.555, y: 5.956), controlPoint1:CGPoint(x: 1.306, y: 6.413), controlPoint2:CGPoint(x: 1.526, y: 6.216))
        minuteHandPath.line(to: CGPoint(x: 2.09, y: 1.11))
        minuteHandPath.curve(to: CGPoint(x: 2.09, y: 1.045), controlPoint1:CGPoint(x: 2.089, y: 1.088), controlPoint2:CGPoint(x: 2.09, y: 1.067))
        minuteHandPath.close()
        minuteHandPath.move(to: CGPoint(x: 2.09, y: 1.045))
        
        return minuteHandPath
    }
    
    func hourHandPath() -> NSBezierPath{
        let hourHandPath = NSBezierPath()
        hourHandPath.move(to: CGPoint(x: 0.579, y: 1.241))
        hourHandPath.curve(to: CGPoint(x: 0, y: 2.177), controlPoint1:CGPoint(x: 0.236, y: 1.412), controlPoint2:CGPoint(x: 0, y: 1.767))
        hourHandPath.curve(to: CGPoint(x: 1.045, y: 3.222), controlPoint1:CGPoint(x: 0, y: 2.754), controlPoint2:CGPoint(x: 0.468, y: 3.222))
        hourHandPath.curve(to: CGPoint(x: 1.622, y: 3.048), controlPoint1:CGPoint(x: 1.258, y: 3.222), controlPoint2:CGPoint(x: 1.457, y: 3.158))
        hourHandPath.line(to: CGPoint(x: 1.624, y: 3.049))
        hourHandPath.line(to: CGPoint(x: 1.641, y: 3.035))
        hourHandPath.curve(to: CGPoint(x: 1.765, y: 2.934), controlPoint1:CGPoint(x: 1.685, y: 3.005), controlPoint2:CGPoint(x: 1.726, y: 2.971))
        hourHandPath.curve(to: CGPoint(x: 4.232, y: 0.927), controlPoint1:CGPoint(x: 2.303, y: 2.495), controlPoint2:CGPoint(x: 4.19, y: 0.957))
        hourHandPath.curve(to: CGPoint(x: 4.372, y: 0.257), controlPoint1:CGPoint(x: 4.443, y: 0.772), controlPoint2:CGPoint(x: 4.503, y: 0.483))
        hourHandPath.curve(to: CGPoint(x: 3.722, y: 0.043), controlPoint1:CGPoint(x: 4.242, y: 0.03), controlPoint2:CGPoint(x: 3.961, y: -0.062))
        hourHandPath.line(to: CGPoint(x: 0.752, y: 1.173))
        hourHandPath.curve(to: CGPoint(x: 0.598, y: 1.232), controlPoint1:CGPoint(x: 0.698, y: 1.189), controlPoint2:CGPoint(x: 0.647, y: 1.209))
        hourHandPath.line(to: CGPoint(x: 0.579, y: 1.239))
        hourHandPath.line(to: CGPoint(x: 0.579, y: 1.241))
        hourHandPath.line(to: CGPoint(x: 0.579, y: 1.241))
        hourHandPath.close()
        hourHandPath.move(to: CGPoint(x: 0.579, y: 1.241))
        
        return hourHandPath
    }
    
    
}
