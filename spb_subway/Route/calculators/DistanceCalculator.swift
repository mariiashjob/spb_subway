//
//  Distance.swift
//  spb_subway
//
//  Created by m.shirokova on 07.12.2022.
//

import Foundation
import UIKit

final class DistanceCalculator {
    
    static let degrees: CGFloat = 180.0
    static let earthRadious: CGFloat = 6371.008
    static let meters: CGFloat = 1000.0
    
    struct Coordinates {
        var lat: CGFloat
        var lng: CGFloat
    }
    
    static func calculateDistanceKm(from: Station, to: Station) -> CGFloat {
        let fromPoint = Coordinates(
            lat: from.lat.convertToRadians(),
            lng: from.lng.convertToRadians())
        let toPoint = Coordinates(
            lat: to.lat.convertToRadians(),
            lng: to.lng.convertToRadians())
        let cosD = sin(fromPoint.lat) * sin(toPoint.lat) + cos(fromPoint.lat) * cos(toPoint.lat) * cos(fromPoint.lng + toPoint.lng)
        return (acos(cosD) * DistanceCalculator.earthRadious).convertToKilometers()
    }
}

extension CGFloat {
    
    func convertToRadians() -> CGFloat {
        return self * CGFloat.pi / DistanceCalculator.degrees
    }
    
    func convertToKilometers() -> CGFloat {
        return self / DistanceCalculator.meters
    }
}
