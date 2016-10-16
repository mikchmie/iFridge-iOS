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
                                                            parameterEncoding: target.parameterEncoding)
    return endpoint
}

let FridgeApiProvider = MoyaProvider<FridgeApi>(endpointClosure: endpointClosure)

enum FridgeApi {

    case logIn(login: String, password: String)
    case getAllProducts(token: String)
    case saveProduct(product: Product, token: String)
    case addProduct(product: Product, token: String)
}

extension FridgeApi: TargetType {

    var baseURL: URL { return URL(string: "http://localhost:8080/fridge")! }

    var path: String {

        switch self {

        case .logIn:
            return "/auth/login"

        case .getAllProducts, .saveProduct, .addProduct:
            return "/products"
        }
    }

    var method: Moya.Method {

        switch self {

        case .getAllProducts:
            return .GET

        case .logIn, .saveProduct:
            return .POST

        case .addProduct:
            return .PUT
        }
    }

    var parameters: [String : Any]? {

        switch self {

        case .logIn(let login, let password):
            return ["login": login,
                    "password": password]

        case .getAllProducts(let token):
            return ["token": token]

        case .saveProduct(let product, let token), .addProduct(let product, let token):

            let wrappedProduct: [String : Any] = (try? wrap(product)) ?? [:]
            return ["product": wrappedProduct,
                    "token": token]
        }
    }

    var parameterEncoding: Moya.ParameterEncoding {
        switch self {

        case .logIn, .getAllProducts:
            return URLEncoding.methodDependent

        case .saveProduct, .addProduct:
            return JSONEncoding.default
        }
    }

    var sampleData: Data {
        
        return Data()
    }
    
    var task: Task {
        
        return .request
    }
}