//
//  KeepSwiping.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 08.05.23.
//

import UIKit

class KeepSwipingButton: UIButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let gradientLayer = CAGradientLayer()
        let leftColor = #colorLiteral(red: 0.9810560346, green: 0.159181565, blue: 0.4431154132, alpha: 1)
        let rightColor = #colorLiteral(red: 0.986747086, green: 0.3418981433, blue: 0.3349232674, alpha: 1)
        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        
        let cornerRadius = rect.height / 2
        
        let maskPath = CGMutablePath()
        maskPath.addPath(UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath)
        maskPath.addPath(UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: cornerRadius).cgPath)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath
        maskLayer.fillRule = .evenOdd
        
        gradientLayer.mask = maskLayer
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        gradientLayer.frame = rect
    }
}
