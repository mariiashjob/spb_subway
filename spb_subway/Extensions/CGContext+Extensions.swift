//
//  CGContext+Extensions.swift
//  spb_subway
//
//  Created by m.shirokova on 17.11.2022.
//

import UIKit

extension CGContext {
    
    @discardableResult
    func setAttributes(color: UIColor?, alpha: CGFloat, width: CGFloat = MapSettings.lineWidth, cap: CGLineCap = MapSettings.lineCap) -> CGContext {
        
        if let color = color {
            self.setStrokeColor(color.cgColor)
        }
        self.setLineWidth(width)
        self.setLineCap(cap)
        self.setAlpha(alpha)
        return self
    }
    
    func drawLine(points: [CGPoint]) {
        for (index, point) in points.enumerated() {
            
            if index == 0 {
                self.move(to: point)
            } else {
                self.addLine(to: point)
            }
        }
        self.strokePath()
    }
}
