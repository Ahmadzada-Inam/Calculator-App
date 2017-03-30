//
//  ViewController.swift
//  JustAGraphCalc
//
//  Created by Inam Ahmad-zada on 2017-03-22.
//  Copyright © 2017 Inam Ahmad-zada. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    var yForX: ((_ x: Double) -> Double?)? {didSet{ updateUI()}}
    
    @IBOutlet weak var graphView: GraphView!{
        didSet{
            
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(GraphView.pinchToZoom(_:))))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: #selector(GraphView.panToMoveAround(_:))))
            graphView.addGestureRecognizer(UITapGestureRecognizer(target: graphView, action: #selector(GraphView.doubleTapToMoveOrigin(_:))))
            updateUI()
        }
    }
    
    func updateUI(){
        graphView?.yForX = yForX
    }
    
}

