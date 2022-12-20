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
    init(id: Int, segments: SegemntedRoute) {
        self.id = id
        self.segments = segments
    }
}

class Segment {
    var from: Station?
    var to: Station?

    init(from: Station?, to: Station?) {
        self.from = from
        self.to = to
    }
}

extension Segment {
    func line(_ subway: Subway) -> Line? {
        guard let station = self.from else {
            return nil
        }
        return station.line(lines: subway.lines)
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
