//
//  Subway.swift
//  spb_subway
//
//  Created by m.shirokova on 17.11.2022.
//

import UIKit

class Subway {
    
    var city: String
    var lines: [Line]
    
    init(city: String, lines: [Line]) {
        self.city = city
        self.lines = lines
    }
}
    
class Line: Equatable {
    static func == (lhs: Line, rhs: Line) -> Bool {
        return true
    }
    
    var id: Int
    var name: String?
    var color: UIColor?
    var points: [CGPoint] // TODO: should be removed, used in mock
    var stations: [Station]
    
    init?(data: NSDictionary) {
        guard let id = data["id"] as? Int,
              let name = data["name"] as? String,
              let color = data["hex_color"] as? String,
              let stationsData = data["stations"] as? [NSDictionary]
             else { return nil }
        var stations = [Station]()
        for stationData in stationsData {
            let station = Station(data: stationData)
            if let station = station {
                stations.append(station)
            }
        }
        
        self.id = id
        self.name = name
        self.color = UIColor(hex: color)
        self.points = [CGPoint]()
        self.stations = stations
        
    }
    
    init(id: Int, color: UIColor, points: [CGPoint], stations: [Station] = [Station]()) {
        self.id = id
        self.color = color
        self.points = points
        self.stations = stations
    }
}

class Station {
    var id: Int?
    var lineId: Int?
    var routeId: Int?
    var nodes: [Station]
    var name: String?
    var coordinates: CGPoint
    var lat: CGFloat? // TODO: should be removed, used in mock
    var lng: CGFloat? // TODO: should be removed, used in mock
    var order: Int
    var isClosed: Bool?
    var isInRoute: Bool?
    
    init?(data: NSDictionary) {
        guard let id = data["id"] as? Int,
              let name = data["name"] as? String,
              let lat = data["lat"] as? CGFloat,
              let lng = data["lng"] as? CGFloat,
              let order = data["order"] as? Int
             else { return nil }
        self.id = id
        self.name = name
        self.coordinates = CGPoint(x: lat, y: lng)
        self.lat = lat
        self.lng = lng
        self.order = order
        self.isClosed = false
        self.isInRoute = false
        self.nodes = [Station]()
    }
    
    init(
        lineId: Int,
        name: String?,
        order: Int,
        point: CGPoint
    ) {
        self.name = name
        self.order = order
        self.lineId = lineId
        self.coordinates = point
        self.isClosed = false
        self.isInRoute = false
        self.nodes = [Station]()
    }
}

extension Line {
    
    func allNodes() -> [Station] {
        var allStationNodes = [Station]()
        for station in self.stations {
            let nodes = station.nodes
            if !nodes.isEmpty {
                allStationNodes.append(contentsOf: nodes)
            }
        }
        return allStationNodes
    }
}

extension Station {
    
    func line(lines: [Line]) -> Line? {
        return lines.filter { line in
            line.id == self.lineId
        }.first
    }
}

extension Subway {
    func determineStationsForSegment(_ segment: Segment) -> [Station] {
        var stations: [Station] = []
        guard let start = segment.from, let end = segment.to, let line = segment.line(self) else {
            return [Station]()
        }
        if start.order < end.order {
            stations = line.stations.filter { station in
                station.order <= end.order && station.order >= start.order
            }
        } else {
            stations = line.stations.filter { station in
                station.order <= start.order && station.order >= end.order
            }.reversed()
        }
        return stations
    }
}
