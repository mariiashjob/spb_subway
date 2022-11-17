//
//  Subway.swift
//  spb_subway
//
//  Created by m.shirokova on 17.11.2022.
//

import UIKit

class Subway {
    
    static func lines(width: CGFloat, height: CGFloat) -> [Line] {
        var lines = [Line]()
        for index in 1...5 {
            if let line = setLine(number: index, width: width, height: height) {
                lines.append(line)
            }
        }
        return lines
    }
    
    static func setLine(number: Int, width: CGFloat, height: CGFloat) -> Line? {
        var color: UIColor?
        var coordinates: [Coordinate]?
        switch(number) {
        case 1:
            color = .systemRed
            coordinates = [(0.7, 0.2), (0.7, 0.8), (0.3, 1.1), (0.15, 1.3), (0.1, 1.6)]
        case 2:
            color = .systemBlue
            coordinates = [(0.4, 0.2), (0.4, 1.6)]
        case 3:
            color = .systemGreen
            coordinates = [(0.1, 0.7), (0.18, 0.8), (0.7, 0.8), (0.8, 0.9), (0.8, 1.5)]
        case 4:
            color = .systemYellow
            coordinates = [(0.2, 0.9), (0.8, 0.9), (0.95, 1.0), (0.95, 1.2)]
        case 5:
            color = .systemPurple
            coordinates = [(0.2, 0.3), (0.2, 0.6), (0.4, 0.9), (0.7, 1.1), (0.7, 1.6)]
        default:
            color = nil
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
        return Line(number: number, color: color, points: points)
    }
    
    static func getCGPoint(width: CGFloat, height: CGFloat, coordinate: Coordinate) -> CGPoint {
        return CGPoint(x: width * coordinate.0, y: height * coordinate.1)
    }
}

typealias Coordinate = (CGFloat, CGFloat)

class Line {
    var number: Int
    var color: UIColor
    var points: [CGPoint]
    
    init(number: Int, color: UIColor, points: [CGPoint]) {
        self.number = number
        self.color = color
        self.points = points
    }
}

class Station {
    var name: String
    var line: Line
    var point: CGPoint
    var exists: Bool
    var available: Bool
    
    init(name: String,
         line: Line,
         point: CGPoint,
         exists: Bool = true,
         available: Bool = true
    ) {
        self.name = name
        self.line = line
        self.point = point
        self.available = available
        self.exists = exists
    }
}
