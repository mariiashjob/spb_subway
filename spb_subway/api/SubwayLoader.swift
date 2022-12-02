//
//  SubwayLoader.swift
//  spb_subway
//
//  Created by m.shirokova on 19.11.2022.
//

import Alamofire
import SwiftyJSON

class SubwayLoader {
    
    static let API_AREA  = "https://api.hh.ru/areas/"
    static let API_METRO = "https://api.hh.ru/metro"
    
    func getSpbId(completion: @escaping (Int) -> Void) {
        DispatchQueue.main.async {
            AF.request(SubwayLoader.API_AREA, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            // TODO: responseDecodable
            .responseJSON(completionHandler: { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success:
                        if let value = response.value {
                            let json = JSON(value)
                                    
                            // TODO: define spb id
                            completion(0)
                        }
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                    }
                }
            })
        }
    }
    
    static func getSpbSubwayLines(completion: @escaping ([Line]) -> Void) {
        AF.request(SubwayLoader.API_METRO, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .responseJSON(completionHandler: { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success:
                        if let objects = response.value, let jsonDictList = objects as? [NSDictionary] {
                            for jsonDict in jsonDictList {
                                if let area = Area(data: jsonDict), area.name == City.spb {
                                    completion(area.lines)
                                    return
                                }
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            })
    }
}
