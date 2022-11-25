//
//  Route.swift
//  spb_subway
//
//  Created by m.shirokova on 25.11.2022.
//

class Route {
    
    var id: Int
    var stations: [Station]
    
    init(id: Int, stations: [Station]) {
        self.id = id
        self.stations = stations
    }
}

typealias Segment = [Station]
