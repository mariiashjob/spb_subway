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
    
    init(routeWatcher: RouteWatcher?, subway: Subway?, mapDelegate: MapViewDelegate?) {
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
        layout.minimumLineSpacing = Constants.minimumLineSpacing
        contentInset = UIEdgeInsets(top: 0, left: Constants.leftDistancetoView, bottom: 0, right: Constants.rightDistancetoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = nil
        self.isUserInteractionEnabled = true
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
        return CGSize(width: super.bounds.width, height: 100.0)
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

struct Constants {
    static let leftDistancetoView: CGFloat = 0.0
    static let rightDistancetoView: CGFloat = 0.0
    static let minimumLineSpacing: CGFloat = 0.0
}
