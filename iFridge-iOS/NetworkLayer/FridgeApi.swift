//
//  FridgeApi.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 08.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import Moya
import Wrap

let endpointClosure = { (target: FridgeApi) -> Endpoint<FridgeApi> in

    let url = target.baseURL.appendingPathComponent(target.path).absoluteString

    let endpoint: Endpoint<FridgeApi> = Endpoint<FridgeApi>(URL: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)},
                                                            method: target.method, parameters: target.parameters,
                                                            parameterEncoding: target.parameterEncoding, httpHeaderFields: target.httpHeaderFields)
    return endpoint
}

let FridgeApiProvider = MoyaProvider<FridgeApi>(endpointClosure: endpointClosure)

enum FridgeApi {

    case logIn(login: String, password: String)
    case getAllProducts(token: String)
    case addProduct(product: Product, token: String)
    case updateProduct(product: Product, token: String)
}

extension FridgeApi: TargetType {

    var baseURL: URL { return URL(string: "http://localhost:8080/fridge")! }

    var path: String {

        switch self {

        case .logIn:
            return "/auth/login"

        case .getAllProducts, .addProduct:
            return "/products"

        case .updateProduct(let product, _):
            return "/products/\(product.id)"
        }
    }

    var method: Moya.Method {

        switch self {

        case .getAllProducts:
            return .GET

        case .logIn, .addProduct:
            return .POST

        case .updateProduct:
            return .PUT
        }
    }

    var parameters: [String : Any]? {

        switch self {

        case .logIn(let login, let password):
            return ["login": login,
                    "password": password]

        case .addProduct(let product, _), .updateProduct(let product, _):
            return (try? wrap(product)) ?? [:]

        case .getAllProducts:
            return nil
        }
    }

    var parameterEncoding: Moya.ParameterEncoding {
        switch self {

        case .logIn, .getAllProducts:
            return URLEncoding.methodDependent

        case .addProduct, .updateProduct:
            return JSONEncoding.default
        }
    }

    var httpHeaderFields: [String: String]? {

        switch self {

        case .getAllProducts(let token), .addProduct(_, let token), .updateProduct(_, let token):
            return ["Authorization": token]

        case .logIn:
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
