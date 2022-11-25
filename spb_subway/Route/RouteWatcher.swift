//
//  DirectionWatcher.swift
//  spb_subway
//
//  Created by m.shirokova on 19.11.2022.
//

import UIKit

protocol RouteWatcherDelegate {
    
    var stationFrom: Station? { get set }
    var stationTo: Station? { get set }
    var currentDirection: Direction? { get set }
    func saveStation() -> RouteWatcher
    func getRouteTime() -> CGFloat
}

protocol DirectionProtocol {
    
    var station: Station? { get set }
    var isFromStation: Bool { get set }
    init(station: Station?, isFromStation: Bool)
}

class RouteWatcher: RouteWatcherDelegate {
    
    var routes: [Route] = []
    var stationFrom: Station? = nil
    var stationTo: Station? = nil
    var currentDirection: Direction? = nil
    var delegate: MapViewDelegate? = nil
    var routeCalculator: RouteCalculator
    
    init(routeCalculator: RouteCalculator) {
        self.routeCalculator = routeCalculator
    }

    internal func printRoutes() {
        guard let stations = self.routes.first?.stations else {
            return
        }
        print("Маршрут от \(self.stationFrom?.name) до \(self.stationTo?.name)")
        for (index, station) in stations.enumerated() {
            print("\(index) \(station.name)")
        }
    }
    
    @discardableResult
    func saveStation() -> RouteWatcher {
        guard let currentDirection = currentDirection else {
            return self
        }
        let station = currentDirection.station
        if currentDirection.isFromStation == true {
            // TODO: check if it works or not
            self.stationFrom = station
        } else {
            self.stationTo = station
        }
        if let stationFrom = self.stationFrom, let stationTo = stationTo {
            self.routes = routeCalculator.determineRoutes(startStation: stationFrom, endStation: stationTo)
        }
        printRoutes()
        return self
    }
    
    func getRouteTime() -> CGFloat {
        // TODO: use static function to calculate time
        return 20.00
    }
    
    func changeStations() {
        let currentStationTo = self.stationTo
        let currentStationFrom = self.stationFrom
        self.stationFrom = currentStationTo
        self.stationTo = currentStationFrom
        if let stationFrom = self.stationFrom, let stationTo = stationTo {
            self.routes = routeCalculator.determineRoutes(startStation: stationFrom, endStation: stationTo)
        }
        printRoutes()
    }
    
    @discardableResult
    func clearCurrentDirection() -> RouteWatcher {
        self.currentDirection = nil
        delegate?.updateCurrentStationField(station: nil)
        return self
    }
    
    func updateCurrentDirection(_ value: Bool) {
        if let currentDirection = self.currentDirection {
            self.currentDirection = Direction(station: currentDirection.station, isFromStation: value)
        } else {
            self.currentDirection = Direction(station: nil, isFromStation: value)
        }
    }
    
    @discardableResult
    func updateCurrentDirection(_ direction: Direction) -> RouteWatcher {
        self.currentDirection = direction
        return self
    }
}

class Direction: DirectionProtocol {
    
    var station: Station?
    var isFromStation: Bool
    required init(station: Station?, isFromStation: Bool) {
        self.station = station
        self.isFromStation = isFromStation
    }
}
