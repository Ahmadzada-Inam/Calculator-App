//
//  GraphView.swift
//  JustAGraphCalc
//
//  Created by Inam Ahmad-zada on 2017-03-22.
//  Copyright © 2017 Inam Ahmad-zada. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    var yForX: ((_ x: Double) -> Double?)? {didSet{ setNeedsDisplay()}}
    
    private let axesDrawer = AxesDrawer(color: UIColor.blue)
    
    @IBInspectable
    var scale:CGFloat = 50.0 {didSet{ setNeedsDisplay() }}
    
    @IBInspectable
    var lineWidth:CGFloat = 2.0 {didSet{setNeedsDisplay()}}
    
    @IBInspectable
    var color: UIColor = UIColor.blue {didSet{ setNeedsDisplay() }}
    
    private var graphCenter:CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    var originRealtiveToCenter = CGPoint.zero { didSet{setNeedsDisplay()}}
    
    func drawCurveInRect(_ bounds: CGRect, origin: CGPoint, scale: CGFloat){
        color.set()
        var xGraph, yGraph: CGFloat
        
        var x: Double { return Double ((xGraph - origin.x) / scale)}
        
        var oldPoint = OldPoint(yGraph: 0.0, normal: false)
        var disContinuity: Bool {
            return abs(yGraph - oldPoint.yGraph) > (max(bounds.width, bounds.height) * 1.5)
        }
        
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        
        for i in 0...Int(bounds.size.width * contentScaleFactor){
            
            xGraph = CGFloat(i) * contentScaleFactor
            
            guard let y = (yForX)?(x) , y.isFinite else{ oldPoint.normal = false; continue }
            
            yGraph = origin.y - CGFloat(y) * scale
            
            if !oldPoint.normal {
                path.move(to: CGPoint(x: xGraph, y: yGraph))
            }else{
                guard !disContinuity else{ oldPoint = OldPoint(yGraph: yGraph, normal: false)
                    continue;}
                path.addLine(to: CGPoint(x: xGraph, y: yGraph))
            }
            oldPoint = OldPoint(yGraph: yGraph, normal: true)
        }
        path.stroke()
    }
    
    private struct OldPoint {
        var yGraph: CGFloat
        var normal: Bool
    }
    
    private var origin:CGPoint {
        get{
            var origin = originRealtiveToCenter
            origin.x += graphCenter.x
            origin.y += graphCenter.y
            return origin
        }
        set{
            var origin = newValue
            origin.x -= graphCenter.x
            origin.y -= graphCenter.y
            originRealtiveToCenter = origin
        }
    }
    
    private var snapshot: UIView?
    
    func pinchToZoom(_ gesture: UIPinchGestureRecognizer){
        switch gesture.state{
        case .began:
            snapshot = self.snapshotView(afterScreenUpdates: false)
            snapshot!.alpha = 0.8
            self.addSubview(snapshot!)
        case .changed:
            let touch = gesture.location(in: self)
            snapshot!.frame.size.height *= gesture.scale
            snapshot!.frame.size.width *= gesture.scale
            snapshot!.frame.origin.x = snapshot!.frame.origin.x * gesture.scale + (1 - gesture.scale) * touch.x
            snapshot!.frame.origin.y = snapshot!.frame.origin.y * gesture.scale + (1 - gesture.scale) * touch.y
            gesture.scale = 1.0
        case .ended:
            let changedScale = (snapshot!.frame.height / self.frame.height)
            scale *= changedScale
            origin.x = origin.x * changedScale + snapshot!.frame.origin.x
            origin.y = origin.y * changedScale + snapshot!.frame.origin.y
            snapshot!.removeFromSuperview()
            snapshot = nil
            setNeedsDisplay()
        default:
            break
        }
    }
    
    
    func panToMoveAround(_ gesture: UIPanGestureRecognizer){
        switch gesture.state{
        case .ended: fallthrough
        case .changed:
            let translation = gesture.translation(in: self)
            if !translation.equalTo(CGPoint.zero){
                origin.x += translation.x
                origin.y += translation.y
                gesture.setTranslation(CGPoint.zero, in: self)
            }
        default:
            break
        }
    }
    
    func doubleTapToMoveOrigin(_ gesture: UITapGestureRecognizer){
        gesture.numberOfTapsRequired = 2
        if gesture.state == .ended{
            let touch = gesture.location(in: self)
            origin = touch
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        axesDrawer.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale)
        drawCurveInRect(bounds, origin: origin, scale: scale)
    }
    
}
