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

    var delegate: MapViewDelegate?
    var stations = [Station]()
    var stationLabels = [UILabel]()
    var lineNumbersLabels = [UILabel]()
    lazy var routeWatcher = RouteWatcher(routeCalculator: routeCalculator)
    private lazy var width = self.bounds.width
    private lazy var height = self.bounds.height
    private lazy var routeCalculator = RouteCalculator(subway: subway)
    private lazy var subway = Subway(
        city: City.spb,
        lines: Mock.lines(width: width, height: height))
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        routeCalculator.delegate = self
        self.backgroundColor = Colors.backgroundColor
        addLineNumbersLabels()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        for line in subway.lines {
            var alpha: CGFloat = MapSettings.alphaEnabled
            if !routeWatcher.routes.isEmpty {
                alpha = MapSettings.alphaDisabled
            }
            context
                .setAttributes(color: line.color, alpha: alpha)
                .drawLine(points: line.points)
            // TODO: show the first route for test - the logic should be replaced
            let routeId = 0 // it is picked up from view
            if let segments = routeWatcher.routes.filter({$0.id == routeId}).first?.segments {
                for segment in segments {
                    var points = [CGPoint]()
                    for station in segment.stations(subway) {
                        points.append(station.coordinates)
                    }
                    context
                        .setAttributes(
                            color: segment.color(subway),
                            alpha: MapSettings.alphaEnabled)
                        .drawLine(points: points)
                }
            }
        }
    }
    
    func updateMap() {
        setNeedsDisplay()
    }
    
    func addLineNumberLabel(_ line: Line) {
        let numberLabel = UILabel(frame: CGRect(
            x: (line.points.first?.x ?? 0) - 5,
            y: (line.points.first?.y ?? 0) - 20,
            width: 20.0,
            height: 15.0
        ))
        self.addSubview(numberLabel)
        numberLabel.backgroundColor = line.color
        numberLabel.text = String(line.id)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center
        numberLabel.layer.cornerRadius = AttributesConstants.cornerRadius / 2
        numberLabel.clipsToBounds = true
        lineNumbersLabels.append(numberLabel)
    }
    
    func addStationNameLabels(_ stations: [Station]) {
        // TODO: Bug - label width is not adapted for string width inside
        for station in stations {
            let stationNameLabel = StationLabel(frame: CGRect(
                x: station.coordinates.x + 10,
                y: station.coordinates.y - 15,
                width: 100.0,
                height: 30.0
            ))
            self.addSubview(stationNameLabel)
            stationNameLabel.text = station.name
            // TODO: use route delegate to color
            highlightCurrentStationLabel(stationNameLabel)
            stationNameLabel.textAlignment = .left
            stationNameLabel.numberOfLines = 0
            stationNameLabel.paddingLeft = 5.0
            stationNameLabel.paddingRight = 2.0
            stationNameLabel.paddingTop = 2.0
            stationNameLabel.paddingBottom = 2.0
            stationNameLabel.textColor = Colors.textColor
            stationNameLabel.font = stationNameLabel.font.withSize(10.0)
            stationNameLabel.isUserInteractionEnabled = true
            let tapGecture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
            stationNameLabel.addGestureRecognizer(tapGecture)
            stationLabels.append(stationNameLabel)
        }
    }
    
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        let label = sender.view as? StationLabel
        let stationName = label?.text
            
        if let selectedStation = stations.filter({ station in station.name == stationName }).first {
            let isFromStation = routeWatcher.currentDirection?.isFromStation ?? true
            let direction = Direction(
                station: selectedStation,
                isFromStation: isFromStation
            )
            routeWatcher.updateCurrentDirection(direction)
            delegate?.updateCurrentStationField(station: selectedStation)
            updateMapCurrentView()
        }
    }
    
    private func highlightCurrentStationLabel(_ label: UILabel) {
        if routeWatcher.currentDirection?.station?.name == label.text {
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
    func updateMapCurrentView() -> MapView {
        for numberLabel in lineNumbersLabels {
            if !routeWatcher.routes.isEmpty {
                numberLabel.alpha = MapSettings.alphaDisabled
            } else {
                numberLabel.alpha = MapSettings.alphaEnabled
            }
        }
        for label in stationLabels {
            highlightCurrentStationLabel(label)
            if routeWatcher.stationFrom?.name == label.text || routeWatcher.stationTo?.name == label.text {
                label.textColor = Colors.textHighlightedColor
                label.layer.borderWidth = 0.0
            } else if !routeWatcher.routes.isEmpty {
                label.textColor = Colors.textDisabledColor
            }
            else {
                label.textColor = Colors.textColor
            }
        }
        return self
    }

    private func addLineNumbersLabels() {
        for line in subway.lines {
            addLineNumberLabel(line)
            
            switch(line.id) {
            case 1:
                let names = ["Девяткино", "Гражданский проспект", "Академическая", "Политехническая", "Площадь мужества", "Лесная", "Выборгская", "Площадь Ленина", "Чернышевская", "Пл. Восстания", "Владимирская", "Пушкинская", "Технологический интитут - I"]
                let stations = Mock.stations(line: line, names: names)
                self.stations.append(contentsOf: stations)
            case 2:
                let names = ["Парнас", "Проспект просвещения", "Озерки", "Удельная", "Пиoнерская", "Черная речка", "Петроградская", "Горьковская", "Невский проспект", "Садовая", "Технологический интитут - II"]
                let stations = Mock.stations(line: line, names: names)
                self.stations.append(contentsOf: stations)
            case 3:
                let names = ["Приморская", "Василеостровская", "Гостиный двор", "Маяковского", "Пл. Александра Невского - I"]
                let stations = Mock.stations(line: line, names: names)
                self.stations.append(contentsOf: stations)
            default:
                print("Stations list is empty for line \(line.id)")
            }
        }
    
        Mock
            .addNodes(stations: self.stations, nodes: ["Пл. Восстания", "Маяковского"])
            .addNodes(stations: self.stations, nodes: ["Технологический интитут - I", "Технологический интитут - II"])
            .addNodes(stations: self.stations, nodes: ["Гостиный двор", "Невский проспект"])
        
        addStationNameLabels(stations)
    }
}
