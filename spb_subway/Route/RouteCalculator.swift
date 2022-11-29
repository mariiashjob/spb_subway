//
//  RouteCalculator.swift
//  spb_subway
//
//  Created by m.shirokova on 25.11.2022.
//

import CoreGraphics

protocol RouteCalculatorDelegate {
    func updateMap()
}

class RouteCalculator {
    
    var subway: Subway
    var startStation: Station? = nil
    var endStation: Station? = nil
    var delegate: RouteCalculatorDelegate?
    
    init(subway: Subway) {
        self.subway = subway
    }
    
    var routes = [Route]()
    lazy var transits = [TransitionLine]()
    
    func clearRoutes() -> [Route] {
        routes.removeAll()
        delegate?.updateMap()
        return [Route]()
    }
    
    func determineRoutes(startStation: Station, endStation: Station) -> [Route] {
        self.routes.removeAll()
        self.transits.removeAll()
        self.startStation = startStation
        self.endStation = endStation
        if isLineEqual() {
            if let route = determineRouteForEqualLine() {
                routes.append(route)
            }
        } else {
            setUpRouteWithOneNode()
            determineRoutesForVariousLines()
        }
        printRoutes(stationFromName: startStation.name ?? "", stationToName: endStation.name ?? "")
        delegate?.updateMap()
        return routes
    }
    
    private func determineRoutesForVariousLines() {
        determineRouteSegments()
        for transit in transits {
            if let segments = transit.transitions {
                if segments.filter({
                    $0.from == nil || $0.to == nil
                }).isEmpty {
                    let route = Route(id: routes.count, segments: segments)
                    routes.append(route)
                }
            }
        }
    }
    
    private func determineRouteForEqualLine() -> Route? {
        let segments = [Segment(from: self.startStation, to: self.endStation)]
        return Route(id: 0, segments: segments)
    }
    
    private func isLineEqual() -> Bool {
        guard
            let startStationLine = self.startStation?.line(lines: subway.lines),
            let endStationLine = self.endStation?.line(lines: subway.lines) else {
            return false
        }
        return startStationLine.id == endStationLine.id
    }

    func setUpRouteWithOneNode() {
        guard let startStation = self.startStation,
              let endStation = self.endStation,
              let startLine = startStation.line(lines: subway.lines),
              let endLine = endStation.line(lines: subway.lines),
              let stationsWithNodesForStartLine = getStationsWithNodes(line: startLine),
              let stationsWithNodesForEndLine = getStationsWithNodes(line: endLine),
              let nodeTo = stationWithNodeToLine(endLine, stationsWithNodesForStartLine),
              let nodeFrom = stationWithNodeToLine(startLine, stationsWithNodesForEndLine) else {
            return
        }
        let segments = [
            Segment(from: startStation, to: nodeTo),
            Segment(from: nodeFrom, to: endStation)
        ]
        routes.append(Route(id: routes.count, segments: segments))
    }
    
    private func getStationsWithNodes(line: Line) -> [Station]? {
        return line.stations.filter({ station in
            !station.nodes.isEmpty
        })
    }
    
    private func stationWithNodeToLine(_ line: Line, _ stations: [Station]) -> Station? {
        return stations.filter { station in
            station.nodes.filter { node in
                node.lineId == line.id
            }.first != nil
        }.first
    }
    
    private func transitLines() -> [TransitionLine] {
        let stations = [self.startStation, self.endStation]
        var transitLines = subway.lines
        for station in stations {
            guard let stationLine = station?.line(lines: subway.lines) else {
                return [TransitionLine]()
            }
            if let index = transitLines.firstIndex(of: stationLine) {
                transitLines.remove(at: index)
            }
        }
        var transits = [TransitionLine]()
        for line in transitLines {
            let trasit = TransitionLine(line: line)
            transits.append(trasit)
        }
        return transits
    }
    
    private func determineRouteSegments() {
        guard let startLine = self.startStation?.line(lines: subway.lines),
              let endLine = self.endStation?.line(lines: subway.lines) else {
            return
        }
        guard let startNodes = getStationsWithNodes(line: startLine),
              let endNodes = getStationsWithNodes(line: endLine) else {
            return
        }
        transits = transitLines()
        for transit in transits {
            let line = transit.line
            if let transitNodes = getStationsWithNodes(line: line) {
                transit.transitions = [
                    Segment(from: self.startStation, to: stationWithNodeToLine(line, startNodes)),
                    Segment(from: stationWithNodeToLine(startLine, transitNodes), to: stationWithNodeToLine(endLine, transitNodes)),
                    Segment(from: stationWithNodeToLine(line, endNodes), to: self.endStation)
                ]
            } else {
                transit.transitions = nil
            }
        }
    }
    
    // TODO: should be removed when all is right and done
    private func printRoutes(stationFromName: String, stationToName: String) {
        for (index, route) in self.routes.enumerated() {
            print("Маршрут #\(index) от \(stationFromName) до \(stationToName)")
            for (index, station) in route.stations(subway).enumerated() {
                print("\(index) \(station.name ?? "")")
            }
        }
    }
}
