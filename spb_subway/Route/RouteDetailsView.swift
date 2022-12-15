//
//  RouteDetailsView.swift
//  spb_subway
//
//  Created by m.shirokova on 08.12.2022.
//

import UIKit
import Foundation

class RouteDetailsView: UIView {
    
    var routeWatcher: RouteWatcher?
    var labels: [UILabel] = []
    var infoViews: [UIView] = []
    
    struct Point: Equatable {
        var name: String
        var color: UIColor?
        var coordinates: CGPoint
    }
    
    convenience init(_ routeWatcher: RouteWatcher?) {
        self.init(frame: CGRect.zero)
        self.routeWatcher = routeWatcher
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func redrawDetailedRoute(subway: Subway?, routeId: Int) {
        if !labels.isEmpty {
            for nameLabel in labels {
                nameLabel.removeFromSuperview()
            }
            for infoView in infoViews {
                infoView.removeFromSuperview()
            }
            labels.removeAll()
        }
        guard
            let subway = subway,
            let route = routeWatcher?.routes[routeId]
        else {
            return
        }
        let x = 100.0
        var y = 0.0
        var allSegemntsPoints: [[Point]] = [[]]
        for segment in route.segments {
            var points: [Point] = []
            let stations = segment.stations(subway)
            for station in stations {
                let point = Point(name: station.name, color:  segment.color, coordinates: CGPoint(x: x, y: y))
                points.append(point)
                y += 30.0
            }
            allSegemntsPoints.append(points)
            
            var lineX = 0.0
            for point in points {
                let nameLabel = UILabel()
                nameLabel.frame = CGRect (
                    x: point.coordinates.x + 10.0,
                    y: point.coordinates.y,
                    width: superview?.bounds.width ?? 100.0,
                    height: 15.0
                )
                nameLabel.text = point.name
                if point != points.first && point != points.last {
                    nameLabel.font = nameLabel.font.withSize(13.0)
                } else {
                    nameLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
                    let timeLabel = UILabel()
                    timeLabel.text = "12:45"
                    timeLabel.font = timeLabel.font.withSize(10.0)
                    timeLabel.clipsToBounds = true
                    timeLabel.layer.borderWidth = 1.0
                    timeLabel.layer.borderColor = Colors.backgroundColor.cgColor
                    timeLabel.textAlignment = .center
                    self.addSubview(timeLabel)
                    labels.append(timeLabel)
                    timeLabel.frame = CGRect (
                        x: point.coordinates.x - 80.0,
                        y: point.coordinates.y,
                        width: 40.0,
                        height: 15.0
                    )
                    timeLabel.layer.cornerRadius = timeLabel.bounds.width / 10
                }
                self.addSubview(nameLabel)
                labels.append(nameLabel)
                
                
                lineX = point.coordinates.x - 20.0
                let pointLabel = UILabel()
                pointLabel.frame = CGRect (
                    x: lineX,
                    y: point.coordinates.y,
                    width: 10.0,
                    height: 10.0
                )
                pointLabel.layer.cornerRadius = pointLabel.bounds.width / 4
                pointLabel.clipsToBounds = true
                pointLabel.backgroundColor = segment.color
                self.addSubview(pointLabel)
                labels.append(pointLabel)
            }
            y += 10.0
            if segment != route.segments.last {
                let infoView = UIView()
                infoView.frame = CGRect (
                    x: lineX,
                    y: y,
                    width: 200.0,
                    height: 60.0
                )
                infoView.layer.cornerRadius = infoView.bounds.width / 20
                infoView.clipsToBounds = true
                infoView.layer.borderWidth = 1.0
                infoView.layer.borderColor = Colors.backgroundColor.cgColor
                infoViews.append(infoView)
                self.addSubview(infoView)
                
                let infoLabel = UILabel()
                infoLabel.frame = CGRect (
                    x: 30,
                    y: 10,
                    width: 200.0,
                    height: 20.0
                )
                infoLabel.text = Texts.transfer
                infoLabel.font = infoLabel.font.withSize(12.0)
                infoView.addSubview(infoLabel)
                labels.append(infoLabel)
                y += 20.0 + infoView.bounds.height
                let imageView = UIImageView()
                imageView.frame = CGRect (
                    x: 30,
                    y: 35,
                    width: 20.0,
                    height: 20.0
                )
                let image = UIImage(named: "man")
                imageView.image = image
                infoView.addSubview(imageView)
                
                let walkTimeLabel = UILabel()
                walkTimeLabel.text = "3 мин"
                walkTimeLabel.textColor = Colors.backgroundColor
                walkTimeLabel.font = walkTimeLabel.font.withSize(12.0)
                infoView.addSubview(walkTimeLabel)
                labels.append(walkTimeLabel)
                walkTimeLabel.frame = CGRect (
                    x: 60,
                    y: 35,
                    width: 100.0,
                    height: 20.0
                )
            }
        }
            
        self.frame = CGRect(
            x: 0,
            y: 20.0,
            width: superview?.bounds.width ?? 0.0,
            height: y + 100.0
        )
    }
}
