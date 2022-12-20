//
//  RoutesView.swift
//  spb_subway
//
//  Created by m.shirokova on 06.12.2022.
//

import UIKit
import Foundation

class RoutesView: UIView {
    
    var delegate: MapViewDelegate?
    var routeWatcher: RouteWatcher?
    var subway: Subway?
    var cardsView = UIView()
    var detailsScrollView = UIScrollView()
    var isFooterUp: Bool = false
    lazy var routeDetailsView = RouteDetailsView(routeWatcher)
    lazy var pointsView = PointsView(routeWatcher)
    lazy var cardsCollectionView = CardsUICollectionView()
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    convenience init(routeWatcher: RouteWatcher?) {
        self.init(frame: .zero)
        self.routeWatcher = routeWatcher
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.width = superview?.frame.width ?? 300.0
        self.height = superview?.frame.height ?? 100.0
        configure()
    }
    
    private func configure() {
        configureFrames()
        configureCardsView()
        configureRouteDetailsView()
    }
    
    private func configureCardsView() {
        self.addSubview(cardsView)
    }
    
    private func configurePointsView() {
        pointsView.removeFromSuperview()
        pointsView = PointsView(routeWatcher)
        addSubview(pointsView)
    }
    
    private func configureRouteDetailsView() {
        if self.isFooterUp {
            detailsScrollView.addSubview(routeDetailsView)
            detailsScrollView.contentSize = CGSize(width: self.bounds.width, height: routeDetailsView.bounds.height)
            addSubview(detailsScrollView)
            detailsScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    func updateRouteInfo(subway: Subway?, routeId: Int, isFooterUp: Bool) {
        guard  let routeWatcher = self.routeWatcher else {
            return
        }
        if isFooterUp {
            self.isFooterUp = isFooterUp
        }
        if routeWatcher.routeId == 0 {
            cardsCollectionView.removeFromSuperview()
            cardsCollectionView = CardsUICollectionView(
                routeWatcher: routeWatcher,
                subway: subway,
                mapDelegate: delegate)
            cardsView.addSubview(cardsCollectionView)
        }
        configurePointsView()
        layoutSubviews()
    }
    
    private func configureFrames() {
        self.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height)
        pointsView.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: CardsAttributes.pointsViewHeight)
        cardsView.frame = CGRect(
            x: 0,
            y: CardsAttributes.pointsViewHeight,
            width: width,
            height: height)
        detailsScrollView.frame = CGRect(
            x: 0,
            y: cardsCollectionView.bounds.maxY + AttributesConstants.spacing,
            width: self.bounds.width,
            height: UIScreen.main.bounds.height * 0.6)
        cardsCollectionView.frame = CGRect(
            x: 0,
            y: 0,
            width:
                width,
            height: 100.0)
    }
}
