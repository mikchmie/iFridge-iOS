//
//  FridgeApi.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 08.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import Moya

let FridgeApiProvider = MoyaProvider<FridgeApi>()

enum FridgeApi {

    case getAllProducts
}

extension FridgeApi: TargetType {

    var baseURL: URL { return URL(string: "http://localhost:8080/fridge")! }

    var path: String {

        switch self {

        case .getAllProducts:
            return "/product/list"
        }
    }

    var method: Moya.Method {

        switch self {

        case .getAllProducts:
            return .GET
        }
    }

    var parameters: [String : Any]? {

        switch self {

        default:
            return nil
        }
    }
    
    var sampleData: Data {
        
        return Data()
    }
    
    var task: Task {
        
        return .request
    }
}
