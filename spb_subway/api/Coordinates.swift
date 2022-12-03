//
//  Coordinates.swift
//  spb_subway
//
//  Created by m.shirokova on 01.12.2022.
//

import Foundation
import UIKit

class Coordinates {
    
    let width: CGFloat
    let height: CGFloat
    let latDistance: CGFloat
    let lngDistance: CGFloat
    let minLat: CGFloat
    let maxLat: CGFloat
    let minLng: CGFloat
    let maxLng: CGFloat
    
    static let percents: CGFloat = 100.0
    
    init(stations: [Station], width: CGFloat, height: CGFloat) {
        self.minLat = Calculation.minLatitude(stations: stations)
        self.maxLat = Calculation.maxLatitude(stations: stations)
        self.minLng = Calculation.minLongitude(stations: stations)
        self.maxLng = Calculation.maxLongitude(stations: stations)
        self.latDistance = self.maxLat - self.minLat
        self.lngDistance = self.maxLng - self.minLng
        self.width = width
        self.height = height
    }
    
    class Calculation {
        
        static func minLatitude(stations: [Station]) -> CGFloat {
            return stations.map { $0.lat }.min() ?? 0.0
        }
        
        static func maxLatitude(stations: [Station]) -> CGFloat {
            return stations.map { $0.lat }.max() ?? 0.0
        }
        
        static func minLongitude(stations: [Station]) -> CGFloat {
            return stations.map { $0.lng }.min() ?? 0.0
        }
        
        static func maxLongitude(stations: [Station]) -> CGFloat {
            return stations.map { $0.lng }.max() ?? 0.0
        }
    }
    
    func convert(lat: CGFloat, lng: CGFloat) -> CGPoint {
        return CGPoint(x: calculateX(lng), y: calculateY(lat))
    }
    
    private func calculateX(_ coordinate: CGFloat) -> CGFloat {
        width - calculate(
            distance: lngDistance,
            min: minLng,
            coordinate: coordinate,
            size: width
        )
    }
    
    private func calculateY(_ coordinate: CGFloat) -> CGFloat {
        calculate(
            distance: latDistance,
            min: minLat,
            coordinate: coordinate,
            size: height
        )
    }

    private func calculate(distance: CGFloat, min: CGFloat, coordinate: CGFloat, size: CGFloat) -> CGFloat {
        return (coordinate - min) / (distance / Coordinates.percents) / Coordinates.percents * size
    }
    
    func defineEmptyStations(_ line: Line) -> [Station] {
        var stations = line.stations.filter{ $0.coordinates == nil }
        for (index, station) in stations.enumerated() {
            if index + 1 < stations.count, stations[index + 1].order - station.order > 1 {
                for i in (index + 1)...stations.count - 1 {
                stations.remove(at: index + 1)
                }
                return stations
            }
        }
        return stations
    }
    
    func convertCoordinates(_ subway: Subway) {
        for station in subway.stations {
            if station.coordinates != nil {
                station.coordinates(self)
            }
        }
    }
    
    func beforeFirstStation(line: Line, station: Station) -> Station? {
        return line.stations.filter{ $0.order == station.order - 1 }.first
    }
    
    func afterLastStation(line: Line, station: Station) -> Station? {
        return line.stations.filter{ $0.order == station.order + 1 }.last
    }
    
    func defineDistance(_ coordinates: [CGPoint]) -> CGPoint? {
        guard let last = coordinates.last, let first = coordinates.first else {
            return nil
        }
        return CGPoint(
            x: last.x - first.x,
            y: last.y - first.y
        )
    }
    
    func completeLineСoordinates(_ line: Line) {
        repeat {
            let stations = defineEmptyStations(line)
            let steps = CGFloat(stations.count + 1)
            if let firstStation = stations.first, let lastStation = stations.last {
                guard
                    let beforeFirstStation = beforeFirstStation(line: line, station: firstStation),
                    let afterLastStation = afterLastStation(line: line, station: lastStation),
                    let beforeFirstStationCoordinates = beforeFirstStation.coordinates,
                    let afterLastStationCoordinates = afterLastStation.coordinates,
                    let distance = defineDistance([beforeFirstStationCoordinates, afterLastStationCoordinates]) else {
                    return
                }
                let step = CGPoint(x: distance.x / steps, y: distance.y / steps)
                var stationsToComplete = [beforeFirstStation]
                stationsToComplete.append(contentsOf: stations)
                for i in 1...stationsToComplete.count - 1 {
                    guard let coordinates = stationsToComplete[i - 1].coordinates else {
                        return
                    }
                    stationsToComplete[i].coordinates = CGPoint(
                        x: coordinates.x + step.x,
                        y: coordinates.y + step.y)
                }
            }
        } while !line.isLineCompleted()
    }
    
    func completeSubwayСoordinates(_ subway: Subway) -> Coordinates {
        for line in subway.lines {
            completeLineСoordinates(line)
        }
        return self
    }
}
