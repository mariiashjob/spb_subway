//
//  Mock.swift
//  spb_subway
//
//  Created by m.shirokova on 19.11.2022.
//

import UIKit

class Data {
    
    static let nodes: [[String]] = [
        ["Площадь Восстания", "Маяковская"],
        ["Технологический институт", "Технологический институт 2"],
        ["Гостиный двор", "Невский проспект"],
        ["Садовая", "Спасская", "Сенная площадь"],
        ["Достоевская", "Владимирская"],
        ["Пушкинская", "Звенигородская"],
        ["Площадь Александра Невского 1", "Площадь Александра Невского 2"]
    ]
    
    static func addPoints() -> [MapCoordinate] {
       return [
        MapCoordinate(name: "Беговая", point: CGPoint(x: 0.1, y: 0.25)),
        MapCoordinate(name: "Василеостровская", point: CGPoint(x: 0.1, y: 0.4)),
        MapCoordinate(name: "Новочеркасская", point: CGPoint(x: 1.0, y: 0.55)),
        MapCoordinate(name: "Улица Дыбенко", point: CGPoint(x: 1.0, y: 0.7)),
        MapCoordinate(name: "Комендантский проспект", point: CGPoint(x: 0.2, y: 0.05)),
        MapCoordinate(name: "Спортивная", point: CGPoint(x: 0.2, y: 0.2)),
        MapCoordinate(name: "Адмиралтейская", point: CGPoint(x: 0.2, y: 0.45)),
        MapCoordinate(name: "Садовая", point: CGPoint(x: 0.3, y: 0.5)),
        MapCoordinate(name: "Площадь Александра Невского 1", point: CGPoint(x: 0.8, y: 0.5)),
        MapCoordinate(name: "Рыбацкое", point: CGPoint(x: 0.8, y: 0.8)),
        MapCoordinate(name: "Технологический институт", point: CGPoint(x: 0.3, y: 0.6)),
        MapCoordinate(name: "Обводный Канал", point: CGPoint(x: 0.55, y: 0.6)),
        MapCoordinate(name: "Шушары", point: CGPoint(x: 0.55, y: 0.9)),
        MapCoordinate(name: "Парнас", point: CGPoint(x: 0.3, y: 0.0)),
        MapCoordinate(name: "Невский проспект", point: CGPoint(x: 0.3, y: 0.4)),
        MapCoordinate(name: "Купчино", point: CGPoint(x: 0.3, y: 0.9)),
        MapCoordinate(name: "Девяткино", point: CGPoint(x: 0.55, y: 0.0)),
        MapCoordinate(name: "Площадь Восстания", point: CGPoint(x: 0.55, y: 0.4)),
        MapCoordinate(name: "Балтийская", point: CGPoint(x: 0.2, y: 0.65)),
        MapCoordinate(name: "Проспект Ветеранов", point: CGPoint(x: 0.2, y: 0.9)),
        MapCoordinate(name: "Владимирская", point: CGPoint(x: 0.55, y: 0.5))
       ]
    }
    
    static func configureNodes(_ stations: [Station]) -> Bool {
        for node in Data.nodes {
            addNodes(stations: stations, nodes: node)
        }
        return true
    }
    
    @discardableResult
    static func addNodes(stations: [Station], nodes: [String]) -> Data.Type {
        let stationsWithNodes = stations.filter({ nodes.contains($0.name) })
        for station in stationsWithNodes {
            for node in stationsWithNodes {
                if station.name != node.name {
                    if node.coordinates == nil {
                        node.coordinates = station.coordinates
                    } else {
                        station.coordinates = node.coordinates
                    }
                    station.nodes.append(node)
                }
            }
        }
        return self
    }
}
