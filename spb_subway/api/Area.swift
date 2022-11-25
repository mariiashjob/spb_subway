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
    var id: Int
    var parentId: Int
    var name: String
    var areas: [Area]
    
    init?(data: NSDictionary) {
        guard let id = data["id"] as? Int,
              let parentId = data["parent_id"] as? Int,
              let name = data["name"] as? String,
              let areasData = data["areas"] as? [NSDictionary]
             else { return nil }
        
        var areas: [Area] = []
        for data in areasData {
            if let area = Area(data: data) {
                areas.append(area)
            }
        }

        self.id = id
        self.parentId = parentId
        self.name = name
        self.areas = areas
    }
}
