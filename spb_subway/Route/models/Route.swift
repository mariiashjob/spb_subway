//
//  Route.swift
//  spb_subway
//
//  Created by m.shirokova on 25.11.2022.
//

import UIKit

class Route {
    var id: Int
    var segments: SegemntedRoute
    lazy var time: CGFloat? = {
        TimeCalculator.totalTime(route: self)
    }()
    init(id: Int, segments: SegemntedRoute) {
        self.id = id
        self.segments = segments
    }
}

class Segment: Equatable {
    static func == (lhs: Segment, rhs: Segment) -> Bool {
        return lhs.from == rhs.from && lhs.to == rhs.to
    }
    
    var from: Station
    var to: Station
    var lineId: Int
    var distance: CGFloat
    var time: CGFloat
    var stations: [Station] = []
    var color: UIColor?

    init(from: Station, to: Station, subway: Subway) {
        self.from = from
        self.to = to
        self.distance = DistanceCalculator.calculateDistanceKm(from: self.from, to: self.to)
        self.time = TimeCalculator.timeByTrain(self.distance)
        self.lineId = self.from.lineId
        self.color = line(subway)?.color
    }
}

extension Segment {
    func line(_ subway: Subway) -> Line? {
        return self.from.line(lines: subway.lines)
    }
    
    func color(_ subway: Subway) -> UIColor? {
        return line(subway)?.color
    }
    
    func stations(_ subway: Subway) -> [Station] {
        return subway.determineStationsForSegment(self)
    }
}

typealias SegemntedRoute = [Segment]

extension Route {
    
    func stations(_ subway: Subway) -> [Station] {
        var stations = [Station]()
        for segment in self.segments {
            let segmentStations = subway.determineStationsForSegment(segment)
            stations.append(contentsOf: segmentStations)
        }
        return stations
    }
}

class TransitionLine {
    let line: Line
    var transitions: SegemntedRoute?
    init(line: Line) {
        self.line = line
    }
}
