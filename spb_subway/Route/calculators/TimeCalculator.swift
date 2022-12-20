//
//  TimeCalculator.swift
//  spb_subway
//
//  Created by m.shirokova on 07.12.2022.
//

import Foundation
import UIKit

final class TimeCalculator {
    
    static let trainSpeed: CGFloat = 40.0
    static let humanSpeed: CGFloat = 10.0
    static let hour: CGFloat = 60.0
    
    static func timeByTrain(_ distance: CGFloat) -> CGFloat {
        return distance / TimeCalculator.trainSpeed
    }
    
    static func walkingTime(_ distance: CGFloat) -> CGFloat {
        return distance / TimeCalculator.humanSpeed
    }
    
    static func totalTime(route: Route) -> CGFloat {
        if route.segments.count > 1 {
            var walkingDistance: CGFloat = 0.0
            for i in 0..<route.segments.count-1 {
                let distance = DistanceCalculator.calculateDistanceKm(from: route.segments[i].to, to: route.segments[i + 1].from)
                walkingDistance += distance
            }
            return (route.segments.map{ $0.time }.reduce(0, +) + TimeCalculator.walkingTime(walkingDistance)) * TimeCalculator.hour
        } else {
            guard let segment = route.segments.first else {
                return 0.0
            }
            return segment.time * TimeCalculator.hour
        }
    }
}
