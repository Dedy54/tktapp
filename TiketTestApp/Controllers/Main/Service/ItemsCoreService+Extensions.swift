//
//  ProductCoreService+Extensions.swift
//  TiketTestApp
//
//  Created by Dedy Yuristiawan on 17/04/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation
import SwiftyJSON

extension CoreService {
    
    func getItems(params: [String : String], page: Int = 1, perPage: Int = 10, success: @escaping (Pagination<[Item]>) -> (Void), failure: @escaping (NSError) -> (Void)) {
        var parameters: [String: AnyObject] = [:]
        var headers: [String: String] = [:]
        if let token = PreferenceManager.instance.token {
            headers = ["Authorization": token]
        }
        for (key, value) in params {
            parameters[key] = value as AnyObject?
        }
        parameters["page"] = page as AnyObject?
        parameters["per_page"] = perPage as AnyObject?
        let request = manager.request(home + path + "/herostats", method: .get, parameters: parameters, headers: headers)
        request.responseJSON { response in
            switch response.result {
            case let .success(value):
                let json = JSON(value)
                print("JSON \(json)")
//                saya biasanya menggunakan envelope structure json
//                let statusCodeJson = json["status_code"]
//                let dataJson = json["data"]
//                let paginationJson = json["pagination"]
//                let currentPage = paginationJson["current_page"].intValue
//                let total = paginationJson["total_data"].intValue
//                let lastPage = paginationJson["total_page"].intValue
//                if statusCodeJson.intValue == 200 {}

                switch json.type {
                  case .array:
                    var items = [Item]()
                    for itemJson in json.arrayValue {
                        if let item = Item.with(json: itemJson) {
                            items.append(item)
                        }
                    }

                    let pagination = Pagination<[Item]>(total: 1, currentPage: page, lastPage: 1, data: items)
                    success(pagination)
                  default:
                    let error = NSError(domain: "App", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(json["error"].stringValue)"])
                    print(error.localizedDescription)
                    failure(error as NSError)
                }
            case .failure(_):
                var error: NSError?

                if !Reachability.isConnectedToNetwork() {
                    error = NSError(domain: "App", code: 404, userInfo: nil)
                } else {
                    error = NSError(domain: "App", code: 500, userInfo: nil)
                }

                if let error = error {
                    failure(error as NSError)
                }
            }
        }
    }
    
}
