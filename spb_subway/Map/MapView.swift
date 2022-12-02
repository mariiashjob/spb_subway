//
//  MapView.swift
//  spb_subway
//
//  Created by m.shirokova on 17.11.2022.
//

import UIKit

protocol MapViewDelegate {
    func updateCurrentStationField(station: Station?)
    var isFromFieldSelected: Bool { get set }
}

class MapView: UIView, RouteCalculatorDelegate {

    let subway = Subway(city: City.spb)
    var delegate: MapViewDelegate?
    var stationLabels = [UILabel]()
    var lineNumbersLabels = [UILabel]()
    lazy var routeWatcher = RouteWatcher(routeCalculator: routeCalculator)
    private lazy var width = self.bounds.width
    private lazy var height = self.bounds.height
    private lazy var routeCalculator = RouteCalculator(subway: subway)
    private lazy var determinant = Coordinates(stations: subway.stations, width: width, height: height)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        routeCalculator.delegate = self
        self.backgroundColor = Colors.backgroundColor
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawMap()
        if stationLabels.isEmpty && lineNumbersLabels.isEmpty {
            for (index, line) in subway.lines.enumerated() {
                addLineNumberLabel(line: line, index: index)
                addStationNameLabels(line.stations)
                addStationsNodes()
            }
        }
        updateMapLabels()
    }
    
    func updateMap() {
        updateMapLabels()
        setNeedsDisplay()
    }
    
    func addLineNumberLabel(line: Line, index: Int) {
        let numberLabel = UILabel(frame: CGRect(
            x: (line.points.first?.x ?? 0) - 5,
            y: (line.points.first?.y ?? 0) - 20,
            width: 20.0,
            height: 15.0
        ))
        self.addSubview(numberLabel)
        numberLabel.backgroundColor = line.color
        numberLabel.text = String(index + 1)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center
        numberLabel.layer.cornerRadius = AttributesConstants.cornerRadius / 2
        numberLabel.clipsToBounds = true
        lineNumbersLabels.append(numberLabel)
    }
    
    func addStationsNodes() {
        for node in Data.nodes {
            let stationNameLabel = StationLabel()
            guard let coordinates = subway.stations.filter { node.contains($0.name) }.first?.coordinates else {
                return
            }
            let separator = " / "
            stationNameLabel.text = node.joined(separator: separator)
            stationNameLabel.numberOfLines = 0
            stationNameLabel.paddingLeft = 3.0
            stationNameLabel.paddingRight = 3.0
            stationNameLabel.paddingTop = 2.0
            stationNameLabel.paddingBottom = 2.0
            stationNameLabel.textColor = Colors.textColor
            stationNameLabel.font = stationNameLabel.font.withSize(8.0)
            stationNameLabel.isUserInteractionEnabled = true
            let delta = deltaCoordinates(station: node.first ?? "")
            stationNameLabel.frame = CGRect(
                x: coordinates.x + delta.x,
                y: coordinates.y + delta.y,
                width: stationNameLabel.width(char: separator),
                height: stationNameLabel.height(char: separator)
            )
            self.addSubview(stationNameLabel)
            let tapNodeGecture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
            stationNameLabel.addGestureRecognizer(tapNodeGecture)
            highlightCurrentStationLabel(stationNameLabel)
        }
    }
    
    func addStationNameLabels(_ stations: [Station]) {
        // TODO: Bug - label width is not adapted for string width inside
        for station in stations {
            if let coordinates = station.coordinates, station.nodes.isEmpty {
                let stationNameLabel = StationLabel()
                stationNameLabel.text = station.name
                stationNameLabel.numberOfLines = 2
                stationNameLabel.paddingLeft = 5.0
                stationNameLabel.paddingRight = 5.0
                stationNameLabel.paddingTop = 2.0
                stationNameLabel.paddingBottom = 2.0
                stationNameLabel.textColor = Colors.textColor
                stationNameLabel.font = stationNameLabel.font.withSize(8.0)
                stationNameLabel.isUserInteractionEnabled = true
                let delay = stationNameLabel.font.pointSize
                var deltaX = 0.0
                var deltaY = 0.0
                if coordinates.x / width < 0.3 {
                    deltaX = -delay - stationNameLabel.width()
                    stationNameLabel.textAlignment = .right
                } else {
                    deltaX = delay
                    stationNameLabel.textAlignment = .left
                }
                let lineStations = stations.filter { $0.lineId == station.lineId }
                let stationsBefore = lineStations.filter { $0.order == station.order - 1 }.first
                if stationsBefore?.coordinates?.y == station.coordinates?.y {
                    deltaX = -delay
                    deltaY = delay
                }
                stationNameLabel.frame = CGRect(
                    x: coordinates.x + deltaX,
                    y: coordinates.y - deltaY - stationNameLabel.height()/3,
                    width: stationNameLabel.width(),
                    height: stationNameLabel.height()
                )
                self.addSubview(stationNameLabel)
                let tapGecture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
                stationNameLabel.addGestureRecognizer(tapGecture)
                highlightCurrentStationLabel(stationNameLabel)
                stationLabels.append(stationNameLabel)
            }
        }
    }
    
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        let label = sender.view as? StationLabel
        let stationName = label?.text?.removeSpaces()
        if let selectedStation = subway.stations.filter({ station in station.name.removeSpaces() == stationName }).first {
            let isFromStation = routeWatcher.currentDirection?.isFromStation ?? true
            let direction = Direction(
                station: selectedStation,
                isFromStation: isFromStation
            )
            routeWatcher.updateCurrentDirection(direction)
            delegate?.updateCurrentStationField(station: selectedStation)
            updateMapLabels()
        }
    }
    
    private func highlightCurrentStationLabel(_ label: UILabel) {
        if routeWatcher.currentDirection?.station?.name.removeSpaces() == label.text?.removeSpaces() {
            label.layer.cornerRadius = AttributesConstants.cornerRadius
            label.clipsToBounds = true
            label.layer.borderColor = Colors.textHighlightedColor.cgColor
            label.layer.borderWidth = 1.0
        } else {
            label.layer.borderWidth = 0.0
        }
    }
    
    // TODO: color after station selected (return key is pushed or view is panned down)
    // use delegate, create new function for it with UILable param
    @discardableResult
    func updateMapLabels() -> MapView {
        for numberLabel in lineNumbersLabels {
            if !routeWatcher.routes.isEmpty {
                numberLabel.alpha = MapSettings.alphaDisabled
            } else {
                numberLabel.alpha = MapSettings.alphaEnabled
            }
        }
        for label in stationLabels {
            highlightCurrentStationLabel(label)
            if (routeWatcher.stationFrom?.name == label.text || routeWatcher.stationTo?.name == label.text) && routeWatcher.routes.isEmpty {
                label.textColor = Colors.textHighlightedColor
                label.layer.borderWidth = 0.0
            } else if (routeWatcher.stationFrom?.name == label.text || routeWatcher.stationTo?.name == label.text) && !routeWatcher.routes.isEmpty {
                label.textColor = Colors.textHighlightedColor
            } else if !routeWatcher.routes.isEmpty {
                label.textColor = Colors.textDisabledColor
            } else {
                label.textColor = Colors.textColor
            }
        }
        return self
    }
    
    private func drawMap() {
        guard let context = UIGraphicsGetCurrentContext(), !subway.lines.isEmpty else {
            return
        }
        if !subway.isCoordinated {
            subway.addStationsCoordinates()
            determinant
                .completeSubwayСoordinates(subway)
                .convertCoordinates(subway)
        }
        for (index, line) in subway.lines.enumerated() {
            var alpha: CGFloat = MapSettings.alphaEnabled
            if !routeWatcher.routes.isEmpty {
                alpha = MapSettings.alphaDisabled
            }
            line.color = colorById(index)
            context
                .setAttributes(color: line.color, alpha: alpha)
                .drawLine(points: line.points)
        }
        print("-------------MAP IS BUILT-------------")
        // TODO: show the first route for test - the logic should be replaced
        let routeId = 0 // it is picked up from view
        if let segments = routeWatcher.routes.filter({$0.id == routeId}).first?.segments {
            for segment in segments {
                var points = [CGPoint]()
                for station in segment.stations(subway) {
                    if let coordinates = station.coordinates {
                        points.append(coordinates)
                    }
                }
                context
                    .setAttributes(
                        color: segment.color(subway),
                        alpha: MapSettings.alphaEnabled)
                    .drawLine(points: points)
            }
        }
    }
    
    private func colorById(_ id: Int) -> UIColor {
        switch(id + 1) {
        case 1:
            return .systemRed
        case 2:
            return .systemBlue
        case 3:
            return .systemGreen
        case 4:
            return .systemYellow
        case 5:
            return .systemPurple
        default:
            return .systemGray
        }
    }
    
    private func deltaCoordinates(station: String) -> CGPoint {
        switch(station) {
        case "Площадь Восстания":
            return CGPoint(x: 10.0, y: -20.0)
        case "Технологический институт":
            return CGPoint(x: -100.0, y: -20.0)
        case "Гостиный двор":
            return CGPoint(x: 10.0, y: -10.0)
        case "Садовая":
            return CGPoint(x: -100.0, y: -10.0)
        case "Достоевская":
            return CGPoint(x: 10.0, y: -10.0)
        case "Пушкинская":
            return CGPoint(x: 10.0, y: -10.0)
        case "Площадь Александра Невского 1":
            return CGPoint(x: 10.0, y: -20.0)
        default:
            return CGPoint(x: 0.0, y: 0.0)
        }
    }
}
