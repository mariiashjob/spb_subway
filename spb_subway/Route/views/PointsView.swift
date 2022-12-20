//
//  PointCollectionViewCell.swift
//  spb_subway
//
//  Created by m.shirokova on 18.12.2022.
//

import UIKit

final class PointsView: UIView {
    
    var routeWatcher: RouteWatcher?
    var superViewWidth: CGFloat = 0.0
    
    convenience init(_ routeWatcher: RouteWatcher?) {
        self.init(frame: CGRect.zero)
        self.routeWatcher = routeWatcher
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.superViewWidth = super.frame.width
        configure()
    }
    
    private func configure() {
        guard let routeWatcher = routeWatcher, routeWatcher.routes.count > 1 else {
            return
        }
        var x: CGFloat = CardsAttributes.pointWidth
        for (index, _) in routeWatcher.routes.enumerated() {
            let label = UILabel()
            label.frame = CGRect(
                x: x,
                y: 0,
                width: CardsAttributes.pointWidth,
                height: CardsAttributes.pointHeight
            )
            let isActive = index == routeWatcher.routeId
            label.layer.cornerRadius = CardsAttributes.pointWidth / 3
            label.clipsToBounds = true
            label.backgroundColor = isActive ? Colors.backgroundColor : Colors.textDisabledColor
            addSubview(label)
            x += CardsAttributes.pointWidth * 2
        }
        self.frame = CGRect(
            x: superViewWidth/2 - x/2,
            y: 0,
            width: x,
            height: CardsAttributes.pointsViewHeight
        )
        layoutIfNeeded()
    }
}
