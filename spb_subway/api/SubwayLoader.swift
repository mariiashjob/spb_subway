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
    static let API_METRO = "https://api.hh.ru/metro/"
    
    func getSpbId(completion: @escaping (Int) -> Void) {
        DispatchQueue.main.async {
            AF.request(SubwayLoader.API_AREA, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            // TODO: responseDecodable
            .responseJSON(completionHandler: { response in
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
            })
        }
    }
    
    func getSpbSubwayData(id: Int, completion: @escaping ([Line]) -> Void) {
        DispatchQueue.main.async {
            AF.request(SubwayLoader.API_METRO + String(id), method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            // TODO: responseDecodable
            .responseJSON(completionHandler: {  response in
                if let objects = response.value, let jsonDict = objects as? NSDictionary {
                    DispatchQueue.main.async {
                        if let response = Response(data: jsonDict), let lines = response.lines as? [Line] {
                            completion(lines)
                        } else {
                            // TODO: add proper eror handling
                            fatalError("API does not response data with results. \n Actual response: \n \(response)")
                        }
                    }
                }
            })
        }
    }
}
