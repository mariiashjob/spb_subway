//
//  MapView.swift
//  spb_subway
//
//  Created by m.shirokova on 17.11.2022.
//

import UIKit

class MapView: UIView {
    
    private lazy var width = self.bounds.width
    private lazy var height = self.bounds.height
    private lazy var lines = Subway.lines(width: width, height: height)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = .white
        self.layer.cornerRadius = AttributesConstants.cornerRadius
        self.clipsToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        for line in lines {
            context
                .setAttributes(color: line.color)
                .drawLine(points: line.points)
        }
    }
}
