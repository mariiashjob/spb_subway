//
//  Subway.swift
//  spb_subway
//
//  Created by m.shirokova on 17.11.2022.
//

import UIKit

struct MapCoordinate {
    var name: String
    var point: CGPoint
}

class Subway {
    
    var city: String
    var lines: [Line]
    var isCoordinated: Bool = false
    lazy var coordinates: [MapCoordinate] = Data.addPoints()
    lazy var stations: [Station] = {
        var stations = [Station]()
        for line in self.lines {
            stations.append(contentsOf: line.stations)
        }
        return stations
    }()
    
    init(city: String) {
        self.city = city
        self.lines = []
    }
    
    func addStationsCoordinates() {
        for coordinate in self.coordinates {
            let station = self.stations.filter {
                $0.name.removeSpaces() == coordinate.name.removeSpaces()
            }.first
            station?.coordinates = coordinate.point
        }
        self.isCoordinated = Data.configureNodes(self.stations)
    }
}
    
class Line: Equatable {
    static func == (lhs: Line, rhs: Line) -> Bool {
        return true
    }
    
    var id: Int
    var name: String?
    var color: UIColor?
    lazy var points: [CGPoint] = {
        var points: [CGPoint] = []
        for station in self.stations {
            station.lineId = self.id
            if let coordinates = station.coordinates {
                points.append(coordinates)
            }
        }
        return points
    }()
    var stations: [Station]
    
    init?(data: NSDictionary) {
        guard let id = data["id"] as? String,
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
        
        self.id = Int(id) ?? 0
        self.name = name
        self.color = UIColor(hex: "#\(color)")
        self.stations = stations
        
    }
    
    init(id: Int, color: UIColor, stations: [Station] = []) {
        self.id = id
        self.color = color
        self.stations = stations
    }
}

class Station {
    var id: Float?
    var lineId: Int?
    var routeId: Int?
    var nodes: [Station]
    var name: String
    var coordinates: CGPoint?
    var lat: CGFloat
    var lng: CGFloat
    var order: Int
    var isClosed: Bool?
    var isInRoute: Bool?
    var label: UILabel?
    
    init?(data: NSDictionary) {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String,
              let lat = data["lat"] as? CGFloat,
              let lng = data["lng"] as? CGFloat,
              let order = data["order"] as? Int
             else { return nil }
        self.id = Float(id)
        self.name = name
        self.lat = lat
        self.lng = lng
        self.order = order
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
    
    func isLineCompleted() -> Bool {
        return self.stations.filter { $0.coordinates == nil }.isEmpty
    }
}

extension Station {
    
    func line(lines: [Line]) -> Line? {
        return lines.filter { line in
            line.id == self.lineId
        }.first
    }
    
    func coordinates(_ determinant: Coordinates) {
        if let coordinates = self.coordinates {
            self.coordinates = CGPoint(
                x: coordinates.x * determinant.width,
                y: coordinates.y * determinant.height)
        }
    }
    
    func color(lines: [Line]) -> UIColor? {
        return lines.filter { $0.id == self.lineId }.first?.color
    }
}

extension Subway {
    
    func determineStationsForSegment(_ segment: Segment) -> [Station] {
        var stations: [Station] = []
        guard let start = segment.from, let end = segment.to, let line = segment.line(self) else {
            return []
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
