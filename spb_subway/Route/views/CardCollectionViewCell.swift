//
//  CardCollectionViewCell.swift
//  spb_subway
//
//  Created by m.shirokova on 15.12.2022.
//

import UIKit

final class CardCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "CardCollectionViewCell"
    
    var routeWatcher: RouteWatcher?
    var mapDelegate: MapViewDelegate?
    var route: Route?
    var subway: Subway?
    let timeView = UIView()
    let transfersView = UIView()
    let timeLabel = UILabel()
    let transferLabel = UILabel()
    var subwayNumberLabels = [UILabel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureFrames()
        configureAppearance()
        self.addSubview(timeView)
        self.addSubview(transfersView)
        self.isUserInteractionEnabled = true
    }
    
    private func configureFrames() {
        let leftPadding = 30.0
        let width = self.bounds.width
        let height = self.bounds.height / 2
        timeView.frame = CGRect(
            x: leftPadding,
            y: 0,
            width: width,
            height: height
        )
        transfersView.frame = CGRect(
            x: leftPadding,
            y: height,
            width: width,
            height: height
        )
        timeLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: timeView.bounds.width,
            height: timeView.bounds.height
        )
        transferLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: width / 2,
            height: 20.0
        )
    }
    
    private func configureAppearance() {
        guard let route = route, let subway = subway else {
            return
        }
        if !subwayNumberLabels.isEmpty {
            for label in subwayNumberLabels {
                label.removeFromSuperview()
            }
            subwayNumberLabels.removeAll()
        }
        self.layer.borderColor = Colors.backgroundColor.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = AttributesConstants.cornerRadius
        self.clipsToBounds = true
        
        let size = 20.0
        var delay = 0.0
        let time = Int(route.time ?? 0.0)
        timeLabel.text = "\(time) минут в пути"
        timeLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        transferLabel.text = (route.segments.count - 1).transferCountToString()
        transferLabel.font = transferLabel.font.withSize(MapSettings.fontLargeSize)
        delay = transferLabel.bounds.width
        timeView.addSubview(timeLabel)
        transfersView.addSubview(transferLabel)
        for (index, segment) in route.segments.enumerated() {
            let label = UILabel()
            let line = subway.getLineById(segment.lineId)
            let text = line?.number == nil ? nil : String((line?.number)!)
            label.text = text
            label.textAlignment = .center
            label.textColor = Colors.textColor
            label.backgroundColor = line?.color
            label.frame = CGRect(
                x: delay,
                y: 0,
                width: size,
                height: size
            )
            label.layer.cornerRadius = AttributesConstants.cornerRadius
            label.clipsToBounds = true
            subwayNumberLabels.append(label)
            transfersView.addSubview(label)
            delay += size
            if index < route.segments.count - 1 {
                let label = UILabel()
                label.frame = CGRect(
                    x: delay,
                    y: 0,
                    width: size,
                    height: size
                )
                label.textAlignment = .center
                label.text = Symbols.whiteTriangle
                label.textColor = Colors.backgroundColor
                subwayNumberLabels.append(label)
                transfersView.addSubview(label)
            }
            delay += size
        }
    }
    
    private func addGestures() {
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeCard(_:)))
        swipeGestureLeft.direction = .left
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeCard(_:)))
        swipeGestureRight.direction = .right
        self.addGestureRecognizer(swipeGestureLeft)
        self.addGestureRecognizer(swipeGestureRight)
    }
    
    @objc private func didSwipeCard(_ gesture: UISwipeGestureRecognizer) {
        guard
            let routeWatcher = routeWatcher,
            routeWatcher.routes.count > 1
        else {
            return
        }
        let maxRouteId = routeWatcher.routes.count - 1
        if gesture.direction == .left {
            if routeWatcher.routeId == maxRouteId {
                routeWatcher.updateRoute(id: 0)
            } else {
                routeWatcher.updateRoute(value: 1)
            }
        } else if gesture.direction == .right {
            if routeWatcher.routeId == 0 {
                routeWatcher.updateRoute(id: maxRouteId)
            } else {
                routeWatcher.updateRoute(value: -1)
            }
        } else {
            return
        }
        mapDelegate?.updateRouteInfo()
    }
}

extension Int {
    
    fileprivate func transferCountToString() -> String {
        switch(self) {
        case 0:
            return "без пересадок: "
        case 1:
            return "с \(self) пересадкой: "
        default:
            return "с \(self) пересадками: "
        }
    }
}
