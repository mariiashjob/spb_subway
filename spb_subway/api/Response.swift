//
//  Response.swift
//  spb_subway
//
//  Created by m.shirokova on 19.11.2022.
//

import Foundation

class Response {
    var id: Int
    var name: String
    var lines: [Line]
    
    init?(data: NSDictionary) {
        guard let id = data["id"] as? Int,
              let name = data["name"] as? String,
              let linesData = data["lines"] as? [NSDictionary]
             else { return nil }
        
        var lines = [Line]()
        for data in linesData {
            if let line = Line(data: data ) {
                lines.append(line)
            }
        }
        
        self.id = id
        self.name = name
        self.lines = lines
    }
}
