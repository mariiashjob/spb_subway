//
//  RouteCalculator.swift
//  spb_subway
//
//  Created by m.shirokova on 25.11.2022.
//

import CoreGraphics

class RouteCalculator {
    
    var subway: Subway
    
    init(subway: Subway) {
        self.subway = subway
    }
    
    var routes = [Route]()
    
    func determineRoutes(startStation: Station, endStation: Station) -> [Route]{
        if isLineEqual(startStation, endStation) {
            if let route = determineRouteForEqualLine(startStation, endStation) {
                routes.removeAll()
                routes.append(route)
            }
        } else {
            // TODO: other func
        }
        return routes
    }
    
    private func determineRouteForEqualLine(_ startStation: Station, _ endStation: Station) -> Route? {
        var routeStations: [Station] = []
        guard let line = getStationLine(station: startStation) else {
            return nil
        }
        
        if startStation.order < endStation.order {
            routeStations = line.stations.filter { station in
                station.order <= endStation.order && station.order >= startStation.order
            }
        } else {
            routeStations = line.stations.filter { station in
                station.order <= startStation.order && station.order >= endStation.order
            }.reversed()
            
        }
        return Route(id: 0, stations: routeStations)
    }
    
    func isLineEqual(_ startStation: Station, _ endStation: Station) -> Bool {
        guard
            let startStationLine = getStationLine(station: startStation),
            let endStationLine = getStationLine(station: endStation) else {
            return false
        }
        return startStationLine.id == endStationLine.id
    }
    
    func calculateRoutes(startStation: Station, endStation: Station) -> [Route] {
        // TODO: 
        return [Route]()
    }
    
    func getRouteSegment() -> Segment {
        // TODO:
        return Segment()
    }
    
    func getStationLine(station: Station) -> Line? {
        return subway.lines.filter({ line in
            line.id == station.lineId
        }).first
    }

    func setUpRoutes(startStation: Station, endStation: Station) {
        if let line = subway.lines.filter({ line in
            line.id == startStation.lineId
        }).first {
            let nodes = line.allNodes()
            for node in nodes {
                let route = Route(id: routes.count, stations: [startStation, node])
                routes.append(route)
            }
        }
    }
}


