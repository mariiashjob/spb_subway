//
//  Mock.swift
//  spb_subway
//
//  Created by m.shirokova on 19.11.2022.
//

import UIKit

class Mock {
    
    static let linesNumber = 5
    
    typealias Coordinate = (CGFloat, CGFloat)
    
    static func lines(width: CGFloat, height: CGFloat) -> [Line] {
        var lines = [Line]()
        for index in 1...linesNumber {
            if let line = setLine(id: index, width: width, height: height) {
                lines.append(line)
            }
        }
        return lines
    }
    
    static func setLine(id: Int, width: CGFloat, height: CGFloat) -> Line? {
        var color: UIColor?
        var disabledColor: UIColor?
        var coordinates: [Coordinate]?
        switch(id) {
        case 1:
            color = .systemRed
            coordinates = [(0.7, 0.1), (0.7, 0.7), (0.3, 1.0), (0.15, 1.2), (0.1, 1.5)]
        case 2:
            color = .systemBlue
            coordinates = [(0.4, 0.1), (0.4, 1.5)]
        case 3:
            color = .systemGreen
            coordinates = [(0.1, 0.6), (0.18, 0.7), (0.7, 0.7), (0.8, 0.8), (0.8, 1.4)]
        case 4:
            color = .systemYellow
            coordinates = [(0.2, 0.8), (0.8, 0.8), (0.95, 0.9), (0.95, 1.1)]
        case 5:
            color = .systemPurple
            coordinates = [(0.2, 0.2), (0.2, 0.5), (0.4, 0.8), (0.7, 1.0), (0.7, 1.5)]
        default:
            color = nil
            disabledColor = nil
            coordinates = nil
        }
        guard let color = color, let coordinates = coordinates, !coordinates.isEmpty else {
            return nil
        }
        var points = [CGPoint]()
        for coordinate in coordinates {
            let point = getCGPoint(width: width, height: width, coordinate: coordinate)
            points.append(point)
        }
        return Line(id: id, color: color, points: points, stations: [Station]())
    }
    
    static func getCGPoint(width: CGFloat, height: CGFloat, coordinate: Coordinate) -> CGPoint {
        return CGPoint(x: width * coordinate.0, y: height * coordinate.1)
    }
    
    static func stations(line: Line, names: [String]) -> [Station] {
        var stations = [Station]()
        let lineStartStation = line.points.first
        let x = lineStartStation?.x ?? 0
        var y = lineStartStation?.y ?? 0
        for (index, name) in names.enumerated() {
            let station = Station(lineId: line.id, name: name, order: index, point: CGPoint(x: x, y: y))
            stations.append(station)
            if !line.stations.contains(where: { $0.name == station.name }) {
                line.stations.append(station)
            }
            y += 25
        }
        return stations
    }
    
    @discardableResult
    static func addNodes(stations: [Station], nodes: [String]) -> Mock.Type {
        let stationsWithNodes = stations.filter({ nodes.contains($0.name ?? "") })
        for station in stationsWithNodes {
            for node in stationsWithNodes {
                if station.name != node.name {
                    node.coordinates = station.coordinates
                    station.nodes.append(node)
                }
            }
        }
        return self
    }
}
