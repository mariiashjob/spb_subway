//
//  Area.swift
//  spb_subway
//
//  Created by m.shirokova on 19.11.2022.
//

import Foundation
import Alamofire
import RealmSwift

class Area {
    var id: Int?
    var name: String
    var url: String
    var lines: [Line]
    
    init?(data: NSDictionary) {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String,
              let url = data["url"] as? String,
              let linesData = data["lines"] as? [NSDictionary] else {
            return nil
        }
        
        var lines: [Line] = []
        for data in linesData {
            if let area = Line(data: data) {
                lines.append(area)
            }
        }

        self.id = Int(id)
        self.name = name
        self.url = url
        self.lines = lines
    }
}
