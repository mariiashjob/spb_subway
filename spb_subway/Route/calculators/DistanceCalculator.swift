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
    static let earthRadious: CGFloat = 6371.008 //6372795.0
    static let meters: CGFloat = 1000.0 // TODO: must be 1000.0 !!!
    
    struct Coordinates {
        let lat: CGFloat
        let lng: CGFloat
    }
    
    static func calculateDistanceKm(from: Station, to: Station) -> CGFloat {
        let fromPoint = Coordinates(
            lat: from.lat.convertToRadians(),
            lng: from.lng.convertToRadians()
        )
        let toPoint = Coordinates(
            lat: to.lat.convertToRadians(),
            lng: to.lng.convertToRadians()
        )
        
        let cosLatFrom = cos(fromPoint.lat)
        let cosLatTo = cos(toPoint.lat)
        let sinLatFrom = sin(fromPoint.lat)
        let sinLatTo = sin(toPoint.lat)
        let delta = toPoint.lng - from.lng
        let cosDelta = cos(delta)
        let sinDelta = sin(delta)
        
        let y = sqrt(pow(cosLatTo * sinDelta, 2) + pow(cosLatFrom * sinLatTo - sinLatFrom * cosLatTo * cosDelta, 2))
        let x = sinLatFrom * sinLatTo + cosLatFrom * cosLatTo * cosDelta
        
        return (atan2(y, x) * DistanceCalculator.earthRadious) / DistanceCalculator.meters
    }
}

extension CGFloat {
    
    func convertToRadians() -> CGFloat {
        return self * CGFloat.pi / DistanceCalculator.degrees
    }
}
