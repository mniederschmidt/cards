//
//  UIViewX.swift
//  FlashCards
//
//  Created by Mary Niederschmidt on 11/25/17.
//  Copyright © 2017 LaunchCode. All rights reserved.
//

import UIKit

class UIViewX: UIView {
    
    var firstColor: UIColor = UIColor.white {
        didSet {
            updateView()
        }
    }
    
    var secondColor: UIColor = UIColor.white {
        didSet {
            updateView()
        }
    }
    
    var horizontalGradient: Bool = false {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [ firstColor.cgColor, secondColor.cgColor]
        
        if (horizontalGradient) {
            layer.startPoint = CGPoint(x: 0.0, y: 0.5)
            layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        } else {
            layer.startPoint = CGPoint(x: 0, y: 0)
            layer.endPoint = CGPoint(x: 0, y: 1)
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
