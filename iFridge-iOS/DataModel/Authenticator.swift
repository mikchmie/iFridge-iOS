//
//  Authenticator.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 15.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation
import Unbox

enum AuthenticationError: Error {

    case invalidCredentials, other
}

class Authenticator {

    fileprivate static let TokenKey = "FridgeApiToken"

    init() {

        self.token = UserDefaults.standard.string(forKey: Authenticator.TokenKey)
    }

    fileprivate(set) var token: String? {
        didSet {
            UserDefaults.standard.setValue(self.token, forKey: Authenticator.TokenKey)
        }
    }

    func logIn(login: String, password: String, completion: @escaping (AuthenticationError?) -> Void) {

        FridgeApiProvider.request(.logIn(login: login, password: password)) { (result) in

            switch result {

            case .success(let response):

                do {

                    let apiResponse: StringResponse = try unbox(data: response.data)

                    guard let token = apiResponse.value else {
                        completion(.invalidCredentials)
                        return
                    }

                    self.token = token
                    completion(nil)

                } catch {

                    print(error)
                    completion(.other)
                    return
                }

            case .failure(let error):

                print(error)
                completion(.other)
                return
            }
        }
    }

    func logOut() {

        self.token = nil
    }
}
