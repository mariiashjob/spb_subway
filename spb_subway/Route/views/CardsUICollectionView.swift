//
//  CardsView.swift
//  spb_subway
//
//  Created by m.shirokova on 14.12.2022.
//

import UIKit

final class CardsUICollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var subway: Subway?
    var routeWatcher: RouteWatcher?
    var mapDelegate: MapViewDelegate?
    var isCardViewSet: Bool = false
    
    init(routeWatcher: RouteWatcher? = nil, subway: Subway? = nil, mapDelegate: MapViewDelegate? = nil) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        
        self.showsHorizontalScrollIndicator = false
        self.isPagingEnabled = true
        self.isUserInteractionEnabled = true
        self.routeWatcher = routeWatcher
        self.subway = subway
        self.mapDelegate = mapDelegate
        delegate = self
        dataSource = self
        register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionViewCell.reuseId)
        layout.minimumLineSpacing = CardsAttributes.minimumLineSpacing
        contentInset = UIEdgeInsets(
            top: CardsAttributes.topDistancetoView,
            left: CardsAttributes.leftDistancetoView,
            bottom: CardsAttributes.bottomDistancetoView,
            right: CardsAttributes.rightDistancetoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = nil
        //self.isUserInteractionEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return routeWatcher?.routes.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.reuseId, for: indexPath) as! CardCollectionViewCell
        cell.route = routeWatcher?.routes[indexPath.row]
        cell.subway = subway
        cell.routeWatcher = routeWatcher
        cell.mapDelegate = mapDelegate
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: CardsAttributes.cardHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isCardViewSet {
            routeWatcher?.updateRoute(id: indexPath.row)
            mapDelegate?.updateRouteInfo()
        } else {
            isCardViewSet = true
            return
        }
    }
}
