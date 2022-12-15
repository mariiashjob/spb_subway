//
//  RoutesView.swift
//  spb_subway
//
//  Created by m.shirokova on 06.12.2022.
//

import UIKit
import Foundation

class RoutesView: UIView {
    
    let timeView = UIView()
    let timeLabel = UILabel()
    let transitsView = UIView()
    let transferLabel = UILabel()
    let detailsScrollView = UIScrollView()
    var subwayNumberLabels = [UILabel]()
    var routeWatcher: RouteWatcher?
    var subway: Subway?
    var isFooterUp: Bool = false
    lazy var cardsView = CardsView(routeWatcher)
    lazy var routeDetailsView = RouteDetailsView(routeWatcher)
    
    convenience init(routeWatcher: RouteWatcher?) {
        self.init(frame: CGRect.zero)
        self.routeWatcher = routeWatcher
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configure()
    }
    
    private func configure() {
        timeLabel.font = timeLabel.font.withSize(20.0)
        timeView.addSubview(timeLabel)
        transitsView.addSubview(transferLabel)
        configureFrames()
        configureCardsView()
        configureRouteDetailsView()
    }
    
    private func configureCardsView() {
        self.addSubview(cardsView)
    }
    
    private func configureRouteDetailsView() {
        if self.isFooterUp {
            routeDetailsView.alpha = 1
            detailsScrollView.addSubview(routeDetailsView)
            detailsScrollView.contentSize = CGSize(width: self.bounds.width, height: routeDetailsView.bounds.height)
            detailsScrollView.center = CGPoint(x: self.center.x, y: self.center.y + detailsScrollView.bounds.height / 2 + cardsView.bounds.height / 2)
            detailsScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            detailsScrollView.isUserInteractionEnabled = true
            self.addSubview(detailsScrollView)
        }
    }
    
    func updateRouteInfo(subway: Subway?, routeId: Int, isFooterUp: Bool) {
        if !subwayNumberLabels.isEmpty {
            for label in subwayNumberLabels {
                label.removeFromSuperview()
            }
            subwayNumberLabels.removeAll()
        }
        guard
            let routeWatcher = self.routeWatcher,
            let subway = subway
        else {
            return
        }
    
        cardsView.removeFromSuperview()
        cardsView =  CardsView(routeWatcher)
        self.addSubview(cardsView)
        
        let route = routeWatcher.routes[routeId]
        let size = 20.0
        var delay = 0.0
        let time = Int(route.time ?? 0.0)
        timeLabel.text = "\(time) минут в пути"
        timeLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        transferLabel.text = (route.segments.count - 1).transferCountToString()
        transferLabel.font = transferLabel.font.withSize(MapSettings.fontLargeSize)
        delay = transferLabel.bounds.width
        transitsView.addSubview(transferLabel)
        
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
            transitsView.addSubview(label)
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
                transitsView.addSubview(label)
            }
            delay += size
        }
        
        
        if isFooterUp {
            self.isFooterUp = isFooterUp
            layoutSubviews()
        }
    }
    
    private func configureFrames() {
        self.frame = CGRect(
            x: 0,
            y: 0,
            width: superview?.bounds.width ?? 0.0,
            height: superview?.bounds.height ?? 0.0)
        let arrangedSubviewWidth = self.bounds.width
        let arrangedSubviewHeight = self.bounds.height
        cardsView.frame = CGRect(
            x: 0,
            y: 0,
            width: arrangedSubviewWidth * 3,
            height: arrangedSubviewHeight)
        cardsView.center = self.center
        detailsScrollView.frame = CGRect(
            x: 0,
            y: arrangedSubviewHeight,
            width: arrangedSubviewWidth,
            height: 550.0) // TODO: needed to be calqulated
        
        timeLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: arrangedSubviewWidth / 2,
            height: 20.0)
        transferLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: arrangedSubviewWidth / 2,
            height: 20.0
        )
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
