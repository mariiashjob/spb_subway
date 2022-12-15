//
//  MapView.swift
//  spb_subway
//
//  Created by m.shirokova on 17.11.2022.
//

import UIKit

protocol MapViewDelegate {
    var isFromFieldSelected: Bool { get set }
    var isFooterUp: Bool { get set }
    func updateRouteInfo()
    func updateCurrentStationField(station: Station?)
}

class MapView: UIView, RouteCalculatorDelegate {

    let subway = Subway(city: City.spb)
    var delegate: MapViewDelegate?
    var stationLabels = [UILabel]()
    var lineNumbersLabels = [UILabel]()
    var directionsLabels = [UILabel]()
    lazy var routeWatcher = RouteWatcher(routeCalculator: routeCalculator)
    private lazy var width = self.bounds.width
    private lazy var height = self.bounds.height
    private lazy var routeCalculator = RouteCalculator(subway: subway)
    private lazy var determinant = Coordinates(stations: subway.stations, width: width, height: height)
    private let separator = " / "
    
    override func layoutSubviews() {
        super.layoutSubviews()
        routeCalculator.delegate = self
        self.backgroundColor = Colors.backgroundColor
    }
    
    // TODO: Bug - right line stations labels are disabled
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let isFooterUp = delegate?.isFooterUp, isFooterUp == true {
            delegate?.updateRouteInfo()
        }
        drawMap(routeWatcher.routeId)
        addStationsAndLinesLabelsIfNeeded()
        updateMapLabels()
    }
    
    func updateMapContent() {
        updateMapLabels()
        setNeedsDisplay()
    }
    
    private func addStationsAndLinesLabelsIfNeeded() {
        if stationLabels.isEmpty && lineNumbersLabels.isEmpty {
            for (index, line) in subway.lines.enumerated() {
                addLineNumberLabel(line: line, index: index)
                addStationNameLabels(line.stations)
                addStationsNodes()
            }
        }
    }
    
    private func addLineNumberLabel(line: Line, index: Int) {
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
    
    private func addToViewDirectionLabels() {
        if !directionsLabels.isEmpty {
            for label in directionsLabels {
                self.addSubview(label)
            }
        }
    }
    
    private func removeDirectionLabels() {
        if !directionsLabels.isEmpty {
            for label in directionsLabels {
                label.removeFromSuperview()
            }
        directionsLabels.removeAll()
        }
    }
    
    private func addDirectionLabel(station: Station, text: String) {
        guard let coordinates = station.coordinates else {
            return
        }
        let defaultSize: CGFloat = 15.0
        let label = UILabel(frame: CGRect(
            x: coordinates.x - defaultSize / 2,
            y: coordinates.y,
            width: defaultSize,
            height: defaultSize
        ))
        label.backgroundColor = station.color(lines: subway.lines)
        label.text = text
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = AttributesConstants.cornerRadius / 2
        label.clipsToBounds = true
        directionsLabels.append(label)
    }
    
    private func addStationsNodes() {
        for node in Data.nodes {
            let stationNameLabel = StationLabel()
            guard let coordinates = subway.stations.filter({ node.contains($0.name) }).first?.coordinates else {
                return
            }
            stationNameLabel.text = node.joined(separator: separator)
            stationNameLabel.numberOfLines = 0
            stationNameLabel.paddingLeft = 5.0
            stationNameLabel.paddingRight = 5.0
            stationNameLabel.paddingTop = 2.0
            stationNameLabel.paddingBottom = 2.0
            stationNameLabel.textColor = Colors.textColor
            stationNameLabel.font = stationNameLabel.font.withSize(MapSettings.fontSize)
            stationNameLabel.isUserInteractionEnabled = true
            let delta = deltaLabelCoordinates(station: node.first ?? "")
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
            stationLabels.append(stationNameLabel)
        }
    }
    
    private func addStationNameLabels(_ stations: [Station]) {
        // TODO: Bug - label width is not adapted for string width inside
        for station in stations {
            if let coordinates = station.coordinates, station.nodes.isEmpty {
                let stationNameLabel = StationLabel()
                stationNameLabel.text = station.name
                stationNameLabel.numberOfLines = 0
                stationNameLabel.paddingLeft = 5.0
                stationNameLabel.paddingRight = 5.0
                stationNameLabel.paddingTop = 2.0
                stationNameLabel.paddingBottom = 2.0
                stationNameLabel.textColor = Colors.textColor
                stationNameLabel.font = stationNameLabel.font.withSize(MapSettings.fontSize)
                stationNameLabel.isUserInteractionEnabled = true
                let delay = stationNameLabel.font.pointSize
                var deltaX = 0.0
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
                }
                stationNameLabel.frame = CGRect(
                    x: coordinates.x + deltaX,
                    y: coordinates.y,
                    width: stationNameLabel.width(),
                    height: stationNameLabel.height()
                )
                self.addSubview(stationNameLabel)
                let tapGecture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
                stationNameLabel.addGestureRecognizer(tapGecture)
                highlightCurrentStationLabel(stationNameLabel)
                station.label = stationNameLabel
                stationLabels.append(stationNameLabel)
            }
        }
    }
    
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        guard
            let label = sender.view as? StationLabel,
            let labelText = label.text else {
            return
        }
        var stationName = String()
        if labelText.contains(separator) {
            stationName = labelText.components(separatedBy: separator).first ?? String()
        } else {
            stationName = labelText
        }
        let selectedStation = subway.stations.filter({ station in station.name == stationName }).first
        if selectedStation != nil {
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
        guard let labelText = label.text else {
            return
        }
        if routeWatcher.currentDirection?.station != nil && labelText.contains(routeWatcher.currentDirection!.station!.name) {
            label.layer.cornerRadius = AttributesConstants.cornerRadius
            label.clipsToBounds = true
            label.layer.borderColor = Colors.textColor.cgColor
            label.textColor = Colors.textColor
            label.layer.borderWidth = 1.0
        } else {
            label.layer.borderWidth = 0.0
        }
    }
    
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
            guard let labelText = label.text else {
                return self
            }
            highlightCurrentStationLabel(label)
            if (routeWatcher.stationFrom != nil && labelText.contains(routeWatcher.stationFrom!.name)) || (routeWatcher.stationTo != nil && labelText.contains(routeWatcher.stationTo!.name)) {
                if routeWatcher.routes.isEmpty {
                    label.textColor = Colors.textHighlightedColor
                    label.layer.borderWidth = 0.0
                    label.font = label.font.withSize(8.0)
                } else {
                    label.layer.borderWidth = 1.0
                    label.font = UIFont.boldSystemFont(ofSize: 8.0)
                    label.layer.borderColor = Colors.textHighlightedColor.cgColor
                    label.textColor = Colors.textColor
                }
            }  else if !routeWatcher.routes.isEmpty {
                label.font = label.font.withSize(8.0)
                label.textColor = Colors.textDisabledColor
            } else {
                label.font = label.font.withSize(8.0)
                label.textColor = Colors.textColor
            }
        }
        return self
    }
    
    private func drawMap(_ routeId: Int) {
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
                delegate?.updateRouteInfo()
            }
            line.number = index + 1
            context
                .setAttributes(color: line.color, alpha: alpha)
                .drawLine(points: line.points)
        }
        print("-------------MAP IS BUILT-------------")
        guard
            let route = routeWatcher.routes.filter({$0.id == routeId}).first else {
            return removeDirectionLabels()
        }
        for segment in route.segments {
            var points = [CGPoint]()
            for station in segment.stations(subway) {
                if let coordinates = station.coordinates {
                    points.append(coordinates)
                }
            }
            context
                .setAttributes(
                    color: segment.color,
                    alpha: MapSettings.alphaEnabled)
                .drawLine(points: points)
        }
        guard
            let startStation = route.stations(subway).first,
            let endStation = route.stations(subway).last else {
            return
        }
        removeDirectionLabels()
        addDirectionLabel(station: startStation, text: Texts.fromStation)
        addDirectionLabel(station: endStation, text: Texts.toStation)
        addToViewDirectionLabels()
    }
    
    private func deltaLabelCoordinates(station: String) -> CGPoint {
        switch(station) {
        case "Площадь Восстания":
            return CGPoint(x: 30.0, y: 0.0)
        case "Технологический институт":
            return CGPoint(x: -130.0, y: -20.0)
        case "Гостиный двор":
            return CGPoint(x: 5.0, y: 5.0)
        case "Садовая":
            return CGPoint(x: -90.0, y: -10.0)
        case "Достоевская":
            return CGPoint(x: 0.0, y: -30.0)
        case "Пушкинская":
            return CGPoint(x: 20.0, y: -10.0)
        case "Площадь Александра Невского 1":
            return CGPoint(x: 10.0, y: -20.0)
        default:
            return CGPoint(x: 0.0, y: 0.0)
        }
    }
}
