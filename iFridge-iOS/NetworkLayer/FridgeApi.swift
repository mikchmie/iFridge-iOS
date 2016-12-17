//
//  FridgeApi.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 08.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import Moya
import Wrap
import Unbox

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
    case deleteProduct(productID: Int, token: String)
}

extension FridgeApi: TargetType {

    var baseURL: URL { return URL(string: "http://10.0.0.9:8080/fridge")! }

    var path: String {

        switch self {

        case .logIn:
            return "/auth/login"

        case .getAllProducts, .addProduct:
            return "/products"

        case .updateProduct(let product, _):
            return "/products/\(product.id)"

        case .deleteProduct(let productID, _):
            return "/products/\(productID)"
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

        case .deleteProduct:
            return .DELETE
        }
    }

    var parameters: [String : Any]? {

        switch self {

        case .logIn(let login, let password):
            return ["login": login,
                    "password": password]

        case .addProduct(let product, _), .updateProduct(let product, _):
            return (try? wrap(product)) ?? [:]

        case .getAllProducts, .deleteProduct:
            return nil
        }
    }

    var parameterEncoding: Moya.ParameterEncoding {
        switch self {

        case .logIn, .getAllProducts, .deleteProduct:
            return URLEncoding.methodDependent

        case .addProduct, .updateProduct:
            return JSONEncoding.default
        }
    }

    var httpHeaderFields: [String: String]? {

        switch self {

        case .getAllProducts(let token), .addProduct(_, let token), .updateProduct(_, let token), .deleteProduct(_, let token):
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

enum FridgeApiError: Swift.Error {

    case invalidResponseCode(Int)
}

extension FridgeApi {

    static func performGetAllProducts(token: String, completion: @escaping ([Product]) -> Void, failure: ((Swift.Error) -> Void)?) {

        FridgeApiProvider.request(.getAllProducts(token: token)) { (result) in

            switch result {

            case .success(let response):

                print("[GET] " + (String(data: response.data, encoding: .utf8) ?? ""))

                guard response.statusCode == 200 else {

                    failure?(FridgeApiError.invalidResponseCode(response.statusCode))
                    return
                }

                do {
                    let products: [Product] = try unbox(data: response.data)
                    completion(products)

                } catch {
                    failure?(error)
                    return
                }

            case .failure(let error):
                
                failure?(error)
                return
            }
        }
    }

    static func performAddProduct(product: Product, token: String,
                           completion: @escaping (Product) -> Void, failure: ((Swift.Error) -> Void)?) {

        FridgeApiProvider.request(.addProduct(product: product, token: token)) { (result) in

            switch result {

            case .success(let response):

                print("[ADD] " + (String(data: response.data, encoding: .utf8) ?? ""))

                guard response.statusCode == 201 else {

                    failure?(FridgeApiError.invalidResponseCode(response.statusCode))
                    return
                }

                do {
                    let product: Product = try unbox(data: response.data)
                    completion(product)

                } catch {
                    failure?(error)
                    return
                }

            case .failure(let error):
                
                failure?(error)
                return
            }
        }
    }

    static func performUpdateProduct(product: Product, token: String,
                              completion: @escaping (Product) -> Void, failure: ((Swift.Error) -> Void)?) {

        FridgeApiProvider.request(.updateProduct(product: product, token: token)) { (result) in

            switch result {

            case .success(let response):

                print("[UPDATE] " + (String(data: response.data, encoding: .utf8) ?? ""))

                guard response.statusCode == 200 else {

                    failure?(FridgeApiError.invalidResponseCode(response.statusCode))
                    return
                }

                do {
                    let product: Product = try unbox(data: response.data)
                    completion(product)

                } catch {
                    failure?(error)
                    return
                }

            case .failure(let error):
                
                failure?(error)
                return
            }
        }
    }

    static func performDeleteProduct(productID: Int, token: String,
                              completion: @escaping () -> Void, failure: ((Swift.Error) -> Void)?) {

        FridgeApiProvider.request(.deleteProduct(productID: productID, token: token)) { (result) in

            switch result {

            case .success(let response):

                print("[DELETE] " + (String(data: response.data, encoding: .utf8) ?? ""))

                guard response.statusCode == 204 else {

                    failure?(FridgeApiError.invalidResponseCode(response.statusCode))
                    return
                }

                completion()

            case .failure(let error):
                
                failure?(error)
                return
            }
        }
    }
}
