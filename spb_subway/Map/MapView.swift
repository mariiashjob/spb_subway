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

class MapView: UIView {
    
    var delegate: MapViewDelegate?
    var stations = [Station]()
    var stationLabels = [UILabel]()
    lazy var routeWatcher = RouteWatcher(routeCalculator: routeCalculator)
    private lazy var width = self.bounds.width
    private lazy var height = self.bounds.height
    private lazy var routeCalculator = RouteCalculator(subway: subway)
    private lazy var subway = Subway(
        city: City.spb,
        lines: Mock.lines(width: width, height: height))
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = Colors.backgroundColor
        addLineNumbersLabels()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        for line in subway.lines {
            context
                .setAttributes(color: line.color)
                .drawLine(points: line.points)
        }
        setNeedsDisplay()
    }
    
    func addLineNumberLabel(_ line: Line) {
        let nameLabel = UILabel(frame: CGRect(
            x: (line.points.first?.x ?? 0) - 5,
            y: (line.points.first?.y ?? 0) - 20,
            width: 20.0,
            height: 15.0
        ))
        self.addSubview(nameLabel)
        nameLabel.backgroundColor = line.color
        nameLabel.text = String(line.id)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.layer.cornerRadius = AttributesConstants.cornerRadius / 2
        nameLabel.clipsToBounds = true
    }
    
    func addStationNameLabels(_ stations: [Station]) {
        // TODO: Bug - label width is not adapted for string width inside
        for station in stations {
            let stationNameLabel = StationLabel(frame: CGRect(
                x: station.coordinates.x + 10,
                y: station.coordinates.y - 10,
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
        for label in stationLabels {
            highlightCurrentStationLabel(label)
            if routeWatcher.stationFrom?.name == label.text || routeWatcher.stationTo?.name == label.text {
                label.textColor = Colors.textHighlightedColor
                label.layer.borderWidth = 0.0
            } else {
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
                let names = ["Девяткино", "Гражданский проспект", "Академическая", "Политехническая", "Площадь мужества", "Лесная", "Выборгская", "Площадь Ленина", "Чернышевская"]
                let stations = Mock.stations(line: line, names: names)
                self.stations.append(contentsOf: stations)
            case 2:
                let names = ["Парнас", "Проспект просвещения", "Озерки", "Удельная", "Пиoнерская", "Черная речка", "Петроградская", "Горьковская"]
                let stations = Mock.stations(line: line, names: names)
                self.stations.append(contentsOf: stations)
            default:
                print("Stations list is empty for line \(line.id)")
            }
        }
        addStationNameLabels(stations)
    }
}
